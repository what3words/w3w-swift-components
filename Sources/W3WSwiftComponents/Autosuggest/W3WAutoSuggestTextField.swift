//
//  File.swift
//
//
//  Created by Dave Duprey on 04/07/2020.
//

import Foundation
import UIKit
import W3WSwiftApi

/// A text field, based on UITextField with a what3words autocomplete function
@IBDesignable
open class W3WAutoSuggestTextField: UITextField, UITextFieldDelegate, W3AutoSuggestResultsViewControllerDelegate, W3WAutoSuggestTextFieldProtocol {
  
  // MARK: Vars
  
  /// callback for when the user choses a suggestion
  lazy public var onSuggestionSelected: W3WSuggestionResponse = { suggestion in self.suggestionSelected(suggestion) }

  /// To be DEPRECIATED: use onSelected instead - old callback for when the user choses a suggestion, to be depreciate
  public var suggestionSelected: W3WSuggestionResponse = { _ in }
  
  /// if freeFormText is enabled, this will be called everytime the text field is edited
  public var textChanged: W3WTextChangedResponse = { _ in }

  /// returns the error enum for any error that occurs
  public var onError: W3WAutoSuggestTextFieldErrorResponse = { _ in }

  /// you can set the API key in Interface Builder
  @IBInspectable open var apiKey: String? {
    didSet {
      if let a = apiKey {
        set(What3WordsV3(apiKey: a))
      }
    }
  }
  
  /// indicates if the textfield should allow only 3 word addresses or if it can allow any text
  private var freeformText = true
  
  /// indicates if if the voice icon should show, if the voiceAPI is available
  var voiceEnabled = false
  
  /// indicates if the textfield should be cleared when user focus changes
  private var allowInvalid3wa = false

  var disableDarkmode = false
  
  /// this is the view controller for displaying the suggestions
  var autoSuggestViewController = W3WAutoSuggestResultsViewController()
  
  /// views for all the icons that may appear
  var slashesView: UIView! // W3WSlashesView!
  var voiceIconView: W3WVoiceIconView!
  var checkView: W3WCheckIconView!
  var icons: W3WIconStack?
  
  var iconSize:CGFloat    = W3WSettings.componentsSlashesIconSize
  var iconPadding:CGFloat = W3WSettings.componentsSlashesPadding
  
