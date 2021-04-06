//
//  File.swift
//  
//
//  Created by Dave Duprey on 04/07/2020.
//

import Foundation
import UIKit
import W3WSwiftApi


/// protocol for talking to the tableview and providing it with updates and data
protocol W3WAutoSuggestDataSourceDelegate {
  func update(suggestions: [W3WSuggestion])
  func update(selected: W3WSuggestion)
  func update(error: W3WAutosuggestComponentError)
  func update(didYouMean: String)
  func update(valid3wa: Bool)
  func replace(text: String)
}


/// the model for the autosuggest components, calls the API or SDK, and provides suggestions to the views
class W3AutoSuggestDataSource: NSObject, UITableViewDataSource, W3WOptionAcceptorProtocol {
    
  /// the text field component that this data source services
  var delegate: W3WAutoSuggestDataSourceDelegate?
  
  /// callback for the UI to update/animate any graphics showing microphone volume/amplitude
  public var volumeUpdate: (Double) -> () = { _ in }
  
  /// callback for when the voice recognition stopped
  public var listeningUpdate: ((W3WVoiceListeningState) -> ()) = { _ in }

  /// the current suggestions
  var suggestions = [W3WSuggestion]()
  
  /// a record of renect known 3 word addresses
  var knownValidThreeWordAddresses = Set<String>()
  
  /// the options to use for autosuggest calls
  var options = [W3WOption]()
  
  /// language to use
  var language = W3WApiLanguage.english.code // default language
  
  /// the languages supported by voice
  static var voiceLanguages: [W3WLanguage]? = nil

  /// to remember the last autosugggest text so that the autosuggest-selected aPI can be called
  var lastAutosuggestTextUsed = ""

  /// the API or SDK
  var w3w: W3WProtocolV3?

  /// microphone for recording if we are using voice
  var microphone: W3WMicrophone!
  
  /// makes sure the autosuggest isn't called too frequently
  var suggestionsDebouncer: W3WTextFieldDebouncer?
  
  /// if true, then this will use convertToCoordinates to return lat/long for every suggestion (calls will return W3WSquare instead of W3WSuggestion)
  var useConvertToCoordinates = false

  /// indicates if free form text is being used in text field, or if it is only allowing w3w characters
  private var freeformText = true

  
  func set(w3w: W3WProtocolV3) {
    self.w3w = w3w
    configure()
    
    if let w3wApi = w3w as? What3WordsV3 {
      let headerValue = "what3words-Swift/" + W3WSettings.W3WSwiftComponentsVersion + " " + figureOutVersionInfo()
      w3wApi.set(customHeaders: ["X-W3W-AS-Component" : headerValue])
    }
  }
  
  
  /// assigns an array of options to use on autosuggest calls
  /// - Parameters:
  ///     - options: an array of W3WOption
  func set(options: [W3WOption]) {
    self.options = options
    
    // set the language if specified in the options.  it is passed as a parameter to autosuggest, and as an option, causing some confusion, but underscoreing to the programmer that it is obligitory
    for option in options {
      if option.key() == W3WOptionKey.voiceLanguage {
        language = option.asString()
        break
      }
    }
  }
  
  
  /// adds an option to the option list, replaces any existing options of the same kind
  /// - Parameters:
  ///     - options: an array of W3WOption
  func add(option: W3WOption) {
    options.removeAll(where: { o in
      o.key() == option.key()
    })
    options.append(option)
  }

  
  /// tells the component to use convertToCoordinates to retrieve lat/long
  /// - Parameters:
  ///     - includeCoordinates: if true, then this will use convertToCoordinates to return lat/long for every suggestion (calls will return W3WSquare instead of W3WSuggestion)
  func set(includeCoordinates: Bool) {
    useConvertToCoordinates = includeCoordinates
  }

  
  /// tells us if we are allowing any characters into the text field or only allowing w3w letters and separators
  /// - Parameters:
  ///     - freeformText: true tells us if we are allowing any characters into the text field and not only allowing w3w letters and separators
  func set(freeformText: Bool) {
    self.freeformText = freeformText
  }


