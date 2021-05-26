//
//  File.swift
//
//
//  Created by Dave Duprey on 04/07/2020.
//

import Foundation
import UIKit
import W3WSwiftApi


/// A text field, based on UISearchController with a what3words autocomplete function
@IBDesignable
open class W3WAutoSuggestSearchController: UISearchController, UISearchTextFieldDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, W3AutoSuggestResultsViewControllerDelegate, W3WAutoSuggestTextFieldProtocol {
  
  /// callback for when the user choses a suggestion
  public var suggestionSelected: W3WSuggestionResponse = { _ in }
  
  /// if freeFormText is enabled, this will be called everytime the text field is edited
  public var textChanged: W3WTextChangedResponse = { _ in }

  /// returns the error enum for any error that occurs
  public var onError: W3WAutoSuggestTextFieldErrorResponse = { _ in }
  
  /// language to use
  var language =  W3WApiLanguage.english.code // default language

  /// indicates if the textfield should allow only 3 word addresses or if it can allow any text
  private var freeformText = true

  /// indicates if the textfield should be cleared when user focus changes
  private var allowInvalid3wa = false

  /// indicates if if the voice icon should show, if the voiceAPI is available
  var voiceEnabled = false

  /// this is the view controller for displaying the suggestions
  var autoSuggestViewController = W3WAutoSuggestResultsViewController()
  
  var slashesSize:CGFloat    = W3WSettings.componentsSlashesIconSize
  var slashesPadding:CGFloat = W3WSettings.componentsSlashesPadding
  
  var leftPadding:CGFloat  = 16.0
  var rightPadding:CGFloat = 16.0

  /// you can set the API key in Interface Builder
  @IBInspectable open var apiKey: String? {
    didSet {
      if let a = apiKey {
        set(What3WordsV3(apiKey: a))
      }
    }
  }

  
  public init() {
    super.init(searchResultsController: autoSuggestViewController)
  }
  
  
  public required init?(coder: NSCoder) {
    super.init(searchResultsController: autoSuggestViewController)
  }
  
  
  /// assign a what3words engine, or API to this  component.  language is optional and defaults to English: "en"
  /// - Parameters:
  ///     - w3w: the what3words API or SDK
  ///     - language: a ISO two letter langauge code
  public func set(_ w3w: W3WProtocolV3, language: String = "en") {
    autoSuggestViewController.set(w3w)
    configure()
    
    // this can affect voice ability, reset the voice icon
    set(voice: voiceEnabled)
  }
  
  
  /// assigns an array of options to use on autosuggest calls
  /// - Parameters:
  ///     - options: an array of W3WOption
  public func set(options: [W3WOption]) {
    autoSuggestViewController.set(options: options)
  }


  /// sets the langauge to use when returning three word addresses
  /// - Parameters:
  ///     - language: a ISO two letter langauge code
  public func set(language l: String) {
    language = l
    
    // this can affect voice ability, reset the voice icon
    set(voice: voiceEnabled)
  }

  
  /// (BETA) turns off the text filter that only allows characters in a 3 word address to be typed
  /// this allows dual use of a text field so it can detect three word addresses or it can be ised as a
  /// regular text field, perhaps for old fashioned addresses as well
  /// - Parameters:
  ///     - freeformText: set to true to turn off text filtering, and allow the user to type anything
  public func set(freeformText: Bool) {
    self.freeformText = freeformText
    autoSuggestViewController.set(freeformText: freeformText)
  }

  
  /// turns on and off text clearing behaviour for free form text
  /// when this field looses focus, the text is cleared by default
  /// - Parameters:
  ///     - allowInvalid3wa: set to true to turn off text filtering, and allow the user to type anything
  public func set(allowInvalid3wa: Bool) {
    self.allowInvalid3wa = allowInvalid3wa
  }
  

  
  /// NOTE: this causes the component to use the converToCoordinates call, which may count against your quota
  /// - Parameters:
  ///     - includeCoordinates: set to true and the component will call convertToCoords for every suggestion and provide lat/long in the results (as W3WSquare instead of W3WSuggestion
  public func set(includeCoordinates: Bool) {
    autoSuggestViewController.set(includeCoordinates: includeCoordinates)
  }