  var leftPadding:CGFloat  = 16.0
  var rightPadding:CGFloat = 16.0
  var padding = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
  
  
  // MARK: Init
  
  
  public init() {
    super.init(frame: CGRect(origin: .zero, size: CGSize(width: W3WSettings.componentsTextFieldWidth, height: W3WSettings.componentsTextFieldHeight)))
    self.delegate = self
  }
  
  
  public init(_ w3w: W3WProtocolV3, frame: CGRect? = nil) {
    super.init(frame: frame ?? CGRect(origin: .zero, size: CGSize(width: W3WSettings.componentsTextFieldWidth, height: W3WSettings.componentsTextFieldHeight)))
    set(w3w)
    self.delegate = self
  }
  
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.delegate = self
  }
  
  
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.delegate = self
  }
  
  
  // MARK: Accessors
  
  
  // let the child view controller know size is changing
  override public var frame: CGRect {
    didSet {
      autoSuggestViewController.updateGeometry()
    }
  }
  
  /// assign a what3words engine, or API to this  component.  language is optional and defaults to English: "en"
  /// - Parameters:
  ///     - w3w: the what3words API or SDK
  ///     - language: a ISO two letter language code
  public func set(_ w3w: W3WProtocolV3, language: String = W3WSettings.defaultLanguage) {
    autoSuggestViewController.delegate = self
    autoSuggestViewController.set(w3w)
    set(options: [W3WOption.voiceLanguage(autoSuggestViewController.autoSuggestDataSource.language)])
    confireuUI()
    
    // this can affect voice ability, reset the voice icon
    set(voice: voiceEnabled)
  }
  
  
  /// assigns an array of options to use on autosuggest calls
  /// - Parameters:
  ///     - options: an array of W3WOption
  public func set(options: [W3WOption]) {
    autoSuggestViewController.set(options: options)
  }

  
  /// intelligently changes the text in the field, adjusting icons to suit
  /// - Parameters:
  ///     - displayText: the text to display
  public func set(display: W3WSuggestion?) {
    if let suggestion = display {
      let t = W3WFormatter.ensureSlashes(text: suggestion.words)
      text = t?.string
      autoSuggestViewController.hideSuggestions()
    }
  }
  

  /// set the color of the text in all AutosuggestTextFields globally
  /// - Parameters:
  ///     - textColor: the color for the text
  ///     - darkMode: the color for the text when the device is in "dark mode"
  public func set(textColor: UIColor, darkMode: UIColor) {
    W3WSettings.set(color: textColor, named: "TextfieldText", forMode: .light)
    W3WSettings.set(color: darkMode, named: "TextfieldText", forMode: .dark)
    updateColours()
  }
  
  
  /// set the color of the textfield background in all AutosuggestTextFields globally
  /// - Parameters:
  ///     - backgroundColor: the color for the textfield background
  ///     - darkMode: the color for the textfield background when the device is in "dark mode"
  public func set(backgroundColor: UIColor, darkMode: UIColor) {
    W3WSettings.set(color: backgroundColor, named: "TextfieldBackground", forMode: .light)
    W3WSettings.set(color: darkMode, named: "TextfieldBackground", forMode: .dark)
    updateColours()
  }
  
  
  /// set the color of the textfield background in all AutosuggestTextFields globally
  /// - Parameters:
  ///     - backgroundColor: the color for the textfield background
  ///     - darkMode: the color for the textfield background when the device is in "dark mode"
  public func set(placeholderColor: UIColor, darkMode: UIColor) {
    W3WSettings.set(color: placeholderColor, named: "TextfieldPlaceholder", forMode: .light)
    W3WSettings.set(color: darkMode, named: "TextfieldPlaceholder", forMode: .dark)
    updateColours()
  }
  

  
  /// sets the language to use when returning three word addresses
  /// - Parameters:
  ///     - language: a ISO two letter language code
  public func set(language l: String) {
    autoSuggestViewController.autoSuggestDataSource.language = l
    
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
    //self.clearsOnResignation = !freeformText // turn off text clearing behaviour for free form text
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
  /// NOTE: this causes the component to use the converToCoordinates call, which may count against your quota
  public func set(includeCoordinates: Bool) {
    autoSuggestViewController.set(includeCoordinates: includeCoordinates)
  }

  
  /// turns on voice recognition if it is available
  /// - Parameters:
  ///     - voice: set to true to allow voice input
  public func set(voice: Bool) {
    self.voiceEnabled = voice

    if voiceEnabled && autoSuggestViewController.supportsVoice() {
      if autoSuggestViewController.supportsVoice() {
        if voiceIconView == nil {
          self.voiceIconView = W3WVoiceIconView(frame: CGRect(origin: .zero, size: CGSize(width: self.frame.height, height: self.frame.height)))
          self.voiceIconView.set(padding: min(self.frame.size.height * 0.2, W3WSettings.componentsIconPadding))
          self.voiceIconView.tapped = { self.autoSuggestViewController.showMicrophone() }
          DispatchQueue.main.async {
            self.updateIcons()
          }
        }
      }
    }
  }

  
  public func set(rightPadding: CGFloat) {
    self.rightPadding = rightPadding
    self.padding      = UIEdgeInsets(top: 0.0, left: leftPadding, bottom: 0.0, right: rightPadding)
  }

  
     
  /// initializes the UI
  func confireuUI() {
    clipsToBounds = true
    
    padding = UIEdgeInsets(top: 0.0, left: leftPadding, bottom: 0.0, right: rightPadding)
    
    updateColours()
    
    if W3WSettings.leftToRight {
      textAlignment = .left
      semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
    } else {
      textAlignment = .right
      semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
    }

    if font == nil {
      font = UIFont.systemFont(ofSize: frame.size.height * 0.618)
    }

    self.iconPadding = (self.frame.size.height - self.iconSize) / 2.0

    if slashesView == nil {
      slashesView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.frame.size.height * 0.309, height: self.frame.size.height))
    }

    updateIcons()
    
    if checkView == nil {
      DispatchQueue.main.async {
        self.checkView = W3WCheckIconView()
        self.checkView.set(padding: min(self.frame.size.height * 0.2, W3WSettings.componentsIconPadding))
        self.checkView.isHidden = true
        //iconsView.add(left: checkView)
        self.updateIcons()
      }
    }

    keyboardType = .URL
        
    adjustsFontSizeToFitWidth = false
    
    layer.borderWidth = 1.0
    layer.borderColor = W3WSettings.color(named: "BorderColor").cgColor
    
