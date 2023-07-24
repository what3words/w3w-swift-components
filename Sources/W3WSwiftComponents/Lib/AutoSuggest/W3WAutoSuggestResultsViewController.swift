//
//  File.swift
//
//
//  Created by Dave Duprey on 04/07/2020.
//
#if !os(macOS) && !os(watchOS)

import Foundation
import UIKit
import W3WSwiftApi


/// protocol for talking to the textfield, either a W3WAutosuggestTextField, or W3WAutosuggestSearcController at this point
public protocol W3AutoSuggestResultsViewControllerDelegate {
  func manageSuggestionView() -> Bool
  func suggestionsLocation(preferedHeight: CGFloat, spacing: CGFloat?) -> CGRect
  func errorLocation(preferedHeight: CGFloat) -> CGRect
  func getParentView() -> UIView
  func getCurrentText() -> String?
  func update(suggestions: [W3WSuggestion])
  func update(selected: W3WSuggestion)
  func update(error: W3WAutosuggestComponentError)
  func update(valid3wa: Bool)
  func replace(text: String)
}


/// presents W3WSuggestions to the user for them to choose one
public class W3WAutoSuggestResultsViewController: UITableViewController, W3WAutoSuggestDataSourceDelegate, W3WMicrophoneViewControllerDelegate, W3WOptionAcceptorProtocol {
  
  // the text field's conform to this so we can send updates to them
  public var delegate: W3AutoSuggestResultsViewControllerDelegate?
  
  /// shows the microphone inside the text field (only works for W3WTextField for now)
  var showMicInTextField = true
  
  /// indicates if free form text is being used in text field, or if it is only allowing w3w characters
  private var freeformText = true
  
  /// this is the data model for this component, handling w3w, formatting text, and providing suggestions
  var autoSuggestDataSource: W3AutoSuggestDataSource!
  
  /// the view to display the microphone if voice is enabled
  var microphoneViewController: W3WMicrophoneViewController?
  
  /// the view for displaying an error
  var errorView: W3WTextErrorView?
  
  /// the view for the "did you mean" box
  var didYouMeanView: W3WHintView?
  
  /// error for the user that something technical has gone wrong, implement update(error:) to catch the W3WError with detials, this can be changed to any text you like
  var technicalErrorString = W3WSettings.technicalErrorText

  /// error for the user that no good answer could be found, implement update(error:) to catch the W3WError with detials, this can be changed to any text you like
  var apiErrorString       = W3WSettings.apiErrorText

  /// indicates if the microphone is showing
  var isShowingMicrophone  = false
  
  /// ensures this view is infront of all sibling views, set to true if suggestions are appearing underneath other views
  var keepOnTop = false
  
  var cellHeight:CGFloat = W3WSettings.componentsTableCellHeight
  var maxTableHeight:CGFloat = W3WSettings.componentsMaxTableHeight
  
