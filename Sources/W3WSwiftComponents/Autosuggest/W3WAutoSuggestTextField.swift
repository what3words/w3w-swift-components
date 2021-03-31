//
//  File.swift
//
//
//  Created by Dave Duprey on 04/07/2020.
//

import Foundation
import UIKit
import W3WSwiftApi


@IBDesignable
open class W3WAutoSuggestTextField: UITextField, UITextFieldDelegate, W3AutoSuggestResultsViewControllerDelegate, W3WAutoSuggestTextFieldProtocol {

  /// callback for when the user choses a suggestion
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

  /// this is the view controller for displaying the suggestions
  var autoSuggestViewController = W3WAutoSuggestResultsViewController()
  
  /// views for all the icons that may appear
  var slashesView: W3WSlashesView!
  var voiceIconView: W3WVoiceIconView!
  var checkView: W3WCheckIconView!
  var iconsView: W3WIconStack!
  
  var slashesSize:CGFloat    = W3WSettings.componentsSlashesIconSize
  var slashesPadding:CGFloat = W3WSettings.componentsSlashesPadding
  
  var leftPadding:CGFloat  = 16.0
  var rightPadding:CGFloat = 16.0

  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.delegate = self
  }
  
  
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.delegate = self
  }
  
  
  
  /// assign a what3words engine, or API to this  component.  language is optional and defaults to English: "en"
  /// - Parameters:
  ///     - w3w: the what3words API or SDK
  ///     - language: a ISO two letter langauge code
  public func set(_ w3w: W3WProtocolV3, language: String = "en") {
    autoSuggestViewController.set(w3w: w3w)
    configure()
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


  /// sets the langauge to use when returning three word addresses
  /// - Parameters:
  ///     - language: a ISO two letter langauge code
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
          voiceIconView = W3WVoiceIconView()
          voiceIconView.set(padding: frame.size.height * 0.2)
          voiceIconView.tapped = { self.autoSuggestViewController.showMicrophone() }
          iconsView.add(right: voiceIconView)
        }