//    DispatchQueue.main.async {
//      self.voiceIconView?.frame = CGRect(x: self.iconPadding, y: self.iconPadding, width: self.iconSize, height: self.iconSize)
//    }
    
    if placeholder == nil {
      placeholder = W3WSettings.componentsPlaceholderText
    }
  }
  
  
  public func set(darkModeSupport: Bool) {
    disableDarkmode = !darkModeSupport
    
    if #available(iOS 13.0, *) {
      overrideUserInterfaceStyle = darkModeSupport ? .unspecified : .light
    }
    autoSuggestViewController.set(darkModeSupport: darkModeSupport)
    
    updateColours()
  }
  
  
  func updateIcons() {
    self.leftViewMode = .always
    self.rightViewMode = .always

    // make icon placeholder
    if icons == nil {
      icons = W3WIconStack(frame: CGRect(origin: .zero, size: CGSize(width: self.frame.height, height: self.frame.height)))
    }
    let iconHeight = (self.frame.width / self.frame.height > 5) ? self.frame.height : self.frame.width / 5.0
    icons?.frame = CGRect(origin: icons?.frame.origin ?? .zero, size: CGSize(width: iconHeight, height: iconHeight))
    icons?.resize()
    
    // if there is a checkmark, put it in
    if checkView != nil {
      icons?.add(left: checkView)
    }
    
    // if there is a voice icon, put it in
    voiceIconView?.frame = CGRect(origin: .zero, size: CGSize(width: self.frame.height, height: self.frame.height))
    if voiceIconView != nil {
      icons?.add(left: voiceIconView)
    }

    // assign the things to the correct sides of the textfield
    self.leftView  = slashesView
    self.rightView = icons
  }

  
  
  func update(checkmark: Bool) {
    // show green check on valid 3wa
    if checkmark {
      self.checkView?.isHidden = false
      self.voiceIconView?.isHidden = true
      
      // show voice icon if voice is enabled and supported by the w3w engine
    } else if self.voiceEnabled && self.autoSuggestViewController.supportsVoice() {
      self.checkView?.isHidden = true
      self.voiceIconView?.isHidden = false
      
      // word is not a valied 3wa and voice is not available - show no icon
    } else {
      self.checkView?.isHidden = true
      self.voiceIconView?.isHidden = true
    }
    
    self.updateIcons()
  }
  
  
  
  public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    updateColours()
  }
  
  
  
  func updateColours() {
    DispatchQueue.main.async {
      self.textColor          = W3WSettings.color(named: "TextfieldText", forMode: self.disableDarkmode ? .light : W3WColorScheme.colourMode)
      self.backgroundColor     = W3WSettings.color(named: "TextfieldBackground", forMode: self.disableDarkmode ? .light : W3WColorScheme.colourMode)
      self.layer.borderColor    = W3WSettings.color(named: "BorderColor", forMode: self.disableDarkmode ? .light : W3WColorScheme.colourMode).cgColor
      self.attributedPlaceholder = NSAttributedString(string: self.attributedPlaceholder?.string ?? "", attributes: [NSAttributedString.Key.foregroundColor: W3WSettings.color(named: "TextfieldPlaceholder", forMode: self.disableDarkmode ? .light : W3WColorScheme.colourMode)])
    }
  }
  
  
  /// puts all subviews into their place
  public override func layoutSubviews() {
    super.layoutSubviews()
    updateIcons()
  }
  
  
  
  // MARK: W3AutoSuggestDataSourceDelegate
  
  
  /// called when the text in the text field is updated, does the filtering of disallowed characters
  func update(text: String?) {
    DispatchQueue.main.async {
      self.text = self.autoSuggestViewController.groom(text: text)
    }
  }
  
  
  /// called when new suggestions are avialable
  /// - Parameters:
  ///     - suggestions: the new suggestions
  public func update(suggestions: [W3WSuggestion]) {
  }
  
  
  /// called when the user selects a suggestion
  /// - Parameters:
  ///     - selected: the suggestion chosen by the user
  public func update(selected: W3WSuggestion) {
    if let words = selected.words {
      update(text: W3WAddress.ensureLeadingSlashes(words))
      onSuggestionSelected(selected)
      textChanged(words)
      dismissKeyboard()
      DispatchQueue.main.async {
        self.update(checkmark: self.autoSuggestViewController.isValid3wa(text: self.text ?? ""))
      }
    }
  }
  
  
  /// notifies when and if the address in the text field is a known three word address
  /// removes the green check mark on the right of the field if the word isn't valid
  public func update(valid3wa: Bool) {
    if !valid3wa {
      DispatchQueue.main.async {
        self.update(checkmark: valid3wa)
      }
    }
  }
  
  
  /// called when an error happens
  public func update(error: W3WAutosuggestComponentError) {
    onError(error)
  }
  
  
  // MARK: TextField Stuff

  
  /// dismiss the on screen keyboard
  func dismissKeyboard() {
    DispatchQueue.main.async {
      self.resignFirstResponder()
    }
  }
  
  
  // MARK: UITextFieldDelegate
  
  /// called when the text contents change
  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    var textCanChange = autoSuggestViewController.textChanged(currentText:textField.text, additionalText:string, newTextPosition: range)
    if freeformText {
      textCanChange = true
    }
    
    return textCanChange
  }
  
  
  /// called when the text changes
  public func textFieldDidChangeSelection(_ textField: UITextField) {
    DispatchQueue.main.async {
      textField.text = self.autoSuggestViewController.groom(text: textField.text)
    }
    textChanged(self.text)
  }
  
  
  public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    if !allowInvalid3wa && !autoSuggestViewController.autoSuggestDataSource.isInKnownAddressList(text: text ?? "") {
      if !autoSuggestViewController.autoSuggestDataSource.isInKnownAddressList(text: text) {
        text = ""
        //autoSuggestViewController.autoSuggestDataSource.updateSuggestions(text: "")
        autoSuggestViewController.updateSuggestions(text: "")
        autoSuggestViewController.autoSuggestDataSource.update(error: .noValidAdressFound)
      }
    }
    
    // hide the suggestions
    autoSuggestViewController.hideSuggestions()
    
    return true
  }
  
  
  public func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField.text == "" {
      textField.text = W3WAddress.ensureLeadingSlashes(textField.text ?? "")
    }
  }
  
  
  // MARK: W3AutoSuggestResultsViewControllerDelegate
  
  
  /// instructs the suggestions view on a good place to position itself
  public func suggestionsLocation(preferedHeight: CGFloat) -> CGRect {
    var origin = frame.origin
    origin.y += frame.size.height + W3WSettings.componentsTableTopMargin
    
    let size = CGSize(width: frame.size.width, height: preferedHeight)
    
    return CGRect(origin: origin, size: size)
  }
  
  
  /// tells the suggestions view a good place for the error notice
  public func errorLocation(preferedHeight: CGFloat) -> CGRect {
    var f = frame
    f.origin.y += f.size.height
    f.size.height = preferedHeight
    
    return f
  }
  

  
  /// gives the suggestions view self's view so it can place itself on it
  public func getParentView() -> UIView {
    return self
  }
  
  
  /// returns the text currently being displayed
  public func getCurrentText() -> String? {
    return text
  }
  

  /// replaces the text in the text field
  public func replace(text: String) {
    DispatchQueue.main.async {
      self.text = text
    }
  }

  
  // MARK: UITextFieldDelegate
  
  
  /// called when the text field contents change
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if let words = self.text {
      if autoSuggestViewController.autoSuggestDataSource.is3wa(text: words) {
        DispatchQueue.main.async {
          if self.autoSuggestViewController.autoSuggestDataSource.isInKnownAddressList(text: words) {
            self.onSuggestionSelected(W3WApiSuggestion(words: words))
            self.textChanged(words)
            self.resignFirstResponder()
            self.autoSuggestViewController.hideSuggestions()
            //self.text = ""
            self.update(checkmark: self.autoSuggestViewController.isValid3wa(text: words))
          }
        }
      }
    }
    
    return false
  }
  
}