  /// turns on voice recognition if it is available
  /// - Parameters:
  ///     - voice: set to true to allow voice input
  public func set(voice: Bool) {
    self.voiceEnabled = voice
    
    if voice && autoSuggestViewController.supportsVoice() {
      self.autoSuggestViewController.initialiseMicrophone()
      showVoiceIcon()
    }
  }

  
  /// makes nessesary initialization, called by init()s
  func configure() {
    autoSuggestViewController.delegate = self
    set(options: [W3WOption.voiceLanguage(language)])
    isActive = true
    searchBar.keyboardType = .URL
  }
  
  
  /// shows the voice icon
  func showVoiceIcon() {
    if autoSuggestViewController.supportsVoice() {
      var height = self.searchBar.frame.size.height * 0.333
      if #available(iOS 13.0, *) {
        height    = searchBar[keyPath: \.searchTextField].font?.pointSize ?? self.searchBar.frame.size.height * 0.8
      }
      let voiceIconView = W3WVoiceIconView(frame: CGRect(x: 0.0, y: 0.0, width: height + rightPadding, height: height))
      //voiceIconView.insets = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right:1.0)
      //voiceIconView.alignment = .leading
      //voiceIconView.set(padding: self.searchBar.frame.size.height * 0.3)
      voiceIconView.set(padding: 0.0)
      
      self.searchBar.showsBookmarkButton = true
      self.searchBar.setImage(voiceIconView.asImage(), for: .bookmark, state: .normal)
      self.searchBar.setImage(voiceIconView.asImage(), for: .bookmark, state: [.highlighted, .selected])
    }
  }
  

  /// initializes the UI
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    self.delegate = self
    self.searchBar.delegate = self
    self.searchResultsUpdater = self
    
    self.autoSuggestViewController.tableView.backgroundColor = .clear
    
    if #available(iOS 13.0, *) {
      self.slashesSize    = searchBar[keyPath: \.searchTextField].font?.pointSize ?? self.searchBar.frame.size.height * 0.8
    } else {
      self.slashesSize    = self.searchBar.frame.size.height * 0.333
    }

    //let slashesView = W3WSlashesView(frame: CGRect(x: 0.0, y: 0.0, width: slashesSize + leftPadding, height: slashesSize))
    //slashesView.alignment = .trailing
    //self.searchBar.setImage(slashesView.asImage(), for: .search, state: .normal)
    self.searchBar.showsSearchResultsButton = false

    if voiceEnabled {
      showVoiceIcon()
    }
    
    self.searchBar.placeholder = W3WSettings.componentsPlaceholderText
  }
  
  
  // MARK: W3AutoSuggestDataSourceDelegate

  
  /// called when the text in the text field is updated, does the filtering of disallowed characters
  func update(text: String?) {
    DispatchQueue.main.async {
      self.searchBar.text = self.autoSuggestViewController.groom(text: text)
    }
  }
  
  
  /// called when new suggestions are avialable
  /// - Parameters:
  ///     - suggestions: the new suggestions
  public func update(suggestions: [W3WSuggestion]) {
    if let suggestion = suggestions.first as? W3WVoiceSuggestion {
      if let words = suggestion.words {
        //self.searchBar.text = words
        update(text: words)
      }
    }
  }
  
  
  /// called when the user selects a suggestion
  /// - Parameters:
  ///     - selected: the suggestion chosen by the user
  public func update(selected: W3WSuggestion) {
    if let words = selected.words {
      update(text: W3WAddress.ensureLeadingSlashes(words))
      suggestionSelected(selected)
      textChanged(words)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.isActive = false
      }
    }
  }
  
  
  /// notifies when and if the address in the text field is a known three word address
  public func update(valid3wa: Bool) {
  }
  
  
  /// called when an error happens
  public func update(error: W3WAutosuggestComponentError) {
    onError(error)
  }
  
  
  // MARK: W3AutoSuggestResultsViewControllerDelegate
  
  
  /// instructs the suggestions view on a good place to position itself
  public func suggestionsLocation(preferedHeight: CGFloat) -> CGRect {
    let origin = self.view.frame.origin
    let size   = CGSize(width: self.searchBar.frame.size.width, height: preferedHeight)
    
    return CGRect(origin: origin, size: size)
  }
  
  
  /// tells the suggestions view a good place for the error notice
  public func errorLocation(preferedHeight: CGFloat) -> CGRect {
    var frame = self.searchBar.superview?.subviews.first?.subviews.first?.frame ?? CGRect.zero
    frame.origin.y += frame.size.height
    frame.size.height = preferedHeight

    return frame
  }

  
  /// gives the suggestions view self's view so it can place itself on it
  public func getParentView() -> UIView {
    return self.view
  }
  
  
  /// returns the text currently being displayed
  public func getCurrentText() -> String? {
    return searchBar.text
  }

  
  /// replaces the text in the text field
  public func replace(text: String) {
    DispatchQueue.main.async {
      self.searchBar.text = text
    }
  }
  
  
  // MARK: UISearchBarDelegate Protocol
  
  

  public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    if searchBar.text == "" {
      searchBar.text = W3WAddress.ensureLeadingSlashes(searchBar.text ?? "")
    }
  }
  
  
  /// called when the text field contents change
  public func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

    if text == "\n" {
      if let words = searchBar.text {
        if autoSuggestViewController.autoSuggestDataSource.is3wa(text: words) {
          DispatchQueue.main.async {
            if self.autoSuggestViewController.autoSuggestDataSource.isInKnownAddressList(text: words) {
              self.suggestionSelected(W3WApiSuggestion(words: words))
              self.textChanged(words)
            }
          }
        }
      }

      self.resignFirstResponder()
      self.dismiss(animated: true)
      self.autoSuggestViewController.hideSuggestions()
      return false
    }
    
    var textCanChange = autoSuggestViewController.textChanged(currentText:searchBar.text, additionalText:text, newTextPosition: range)
    if freeformText {
      textCanChange = true
    }

    return textCanChange
  }

  
  /// called when the search bar text changes
  public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchBar.text = autoSuggestViewController.groom(text: searchBar.text)
    textChanged(searchBar.text)
  }
  

  /// called when the voice button is pressed
  public func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
    startVoice()
  }
  
  
  public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    startVoice()
  }
  
  
  func startVoice() {
    self.isActive = true
    DispatchQueue.main.async {
      self.resignFirstResponder()
      self.searchBar.endEditing(true)
      self.autoSuggestViewController.showMicrophone()
    }
  }
  
  
  public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
    if !allowInvalid3wa && !autoSuggestViewController.autoSuggestDataSource.isInKnownAddressList(text: searchBar.text ?? "") {
      if searchBar.text != "" {
        if !autoSuggestViewController.autoSuggestDataSource.isInKnownAddressList(text: searchBar.text) {
          searchBar.text = ""
          //autoSuggestViewController.autoSuggestDataSource.updateSuggestions(text: "")
          autoSuggestViewController.updateSuggestions(text: "")
          autoSuggestViewController.autoSuggestDataSource.update(error: .noValidAdressFound)
        }
      }
    }

    // hide the suggestions
    autoSuggestViewController.hideSuggestions()

    return true
  }
  
  
  /// don't start editing if the mic is recording
  public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    return !self.autoSuggestViewController.isShowingMicrophone
  }
  
  
  // MARK: UISearchController Delegate
  
  public func didPresentSearchController(_ searchController: UISearchController) {
  }
  
  
  // MARK: UISearchResultsUpdating protocol
  
  
  /// Called when the search bar becomes the first responder or when the user makes changes inside the search bar.
  public func updateSearchResults(for searchController: UISearchController) {
  }
  
}