  /// do initial set up
  func configure() {
    // initialize the microphone and localize two of it's event closures to be used by viewcontrollers associated with this object
    microphone = W3WMicrophone()
    microphone.volumeUpdate = { volume in self.volumeUpdate(volume) }
    microphone.listeningUpdate = { state in self.listeningUpdate(state) }
    
    // set up the debouncer as to not call autosuggest too rapidly
    suggestionsDebouncer = W3WTextFieldDebouncer(delay: 1.0, handler: { text in self.updateSuggestions(text: text) })
  }

  
  /// when a new suggestion list if found this updates the nessesary things
  func update(suggestions: [W3WSuggestion]) {
    self.suggestions = suggestions
    self.delegate?.update(suggestions: suggestions)
   
    addToKnownAddressList(suggestions: suggestions)
  }
  
  
  /// handles changes to the text for the text field, and lets caller know if the new input is allowed or not
  func textChanged(currentText:String?, additionalText:String?, newTextPosition:NSRange) -> Bool {
    var allowTypingToContinue = true

    if let u = additionalText {
      if isUrl(text: u) {
        if let i = u.range(of: "/", options: .backwards) {
          let twa = String(u.suffix(from: i.upperBound)).removingPercentEncoding ?? ""
          if is3wa(text: twa) {
            delegate?.replace(text: twa)
            suggestionsDebouncer?.call(text: twa)
            checkForValid3wa(text: twa)
            return false
          }
        }
      }
    }
    
    if let t = currentText, let n = additionalText {
      let newText = t.replacingCharacters(in: Range(newTextPosition, in: t)!, with: n)
      removeLeadingTripleSlashesInTextField(text: newText)
      
      allowTypingToContinue = has3waCharacters(text: newText) || freeformText

      if allowTypingToContinue {
        suggestionsDebouncer?.call(text: newText)
        checkForValid3wa(text: newText)
      }
    }

    return allowTypingToContinue
  }
  
  
  /// formats input text
  func groom(text: String?) -> String? {
    return text?.lowercased()
  }
  
  
  /// determines which characters are allowed as input
  func has3waCharacters(text: String) -> Bool {
    if (text.rangeOfCharacter(from: .whitespacesAndNewlines) != nil) {
      return false
    }
    
    //let regex_string = "^/*([^0-9`~!@#$%^&*()+\\-_=\\]\\[{\\}\\\\|'<,.>?/\";:£§º©®\\s]|[.｡。･・︒។։။۔።।]){0,}$"
    let regex = try! NSRegularExpression(pattern:W3WSettings.regex_3wa_characters, options: [])
    let count = regex.numberOfMatches(in: text, options: [], range: NSRange(text.startIndex..<text.endIndex, in:text))
    if (count > 0) {
      return true
    }
    else {
      return false
    }
  }

  
  /// checks if input looks like a 3 word address or not
  func is3wa(text: String) -> Bool {
    //let regex_string = "^/*[^0-9`~!@#$%^&*()+\\-_=\\]\\[{\\}\\\\|'<,.>?/\";:£§º©®\\s]{1,}[.｡。･・︒។։။۔።।][^0-9`~!@#$%^&*()+\\-_=\\]\\[{\\}\\\\|'<,.>?/\";:£§º©®\\s]{1,}[.｡。･・︒។։။۔።।][^0-9`~!@#$%^&*()+\\-_=\\]\\[{\\}\\\\|'<,.>?/\";:£§º©®\\s]{1,}$"
    let regex = try! NSRegularExpression(pattern:W3WSettings.regex_match, options: [])
    let count = regex.numberOfMatches(in: text, options: [], range: NSRange(text.startIndex..<text.endIndex, in:text))
    if (count > 0) {
      return true
    }
    else {
      return false
    }
  }
  
  
  /// checks if input looks like a 3 word address or not
  func isAlmost3wa(text: String) -> Bool {

    let regex = try! NSRegularExpression(pattern:W3WSettings.regex_loose_match, options: [])
    let count = regex.numberOfMatches(in: text, options: [], range: NSRange(text.startIndex..<text.endIndex, in:text))
    if (count > 0) {
      return true
    }
    else {
      return false
    }
  }
  
  
  