  // MARK: Initialization
  
  
  /// sets up the UI
  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    #if targetEnvironment(macCatalyst)
    tableView.separatorStyle = .singleLine
    #else
    if #available(iOS 11.0, *) {
      tableView.separatorStyle = .singleLine
    } else {
      tableView.separatorStyle = .singleLineEtched
    }
    #endif
    tableView.layer.borderWidth = 1.0
    updateColours()
  }


  
  // MARK: Acessors

  
  /// sets the API or SDK and initializes the datasource for making API calls and updating suggestions
  public func set(_ w3w: W3WProtocolV3) {
    autoSuggestDataSource = W3AutoSuggestDataSource()
    autoSuggestDataSource.set(w3w: w3w)
    autoSuggestDataSource.delegate = self
    self.tableView.dataSource = autoSuggestDataSource
    
    configureTableView()
  }
  
  
  /// assigns an array of options to use on autosuggest calls
  /// - Parameters:
  ///     - options: an array of W3WOption
  public func set(options: [W3WOption]) {
    autoSuggestDataSource?.set(options: options)
  }
  
  
  /// adds an option to the option list, replaces any existing options of the same kind
  /// - Parameters:
  ///     - options: an array of W3WOption
  func add(option: W3WOption) {
    autoSuggestDataSource?.add(option: option)
  }
  
  
  /// tells the component to use convertToCoordinates to retrieve lat/long
  /// - Parameters:
  ///     - includeCoordinates: if true, then this will use convertToCoordinates to return lat/long for every suggestion (calls will return W3WSquare instead of W3WSuggestion)
  func set(includeCoordinates: Bool) {
    autoSuggestDataSource?.set(includeCoordinates: includeCoordinates)
  }
  
  
  /// tells us if we are allowing any characters into the text field or only allowing w3w letters and separators
  /// - Parameters:
  ///     - freeformText: true tells us if we are allowing any characters into the text field and not only allowing w3w letters and separators
  func set(freeformText: Bool) {
    self.freeformText = freeformText
    autoSuggestDataSource?.set(freeformText: freeformText)
  }

  
  /// lets caller know if this supports voice input or not
  func supportsVoice() -> Bool {
    return autoSuggestDataSource?.supportsVoice() ?? false
  }
  
  
  public func set(darkModeSupport: Bool) {
    autoSuggestDataSource.disableDarkmode = !darkModeSupport
    
    if #available(iOS 13.0, *) {
      overrideUserInterfaceStyle = darkModeSupport ? .unspecified : .light
      
      for cell in tableView.visibleCells {
        if let c = cell as? W3WSuggestionViewProtocol {
          c.set(darkModeSupport: darkModeSupport)
        }
      }
    }
    
    updateColours()
  }

  
  /// update the colours
  func updateColours() {
    tableView.separatorColor = W3WSettings.color(named: "SeparatorColor", forMode: autoSuggestDataSource.disableDarkmode ? .light : W3WColorScheme.colourMode)
    tableView.layer.borderColor = W3WSettings.color(named: "BorderColor", forMode: autoSuggestDataSource.disableDarkmode ? .light : W3WColorScheme.colourMode).cgColor
  }
  
  

  func isValid3wa(text: String) -> Bool {
    return autoSuggestDataSource.isInKnownAddressList(text: text)
  }
  
  
  // MARK: UITableViewDelegate
  

  /// called when the user slects a cell
  override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let datasource = self.tableView.dataSource as? W3AutoSuggestDataSource {
      datasource.update(rowSelected: indexPath.row)
    }
  }
  
  
  /// sets the cell height
  override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return cellHeight
  }
  
  
  
  // MARK: W3AutoSuggestDataSource Pass Through
  
  
  /// handles changes to the text for the text field, and lets caller know if the new input is allowed or not
  func textChanged(currentText:String?, additionalText:String?, newTextPosition:NSRange) -> Bool {
    self.didYouMeanView?.isHidden = true
    return autoSuggestDataSource?.textChanged(currentText: currentText, additionalText: additionalText, newTextPosition: newTextPosition) ?? false
  }
  
  
  /// formats input text
  func groom(text: String?) -> String? {
    highlightCellOnTextMatch()
    return autoSuggestDataSource?.groom(text: text) ?? text
  }
  
  
  public func updateSuggestions(text: String) {
    autoSuggestDataSource.updateSuggestions(text: text)
  }
  
  
  // MARK: W3AutoSuggestDataSourceDelegate
  
  
  /// called when new suggestioins are available
  func update(suggestions: [W3WSuggestion]) {
    if self.isShowingMicrophone {
      autoSuggestDataSource.stopListening()
      hideMicrophone()
    }

    delegate?.update(suggestions: suggestions)
    
    if suggestions.count > 0 {
      showSuggestions()
    } else {
      hideSuggestions()
    }

    highlightCellOnTextMatch()
  }
  
  
  /// called when the user chooses a suggestion
  func update(selected: W3WSuggestion) {
    delegate?.update(selected: selected)
  }
  
  
  /// notifies when and if the address in the text field is a known three word address
  func update(valid3wa: Bool) {
    delegate?.update(valid3wa: valid3wa)
  }
  
  
  /// called when an error is found
  func update(error: W3WAutosuggestComponentError) {
    microphoneViewController?.set(engaged: false)
    microphoneViewController?.set(errorText: String(describing: error))
    
    // divide all possible errors into either technical problems, or an error about the input given to the API, the detailed W3WError enum can be obtained with the updateError closue of the main textfield class
    switch error {
    case .apiError(let e):
      if e == .invalidKey || e == .missingKey || e == .badConnection {
        set(error: technicalErrorString)
      } else {
        set(error: apiErrorString)
      }
    case .noValidAdressFound:
      set(error: apiErrorString)
    default:
      set(error: technicalErrorString)
    }
    
    delegate?.update(error: error)
    
    if showMicInTextField {
      hideMicrophone()
    }
  }

  
  func update(didYouMean: String) {
    DispatchQueue.main.async { [weak self] in
      let frame = self?.delegate?.errorLocation(preferedHeight: self?.cellHeight ?? W3WSettings.componentsTableCellHeight) ?? .zero
      
      if self?.didYouMeanView == nil {
        self?.didYouMeanView = W3WHintView(frame: frame)

        // get the view
        if let parentView = self?.delegate?.getParentView() {
          if let dymv = self?.didYouMeanView {
            // if it needs to be pushed to the front
            if self?.keepOnTop ?? false {
              parentView.bringSubviewToFront(dymv)
            }
            
            // add to view
            parentView.addSubview(dymv)
          }
        }
      }

      // add the tap handler
      self?.didYouMeanView?.onTapped = {
        self?.replace(text: didYouMean)
        self?.didYouMeanView?.isHidden = true
        self?.autoSuggestDataSource.updateSuggestions(text: didYouMean)
      }
      
      if let dymv = self?.didYouMeanView {
        //dymv.frame = self?.delegate?.suggestionsLocation(preferedHeight: dymv.frame.height, spacing: 0.0) ?? .zero
        dymv.frame = self?.delegate?.errorLocation(preferedHeight: dymv.frame.height) ?? .zero
        dymv.isHidden = false
        dymv.set(title: W3WSettings.didYouMeanText, hint: W3WFormatter.ensureSlashes(text: didYouMean) ?? NSAttributedString())
      }
    }
  }
  
  
  /// replaces the text in the text field
  func replace(text: String) {
    delegate?.replace(text: text)
  }
  
  
  //MARK: View Stuff
  
  
  /// returns the ideal location for the suggestioins table
  func getSuggestionTableOrigin() -> CGPoint {
    return delegate?.suggestionsLocation(preferedHeight: 0.0, spacing: W3WSettings.componentsTableTopMargin).origin ?? CGPoint.zero
  }
  
  
  /// sets up the table view
  func configureTableView() {
    tableView.register(W3WSuggestionTableViewCell.self, forCellReuseIdentifier: W3WSuggestionTableViewCell.cellIdentifier)
    
    tableView.delegate = self
    tableView.backgroundColor = .clear
    tableView.separatorStyle = .singleLine
    tableView.separatorColor = .gray
    tableView.separatorInset = .zero
    tableView.bounces = false
    
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    
    if let _ = self.delegate?.getParentView() as? W3WAutoSuggestTextField {
      DispatchQueue.main.async {
        self.tableView?.frame = self.delegate?.suggestionsLocation(preferedHeight: 0.0, spacing: W3WSettings.componentsTableTopMargin) ?? CGRect.zero
      }
    }
  }
  
  
  public func updateGeometry() {
    // update the postion of the tableview if this is a textfield
    if let _ = self.delegate?.getParentView() as? W3WAutoSuggestTextField {
      tableView?.frame = self.delegate?.suggestionsLocation(preferedHeight: min(CGFloat(((self.tableView.dataSource as? W3AutoSuggestDataSource)?.suggestions.count) ?? 0) * self.cellHeight, self.maxTableHeight), spacing: W3WSettings.componentsTableTopMargin) ?? CGRect.zero
    }
    
    if !(errorView?.isHidden ?? true) {
      errorView?.frame = self.delegate?.errorLocation(preferedHeight: errorView?.frame.height ?? 32.0) ?? CGRect.zero
    }
    
    // update the position of the hint view if visible
    if !(didYouMeanView?.isHidden ?? true) {
      didYouMeanView?.frame = self.delegate?.errorLocation(preferedHeight: didYouMeanView?.frame.height ?? self.cellHeight) ?? CGRect.zero
    }
    
    positionMicrophoneForiPhone()
  }
  
  
  // MARK: Error view
  
  
  /// displays a warning
  func set(warning: String?) {
    let attributes = [NSAttributedString.Key.foregroundColor : W3WSettings.color(named: "WarningTextColor")]
    set(warning: warning == nil ? nil : NSAttributedString(string: warning ?? "?", attributes: attributes))
  }
  
  
  /// displays a formatted text warning
  func set(warning: NSAttributedString?) {
    showNoticeView(message: warning, textColor: W3WSettings.color(named: "WarningTextColor"), backgroundColor: W3WSettings.color(named: "WarningBackground"))
  }
  

  /// displays an error
  func set(error: String?) {
    let attributes = [NSAttributedString.Key.foregroundColor : W3WSettings.color(named: "ErrorTextColor")]
    set(error: error == nil ? nil : NSAttributedString(string: error ?? "?", attributes: attributes))
  }
  
  
  /// displays a formatted text error
  func set(error: NSAttributedString?) {
    showNoticeView(message: error, textColor: W3WSettings.color(named: "ErrorTextColor"), backgroundColor: W3WSettings.color(named: "ErrorBackground"))
  }
  
  
  /// shows a view contianing a text message
  func showNoticeView(message: NSAttributedString?, textColor: UIColor = W3WSettings.color(named: "ErrorTextColor"), backgroundColor: UIColor = W3WSettings.color(named: "ErrorBackground")) {
    DispatchQueue.main.async { [weak self] in
      let frame = self?.delegate?.errorLocation(preferedHeight: 32.0) ?? CGRect.zero

      if self?.errorView == nil {
        self?.errorView = W3WTextErrorView(frame: frame)

        // get the view
        if let parentView = self?.delegate?.getParentView() {
          if let ev = self?.errorView {
            // if it needs to be pushed to the front
            if self?.keepOnTop ?? false {
              parentView.bringSubviewToFront(ev)
            }
            
            // add to view
            parentView.addSubview(ev)
          }
        }
      }

      self?.errorView?.frame = frame
      self?.errorView?.tintColor = textColor
      self?.errorView?.backgroundColor = backgroundColor

      // if there is a message, unhide the view and make it transparent to begin with and animate it to opacity
      if let e = message {
        self?.errorView?.alpha = 0.0
        self?.errorView?.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
          self?.errorView?.set(error: e)
          self?.errorView?.alpha = 1.0
          
        // on completion of the animation, start a timer to make it dissapear
        }, completion: { value in
          DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self?.showNoticeView(message: nil)
          }
        })
        
      // if there is no message, then fade out, animating opacity to zero then hide the view upon completion
      } else {
        self?.errorView?.alpha = 1.0
        UIView.animate(withDuration: 0.3, animations: {
          self?.errorView?.alpha = 0.0
        }, completion: { value in
          self?.errorView?.isHidden = true
        })
      }
    }
  }

  
  // MARK: Suggestions view

  
  /// highlight any cell that is displaying these words
  func highlightCellOnTextMatch() {
    DispatchQueue.main.async {
      if let words = self.delegate?.getCurrentText() {
        if self.autoSuggestDataSource.suggestions.count > 0 {
          for cell in self.tableView.visibleCells {
            if let c = cell as? W3WSuggestionTableViewCell {
              c.set(highlight: W3WAddress.equal(w1: c.suggestion?.words ?? "", w2: words)) //c.suggestion?.words == words)
            }
          }
        }
      }
    }
  }
  
  
  /// show the suggestions view
  func showSuggestions() {
    DispatchQueue.main.async { [unowned self] in
      self.tableView.reloadData()

      // this checks is this object should manage suggestions view. For example uisearchcontroller manages the tableview itself
      if self.delegate?.manageSuggestionView() ?? false {
        
        // get the view
        if let parentView = self.delegate?.getParentView() {
          if let suggestionsView = self.tableView {
            suggestionsView.frame = self.delegate?.suggestionsLocation(preferedHeight: min(CGFloat(((self.tableView.dataSource as? W3AutoSuggestDataSource)?.suggestions.count) ?? 0) * self.cellHeight, self.maxTableHeight), spacing: W3WSettings.componentsTableTopMargin) ?? CGRect.zero
            
            // if it needs to be pushed to the front
            if self.keepOnTop {
              parentView.bringSubviewToFront(suggestionsView)
            }
            
            // add to view
            parentView.addSubview(suggestionsView)
          }
        }
      }
    }
  }
  
  
  /// hide the suggestion view
  func hideSuggestions() {
    
    DispatchQueue.main.async {
      self.tableView.reloadData()
      
      // this checks is this object should manage suggestions view. For example uisearchcontroller manages the tableview itself
      if self.delegate?.manageSuggestionView() ?? false {
        
        // animate the exit of the suggestions view
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: { () -> Void in
          self.tableView?.alpha = 0.0
          self.tableView?.frame = self.delegate?.suggestionsLocation(preferedHeight: 0.0, spacing: W3WSettings.componentsTableTopMargin) ?? CGRect.zero
        }, completion: { (didFinish) -> Void in
          self.tableView?.removeFromSuperview()
          self.tableView?.alpha = 1.0
        })
      }
    }
  }
  
  
  // MARK: Microphone View
  
  
  /// show the microphone
  func showMicrophone() {
    // assign the volume from the microphone to the microphone view, and the on/off to it as well
    if let datasource = self.tableView.dataSource as? W3AutoSuggestDataSource {
      if microphoneViewController == nil {
        microphoneViewController = W3WMicrophoneViewController()
        microphoneViewController?.delegate = self
      }
      
      datasource.volumeUpdate = { volume in
        self.microphoneViewController?.set(volume: CGFloat(volume))
      }
      
      datasource.listeningUpdate = { state in
        self.microphoneViewController?.set(engaged: state == .started)
        if state == .stopped {
          self.microphoneViewController?.set(volume: 0.0)
          //self.microphoneViewController?.set(engaged: false)
          if self.autoSuggestDataSource.suggestions.count > 0 {
            self.hideMicrophone()
          }
        }
      }
    }
    
    showMicInOverlay()
  }
  
  
  // choose which way to show mic
  func showMicInOverlay() {
    showMicrophoneForiPhone()
  }
  
  
  func showMicrophoneForiPad() {
    DispatchQueue.main.async {
      if !self.isShowingMicrophone {
        self.isShowingMicrophone = true
        if let mic = self.microphoneViewController {
          let popover = UIPopoverPresentationController(presentedViewController: mic, presenting: self)
          popover.permittedArrowDirections = .up
          popover.sourceView = self.delegate?.getParentView()  // self.getParentViewController().view
          self.present(mic, animated: true) {
            if let datasource = self.tableView.dataSource as? W3AutoSuggestDataSource {
              datasource.startListening()
            }
          }
        }
      }
    }
  }
  
    
  func showMicrophoneForiPhone() {
    DispatchQueue.main.async { [unowned self] in
      
      if !self.isShowingMicrophone {
        self.isShowingMicrophone = true
        
        if let parent = self.delegate?.getParentView() {  //self.getParentViewController()
          
          var height = CGFloat(parent.frame.size.width)
          var startingPoint = CGPoint(x: 0.0, y: parent.frame.size.height)
          //var endingPoint = CGPoint(x: 0.0, y: parent.frame.size.height - height)
          var viewSize = CGSize(width: parent.frame.size.width, height: height)
          
          if UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight {
            height = CGFloat(parent.frame.size.height * 0.8)
            startingPoint = CGPoint(x: parent.frame.size.width * 0.25, y: parent.frame.size.height)
            //endingPoint = CGPoint(x: parent.frame.size.width * 0.25, y: parent.frame.size.height - height)
            viewSize = CGSize(width: parent.frame.size.width / 2.0, height: height)
          }
          
          if let mic = self.microphoneViewController {
            self.microphoneViewController?.view.frame = CGRect(origin: startingPoint, size: viewSize)
            mic.view.layer.cornerRadius = 8.0
            if keepOnTop {
              parent.superview?.bringSubviewToFront(parent)
            }
            parent.addSubview(mic.view)
          }
          
          if var parentFrame = self.delegate?.getParentView().frame {
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: { () -> Void in
              parentFrame.size.height = 300.0
              self.microphoneViewController?.view.frame = self.microphoneFrame() // CGRect(origin: endingPoint, size: viewSize)
            }, completion: { (finish) -> Void in
              if let datasource = self.tableView.dataSource as? W3AutoSuggestDataSource {
                datasource.startListening()
              }
            })
          }
        }
      }
    }
  }
  
  
  func positionMicrophoneForiPhone() {
    if isShowingMicrophone {
      UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: { () -> Void in
        self.microphoneViewController?.view.frame = self.microphoneFrame()
      })
    }
  }
  
  
  func microphoneFrame() -> CGRect {
    if let parent = delegate?.getParentView().w3wParentViewController {
      return microphoneFrame(from: parent.view.frame)
    } else {
      return microphoneFrame(from: UIScreen.main.bounds)
    }
  }
  
  
  func microphoneFrame(from: CGRect) -> CGRect {
    var top    = from.height * 0.4
    var side   = 0.0
    
    if from.width > 470.0 {
      if UIDevice.current.userInterfaceIdiom == .phone {
        side = (from.width - 300.0) / 2.0
        if UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight {
          top = from.height * 0.1
        }
      } else {
        if UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight {
          side = from.width / 4.0
          top = from.height * 0.35
        } else {
          side = from.width / 8.0
        }
      }
    }

    let frame = from.inset(by: UIEdgeInsets(top: top, left: side, bottom: 0.0, right: side))
    
    return frame
  }
  
  
  func hideMicrophone() {
    hideMicrophoneForiPhone()
  }
  
  
  func hideMicrophoneForiPad() {
    if self.isShowingMicrophone {
      self.isShowingMicrophone = false
      
      DispatchQueue.main.async {
        self.microphoneViewController?.dismiss(animated: true)
        if self.showMicInTextField { 
          self.microphoneViewController?.view.removeFromSuperview()
        }
      }
    }
  }
  
  
  func hideMicrophoneForiPhone() {
    if self.isShowingMicrophone {
      self.isShowingMicrophone = false
      
      DispatchQueue.main.async { [unowned self] in
        if let parent = self.delegate?.getParentView() {
          let height = CGFloat(parent.frame.size.width)
          let endingPoint = CGPoint(x: 0.0, y: parent.frame.size.height)
          let viewSize = CGSize(width: parent.frame.size.width, height: height)
          
          UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: { () -> Void in
            self.microphoneViewController?.view.frame = CGRect(origin: endingPoint, size: viewSize)
          }, completion: { (didFinish) -> Void in
            self.microphoneViewController?.view.removeFromSuperview()
          })
        }
      }
    }
  }
  
  
  // MARK: W3MicrophoneViewControllerDelegate
  
  /// Microphone view controller close button pressed
  public func closeButtonPressed() {
    self.autoSuggestDataSource.stopListening()
    self.hideMicrophone()
  }
  
  public func voiceButtonPressed() {
    if self.autoSuggestDataSource.isListening() {
      self.autoSuggestDataSource.stopListening()
      microphoneViewController?.set(engaged: false)
      self.hideMicrophone()
    } else {
      microphoneViewController?.set(engaged: true)
      self.autoSuggestDataSource.startListening()
    }
  }
  
}


#endif