//        DispatchQueue.main.async {
//          self.voiceIconView?.isHidden = false
//        }
      }

    } else {
//      DispatchQueue.main.async {
//        self.voiceIconView?.isHidden = true
//      }
    }

  }

  
  public func set(leftPadding: CGFloat) {
    self.leftPadding = leftPadding
  }

  
  public func set(rightPadding: CGFloat) {
    self.rightPadding = rightPadding
  }

  
  /// makes nessesary initialization, called by init()s
  func configure() {
    autoSuggestViewController.delegate = self
    set(options: [W3WOption.voiceLanguage(autoSuggestViewController.autoSuggestDataSource.language)])
  }
  
  
  /// initializes the UI
  func confireuUI() {
    clipsToBounds = true
    
    if backgroundColor == nil {
      backgroundColor = .white
    }
    
    if W3WSettings.leftToRight {
      textAlignment = .left
    } else {
      textAlignment = .right
    }

    if font == nil {
      font = UIFont.systemFont(ofSize: frame.size.height * 0.618)
    } else {
      font = font?.withSize(frame.size.height * 0.618)
    }
    
    self.slashesPadding = (self.frame.size.height - self.slashesSize) / 2.0

    if slashesView == nil {
      slashesView = W3WSlashesView(frame: CGRect(x: slashesPadding, y: slashesPadding, width: frame.size.height, height: frame.size.height))
    }
    if W3WSettings.leftToRight {
      slashesView.set(padding: 2.0)
    } else {
      slashesView.set(padding: 8.0)
    }
    
    if iconsView == nil {
      iconsView = W3WIconStack(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: frame.size.height))
      iconsView.spacing = frame.size.height * -0.2
    }
    
    assignLeadingAndTrailingIcons(leading: slashesView, trailing: iconsView)
    
    if checkView == nil {
      checkView = W3WCheckIconView()
      checkView.set(padding: frame.size.height * 0.2)
      checkView.isHidden = true
      iconsView.add(left: checkView)
    }

    keyboardType = .URL
        
    adjustsFontSizeToFitWidth = false
    
    layer.borderWidth = 0.5
    layer.borderColor = W3WSettings.componentsBorderColor.cgColor
    
    DispatchQueue.main.async {
      self.slashesView.frame = CGRect(x: self.slashesPadding, y: self.slashesPadding, width: self.slashesSize, height: self.slashesSize)
      self.voiceIconView?.frame = CGRect(x: self.slashesPadding, y: self.slashesPadding, width: self.slashesSize, height: self.slashesSize)
      self.checkView?.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.height * 0.8, height: self.frame.size.height * 0.8)
    }
    
    if placeholder == nil {
      placeholder = W3WSettings.componentsPlaceholderText
    }
  }
  
  
  override public func leftViewRect(forBounds bounds: CGRect) -> CGRect {
    return CGRect(x: leftPadding, y: frame.size.height * 0.1, width: frame.size.height * 0.8, height: frame.size.height * 0.8)
  }
  
  
  override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    if W3WSettings.leftToRight {
      return CGRect(x: frame.size.width - frame.size.height * 0.8 - rightPadding, y: 0.0, width: frame.size.height, height: frame.size.height)
    } else {
      return CGRect(x: frame.size.width - frame.size.height * 0.8 - rightPadding * 0.75, y: 0.0, width: frame.size.height, height: frame.size.height)
    }
  }
  
  
  func assignLeadingAndTrailingIcons(leading: UIView, trailing: UIView) {
    self.leftViewMode = .always
    self.rightViewMode = .always

    if W3WSettings.leftToRight {
      self.leftView = leading
      self.rightView = trailing
    } else {
      self.leftView = trailing
      self.rightView = leading
    }
  }
  
  
  /// puts all subviews into their place
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    iconsView?.resize()
    if let sv = slashesView, let iv = iconsView {
      assignLeadingAndTrailingIcons(leading: sv, trailing: iv)
    }
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
  func update(suggestions: [W3WSuggestion]) {
  }
  
  
  /// called when the user selects a suggestion
  /// - Parameters:
  ///     - selected: the suggestion chosen by the user
  func update(selected: W3WSuggestion) {
    if let words = selected.words {
      update(text: words)
      suggestionSelected(selected)
      textChanged(words)
      dismissKeyboard()
    }
  }
  
  
  /// notifies when and if the address in the text field is a known three word address
  /// shows the green check mark on the right of the field
  func update(valid3wa: Bool) {
    DispatchQueue.main.async {
      
      // show green check on valid 3wa
      if valid3wa {
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
    }
  }
  
  
  /// called when an error happens
  func update(error: W3WAutosuggestComponentError) {
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
        autoSuggestViewController.autoSuggestDataSource.updateSuggestions(text: "")
        autoSuggestViewController.autoSuggestDataSource.update(error: .noValidAdressFound)
      }
    }
    
    // hide the suggestions
    autoSuggestViewController.hideSuggestions()
    
    return true
  }
  
  
  // MARK: W3AutoSuggestResultsViewControllerDelegate
  
  
  /// instructs the suggestions view on a good place to position itself
  func suggestionsLocation(preferedHeight: CGFloat) -> CGRect {
    var origin = frame.origin
    origin.y += frame.size.height + W3WSettings.componentsTableTopMargin
    
    let size = CGSize(width: frame.size.width, height: preferedHeight)
    
    return CGRect(origin: origin, size: size)
  }
  
  
  /// tells the suggestions view a good place for the error notice
  func errorLocation(preferedHeight: CGFloat) -> CGRect {
    var f = frame
    f.origin.y += f.size.height
    f.size.height = preferedHeight
    
    return f
  }
  

  
  /// gives the suggestions view self's view so it can place itself on it
  func getParentView() -> UIView {
    return self
  }
  
  
  /// returns the text currently being displayed
  func getCurrentText() -> String? {
    return text
  }
  

  /// replaces the text in the text field
  func replace(text: String) {
    DispatchQueue.main.async {
      self.text = text
    }
  }

  
  // MARK: UITextFieldDelegate
  
  
  /// called when the text field contents change
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    //addressSelected(self.text ?? "")
    //resignFirstResponder()
    
    if let words = self.text {
      if autoSuggestViewController.autoSuggestDataSource.is3wa(text: words) {
        DispatchQueue.main.async {
          if self.autoSuggestViewController.autoSuggestDataSource.isInKnownAddressList(text: words) {
            self.suggestionSelected(W3WApiSuggestion(words: words))
            self.textChanged(words)
            self.resignFirstResponder()
            self.autoSuggestViewController.hideSuggestions()
            //self.text = ""
          }
        }
      }
    }
    
    return false
  }
  
}