  func make3waFromAlmost3wa(text: String) -> String {
    let regex   = try! NSRegularExpression(pattern: W3WSettings.regex_3wa_word)
    let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in:text))
    
    var words = [String]()
    for match in matches {
      print(text[Range(match.range, in: text)!])
      let word = String(text[Range(match.range, in: text)!])
      words.append(word)
    }

    return words.joined(separator: ".")
  }
  
  
  /// checks if the address is a known three word address, that is, if it is in the suggestions or not
  func checkForValid3wa(text: String?) {
    delegate?.update(valid3wa: isInKnownAddressList(text: text))
  }
  

  func addToKnownAddressList(suggestions: [W3WSuggestion]?) {
    for suggestion in suggestions ?? [] {
      addToKnownAddressList(text: suggestion.words)
    }
  }

  
  func addToKnownAddressList(suggestion: W3WSuggestion) {
    addToKnownAddressList(text: suggestion.words)
  }
  
  
  func addToKnownAddressList(text: String?) {
    if let w = text {
      knownValidThreeWordAddresses.insert(w)
    }
  }
  
  
  /// checks if the address is a known three word address, that is, if it is in the suggestions or not
  func isInKnownAddressList(text: String?) -> Bool {
    var valid = false
    
    if let words = text {
      valid = knownValidThreeWordAddresses.contains(words)
    }

    return valid
  }
  
  
  /// determine if the input is a URL, for accepting copy and paste input such as:  https://w3w.co/index.home.raft
  func isUrl(text: String) -> Bool {
    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    if let match = detector.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) {
      // it is a link, if the match covers the whole string
      return match.range.length == text.utf16.count
    } else {
      return false
    }
  }
  

  /// remove any leading /// from the text - only if it is in three word address format
  func removeLeadingTripleSlashesInTextField(text: String) {
    var newText = text
    
    if is3wa(text: newText) {
      if newText.prefix(3) == "///" {
        newText.removeFirst(3)
        delegate?.replace(text: newText)
      }
    }
  }
  
  
  /// given new text, this calls autosuggest to update the current suggestions
  func updateSuggestions(text: String) {
    if is3wa(text: text) {
      lastAutosuggestTextUsed = text
      w3w?.autosuggest(text: text, options: options) { suggestions, error in
        if let e = error {
          self.update(apiError: e)
        } else {
          self.response(suggestions: suggestions)
          self.addToKnownAddressList(suggestions: suggestions)
        }

        self.checkForValid3wa(text: text)
      }
      
    // if the text is not a 3wa but close to one, we call to put up a 'did you mean' notice to the user
    } else if isAlmost3wa(text: text) {
      let fixedText = make3waFromAlmost3wa(text: text)
      w3w?.autosuggest(text: fixedText, options: options) { suggestions, error in
        self.addToKnownAddressList(suggestions: suggestions)
        if let words = suggestions?.first?.words {
          if words == fixedText {
            self.delegate?.update(didYouMean: words)
            self.update(suggestions: [W3WSuggestion]())
          }
        }
      }
    } else {
      self.update(suggestions: [W3WSuggestion]())
    }
  }
  
  
  /// deal with autosuggest response
  func response(suggestions: [W3WSuggestion]?) {
    self.update(suggestions: suggestions ?? [])
  }
  

  // MARK: Voice Stuff

  
  /// lets caller know if this supports voice input or not
  func supportsVoice() -> Bool {
    var voiceSupport = false
    
    if let _ = w3w as? W3WVoice {
      updateVoiceLanguageListIfNessesary()

      // if suppordes voice language list contains the current voice
      if W3AutoSuggestDataSource.voiceLanguages?.contains(where: { language in return language.code == self.language }) ?? false {
        voiceSupport = true
      }
    }
    
    return voiceSupport
  }
  

  /// start recoring the voice input
  func startListening() {
    
    if microphone.isRecording() {
      microphone.stop()
    }

    // if the API or SDK supports voice input
    if let voiceapi = w3w as? W3WVoice {
      
      // call autosuggest with the audio stream from the microphone
      voiceapi.autosuggest(audio: microphone, language:language, options: options, callback: { suggestions, error in
        if let e = error {
          self.update(voiceApiError: e)
        } else {
          self.response(suggestions: suggestions)
          if (suggestions?.count ?? 0) == 0 {
            self.update(error: .noValidAdressFound)
          }
        }
      })
    }
  }
  
  
  /// if this is currently recording the user's voice
  func isListening() -> Bool {
    return microphone.isRecording()
  }
  
  
  /// stop the voice recorder
  func stopListening() {
    microphone?.stop()
  }

  
  /// if this is voice capable, make sure we have a list of available langauges, if we don't then block execution and go get one
  func updateVoiceLanguageListIfNessesary() {
    if let w3wApi = w3w as? What3WordsV3 {
      if let _ = w3w as? W3WVoice {
        if W3AutoSuggestDataSource.voiceLanguages == nil {
          let semaphore = DispatchSemaphore(value: 0) // use a semaphore to wait for the reply
            w3wApi.availableVoiceLanguages() { languages, error in
              W3AutoSuggestDataSource.voiceLanguages = languages
              semaphore.signal()
          }

          _ = semaphore.wait(timeout: .distantFuture)
        }
      }
    }
  }
  
  
  
  // MARK: Logging
  
  
  /// inform the API that a user made a selection
  func log(selection: W3WSuggestion) {
    // if we are using the API, report activity
    if let api = w3w as? What3WordsV3 {
      if !api.customServersSet() {
        var parameters = [
          "raw-input": lastAutosuggestTextUsed,
          "selection": selection.words ?? "",
          "rank": ""
        ]
        
        if let s = selection as? W3WApiSuggestion {
          if let rank = s.rank {
            parameters["rank"] = "\(rank)"
          }
        }
        
        if let _ = selection as? W3WVoiceSuggestion {
          parameters["source-api"] = "voice"
        }
        
        api.performRequest(path: "/autosuggest-selection", params: parameters) { results, error in
          // nothing is returned, and we ignore any error too
        }
      }
    }
  }
  
  
  
  // MARK: Errors
  
  
  /// called when the API reports an error
  func update(apiError: W3WError) {
    update(error: W3WAutosuggestComponentError.apiError(error: apiError))
  }
  
  
  /// called when the voice API reports an error
  func update(voiceApiError: W3WVoiceError) {
    update(error: W3WAutosuggestComponentError.voiceApiError(error: voiceApiError))
  }
  
  
  /// called when this component reports an error
  func update(error: W3WAutosuggestComponentError) {
    self.delegate?.update(error: error)
    
    if isListening() {
      stopListening()
    }
  }
  
  
  // MARK: - Table view
  // wasn't sure if this shouidl go here in the DataSource, or in the TableView.
  // this returns UITableViewCells so should probably go in TableView
  // but it also needs to know the data, so should probably go here
  
  
  /// called when the user selects a suggestion
  func update(rowSelected: Int, clearResults:Bool = true) {
    if suggestions.count > rowSelected {
      let suggestion = suggestions[rowSelected]
      
      log(selection: suggestion)
      
      // tell the delegate about the suggestion, but if required look up the coordinates, and return it as a W3WSquare, which is a W3WSuggesiton with coordinates (and a few other things)
      if useConvertToCoordinates {
        if let words = suggestion.words {
          w3w?.convertToCoordinates(words: words) { square, error in
            if let s = square {
              self.delegate?.update(selected: s)
              self.checkForValid3wa(text: s.words)
            }
          }
        }
      } else {
        delegate?.update(selected: suggestion)
        self.checkForValid3wa(text: suggestion.words)
      }
    }
    
    if clearResults {
      update(suggestions: [W3WSuggestion]())
    }
  }
  
  
  /// delegate for the tablview
  func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  /// delegate for the tablview
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return suggestions.count
  }
  
  
  /// delegate for the tablview when it needs a cell
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: W3WSuggestionTableViewCell.cellIdentifier, for: indexPath) as? W3WSuggestionTableViewCell
    
    let suggestion = suggestions[indexPath.row]
    cell?.set(address: suggestion.words, countryCode: suggestion.country, nearestPlace: suggestion.nearestPlace, language: language)
    
    return cell!
  }

  
  // Establish the various version numbers in order to set an HTTP header
  private func figureOutVersionInfo() -> String {
    #if os(macOS)
    let os_name        = "Mac"
    #elseif os(watchOS)
    let os_name        = WKInterfaceDevice.current().systemName
    #else
    let os_name        = UIDevice.current.systemName
    #endif
    let os_version     = ProcessInfo().operatingSystemVersion
    var swift_version  = "x.x"
    
    #if swift(>=7)
    swift_version = "7.x"
    #elseif swift(>=6)
    swift_version = "6.x"
    #elseif swift(>=5)
    swift_version = "5.x"
    #elseif swift(>=4)
    swift_version = "4.x"
    #elseif swift(>=3)
    swift_version = "3.x"
    #elseif swift(>=2)
    swift_version = "2.x"
    #else
    swift_version = "1.x"
    #endif
    
    return "(Swift " + swift_version + "; " + os_name + " "  + String(os_version.majorVersion) + "."  + String(os_version.minorVersion) + "."  + String(os_version.patchVersion) + ")"
  }
  
  
}


