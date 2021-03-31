//
//  File.swift
//
//
//  Created by Dave Duprey on 04/07/2020.
//

import Foundation
import UIKit
import W3WSwiftApi
//import W3WSwiftComponents


/// protocol for talking to the textfield, either a W3WAutosuggestTextField, or W3WAutosuggestSearcController at this point
protocol W3AutoSuggestResultsViewControllerDelegate {
  func suggestionsLocation(preferedHeight: CGFloat) -> CGRect
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
class W3WAutoSuggestResultsViewController: UITableViewController, W3WAutoSuggestDataSourceDelegate, W3WMicrophoneViewControllerDelegate, W3WOptionAcceptorProtocol {
  
  // the text field's conform to this so we can send updates to them
  var delegate: W3AutoSuggestResultsViewControllerDelegate?
  
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
  
  var cellHeight:CGFloat = W3WSettings.componentsTableCellHeight
  var maxTableHeight:CGFloat = W3WSettings.componentsMaxTableHeight
  
  // MARK: Initialization
  
  
  /// sets up the UI
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    tableView.separatorStyle = .singleLineEtched
    tableView.separatorColor = W3WSettings.componentsSeparatorColor
    
    tableView.layer.borderWidth = 0.5
    tableView.layer.borderColor = W3WSettings.componentsBorderColor.cgColor
  }


  
  // MARK: Acessors

  
  /// sets the API or SDK and initializes the datasource for making API calls and updating suggestions
  func set(w3w: W3WProtocolV3) {
    autoSuggestDataSource = W3AutoSuggestDataSource()
    autoSuggestDataSource.set(w3w: w3w)
    autoSuggestDataSource.delegate = self
    self.tableView.dataSource = autoSuggestDataSource
    
    configureTableView()
  }
  
  
  /// assigns an array of options to use on autosuggest calls
  /// - Parameters:
  ///     - options: an array of W3WOption
  func set(options: [W3WOption]) {
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
  
  
  
  // MARK: UITableViewDelegate
  

  /// called when the user slects a cell
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let datasource = self.tableView.dataSource as? W3AutoSuggestDataSource {
      datasource.update(rowSelected: indexPath.row)
    }
  }
  
  
  /// sets the cell height
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return cellHeight
  }
  
  
  
  // MARK: W3AutoSuggestDataSource Pass Through
  
  
  /// handles changes to the text for the text field, and lets caller knwo if the new input is allowed or not
  func textChanged(currentText:String?, additionalText:String?, newTextPosition:NSRange) -> Bool {
    return autoSuggestDataSource.textChanged(currentText: currentText, additionalText: additionalText, newTextPosition: newTextPosition)
  }
  
  
  /// formats input text
  func groom(text: String?) -> String? {
    highlightCellOnTextMatch()
    return autoSuggestDataSource.groom(text: text)
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
    DispatchQueue.main.async {
      let frame = self.delegate?.errorLocation(preferedHeight: self.cellHeight) ?? CGRect.zero //.getParentView().frame ?? CGRect.zero
      
      if self.didYouMeanView == nil {
        self.didYouMeanView = W3WHintView(frame: frame)

        self.didYouMeanView?.onTapped = {
          self.replace(text: didYouMean)
          self.didYouMeanView?.isHidden = true
        }
        
        let parent = self.getParentViewController()
        if let v = self.didYouMeanView {
          parent.view.insertSubview(v, belowSubview: parent.view)
        }
      }

      self.didYouMeanView?.isHidden = false
      self.didYouMeanView?.set(title: W3WSettings.didYouMeanText, hint: W3WAddress.ensureSlashes(text: didYouMean) ?? NSAttributedString())
    }
  }
  
  
  /// replaces the text in the text field
  func replace(text: String) {
    delegate?.replace(text: text)
  }
  
  //MARK: View Stuff
  
  
  /// gets the parent's view controller for presenting the table, crashes the app if there is no parent
  func getParentViewController() -> UIViewController {
    let parent = delegate?.getParentView().parentViewController
    
    assert(parent != nil, "W3AutoSuggestResultsViewControllerDelegate not assigned to W3AutoSuggestResultsViewController, or getParentViewController() is not returning a UIView!")
    
    return parent!
  }
  
  
  /// returns the ideal location for the suggestioins table
  func getSuggestionTableOrigin() -> CGPoint {
    return delegate?.suggestionsLocation(preferedHeight: 0.0).origin ?? CGPoint.zero
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
    
    DispatchQueue.main.async {
      self.tableView?.frame = self.delegate?.suggestionsLocation(preferedHeight: 0.0) ?? CGRect.zero
    }
  }
  
  
  // MARK: Error view
  
  
  /// displays a warning
  func set(warning: String?) {
    let attributes = [NSAttributedString.Key.foregroundColor : W3WSettings.componentsWarningTintColor]
    set(warning: warning == nil ? nil : NSAttributedString(string: warning ?? "?", attributes: attributes))
  }
  
  
  /// displays a formatted text warning
  func set(warning: NSAttributedString?) {
    showNoticeView(message: warning, tint: W3WSettings.componentsWarningTintColor)
  }
  

  /// displays an error
  func set(error: String?) {
    let attributes = [NSAttributedString.Key.foregroundColor : W3WSettings.componentsErrorTintColor]
    set(error: error == nil ? nil : NSAttributedString(string: error ?? "?", attributes: attributes))
  }
  
  
  /// displays a formatted text error
  func set(error: NSAttributedString?) {
    showNoticeView(message: error, tint: W3WSettings.componentsErrorTintColor)
  }
  
  
  /// shows a view contianing a text message
  func showNoticeView(message: NSAttributedString?, tint: UIColor = W3WSettings.componentsErrorTintColor) {
    DispatchQueue.main.async {
      let frame = self.delegate?.errorLocation(preferedHeight: 32.0) ?? CGRect.zero //.getParentView().frame ?? CGRect.zero

      if self.errorView == nil {
        self.errorView = W3WTextErrorView(frame: frame)

        let parent = self.getParentViewController()
        if let v = self.errorView {
          parent.view.insertSubview(v, belowSubview: parent.view)
        }
      }

      self.errorView?.frame = frame
      self.errorView?.tintColor = tint
      
      // if there is a message, unhide the view and make it transparent to begin with and animate it to opacity
      if let e = message {
        self.errorView?.alpha = 0.0
        self.errorView?.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
          self.errorView?.set(error: e)
          self.errorView?.alpha = 1.0
          
        // on completion of the animation, start a timer to make it dissapear
        }, completion: { value in
          DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.showNoticeView(message: nil)
          }
        })
        
      // if there is no message, then fade out, animating opacity to zero then hide the view upon completion
      } else {
        self.errorView?.alpha = 1.0
        UIView.animate(withDuration: 0.3, animations: {
          self.errorView?.alpha = 0.0
        }, completion: { value in
          self.errorView?.isHidden = true
        })
      }
    }
  }

  
  // MARK: Suggestions view

  
  /// highlight any cell that is displaying these words
  func highlightCellOnTextMatch() {
    DispatchQueue.main.async {
      if let words = self.delegate?.getCurrentText() {
        for cell in self.tableView.visibleCells {
          if let c = cell as? W3WSuggestionTableViewCell {
            c.set(highlight: c.threeWordAddressText?.address == words)
          }
        }
      }
    }
  }
  
  
  /// show the suggestions view
  func showSuggestions() {

    set(error: NSAttributedString?(nil))

    DispatchQueue.main.async {
            
      self.tableView.reloadData()
      
      // this doesn't show suggestions for uisearchcontroller
      if let _ = self.delegate?.getParentView() as? W3WAutoSuggestTextField {
        let parent = self.getParentViewController()
        if let st = self.tableView {
          parent.view.insertSubview(st, aboveSubview: parent.view)
        }
        
        if let _ = self.delegate?.getParentView().frame {
          UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: { () -> Void in
            self.tableView?.frame = self.delegate?.suggestionsLocation(preferedHeight: min(CGFloat(((self.tableView.dataSource as? W3AutoSuggestDataSource)?.suggestions.count) ?? 0) * self.cellHeight, self.maxTableHeight)) ?? CGRect.zero
          }, completion: { (finish) -> Void in
          })
        }
      }
      
    }
  }
  
  
  /// hide the suggestion view
  func hideSuggestions() {
    
    DispatchQueue.main.async {
      self.tableView.reloadData()
      
      if let _ = self.delegate?.getParentView() as? W3WAutoSuggestTextField {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: { () -> Void in
          self.tableView?.frame = self.delegate?.suggestionsLocation(preferedHeight: 0.0) ?? CGRect.zero
        }, completion: { (didFinish) -> Void in
          self.tableView?.removeFromSuperview()
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
    
    // only W3WAutoSuggestTextField can showMicrophoneInTextField() for now
    if let _ = self.delegate?.getParentView() as? W3WAutoSuggestTextField {
      if showMicInTextField { //}, #available(iOS 13.0, *) {
        showMicrophoneInTextField()
      } else {
        showMicInOverlay()
      }
    } else {
      // W3WAutoSuggestSearchController can not showMicrophoneInTextField() yet
      showMicInOverlay()
    }
    
  }
  
  
  //
  func showMicInOverlay() {
    if UIDevice.current.userInterfaceIdiom == .pad {
      showMicrophoneForiPad()
    } else {
      showMicrophoneForiPhone()
    }
  }
  
  
  func showMicrophoneForiPad() {
    DispatchQueue.main.async {
      if !self.isShowingMicrophone {
        self.isShowingMicrophone = true
        if let mic = self.microphoneViewController {
          let popover = UIPopoverPresentationController(presentedViewController: mic, presenting: self)
          popover.permittedArrowDirections = .up
          popover.sourceView = self.getParentViewController().view
          self.present(mic, animated: true) {
            if let datasource = self.tableView.dataSource as? W3AutoSuggestDataSource {
              datasource.startListening()
            }
          }
        }
      }
    }
  }
  
  
  func showMicrophoneInTextField() {
    DispatchQueue.main.async {
      if !self.isShowingMicrophone {
        self.isShowingMicrophone = true
        if let mic = self.microphoneViewController {
          if let textFieldView = self.delegate?.getParentView() as? W3WAutoSuggestTextField {
            mic.set(tinyMode: true)
            let sizeFactor = CGFloat(3.0)
            mic.view.frame = CGRect(x: 0.0, y: 0.0, width: textFieldView.frame.height * sizeFactor, height: textFieldView.frame.height * sizeFactor)
            //mic.view.center = CGPoint(x: textFieldView.frame.width - textFieldView.frame.height / 2.0, y: textFieldView.frame.height / 2.0)
            if W3WSettings.leftToRight {
              mic.view.center = textFieldView.rightView?.center ?? CGPoint(x: textFieldView.frame.width - textFieldView.frame.height / 2.0, y: textFieldView.frame.height / 2.0)
            } else {
              mic.view.center = textFieldView.leftView?.center ?? CGPoint(x: textFieldView.frame.width - textFieldView.frame.height / 2.0, y: textFieldView.frame.height / 2.0)
            }
            textFieldView.clipsToBounds = true
            textFieldView.addSubview(mic.view)
            if let datasource = self.tableView.dataSource as? W3AutoSuggestDataSource {
              datasource.startListening()
            }
          }
        }
      }
    }
  }
  
  
  func showMicrophoneForiPhone() {
    DispatchQueue.main.async {
      
      if !self.isShowingMicrophone {
        self.isShowingMicrophone = true
        //self.findParent()
        
        let parent = self.getParentViewController()
        
        var height = CGFloat(parent.view.frame.size.width)
        var startingPoint = CGPoint(x: 0.0, y: parent.view.frame.size.height)
        var endingPoint = CGPoint(x: 0.0, y: parent.view.frame.size.height - height)
        var viewSize = CGSize(width: parent.view.frame.size.width, height: height)
        
        if UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight {
          height = CGFloat(parent.view.frame.size.height * 0.8)
          startingPoint = CGPoint(x: parent.view.frame.size.width * 0.25, y: parent.view.frame.size.height)
          endingPoint = CGPoint(x: parent.view.frame.size.width * 0.25, y: parent.view.frame.size.height - height)
          viewSize = CGSize(width: parent.view.frame.size.width / 2.0, height: height)
        }
        
        if let mic = self.microphoneViewController {
          self.microphoneViewController?.view.frame = CGRect(origin: startingPoint, size: viewSize)
          mic.view.layer.cornerRadius = 8.0
          parent.view.addSubview(mic.view)
        }
        
        if var parentFrame = self.delegate?.getParentView().frame {
          UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: { () -> Void in
            parentFrame.size.height = 300.0
            self.microphoneViewController?.view.frame = CGRect(origin: endingPoint, size: viewSize)
          }, completion: { (finish) -> Void in
            if let datasource = self.tableView.dataSource as? W3AutoSuggestDataSource {
              datasource.startListening()
            }
          })
        }
      }
    }
  }
  
  
  func hideMicrophone() {
    if UIDevice.current.userInterfaceIdiom == .pad {
      hideMicrophoneForiPad()
    } else {
      hideMicrophoneForiPhone()
    }
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
      
      DispatchQueue.main.async {
        let parent = self.getParentViewController()
        let height = CGFloat(parent.view.frame.size.width)
        let endingPoint = CGPoint(x: 0.0, y: parent.view.frame.size.height)
        //let startingPoint = CGPoint(x: 0.0, y: parent.view.frame.size.height - height)
        let viewSize = CGSize(width: parent.view.frame.size.width, height: height)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: { () -> Void in
          self.microphoneViewController?.view.frame = CGRect(origin: endingPoint, size: viewSize)
        }, completion: { (didFinish) -> Void in
          self.microphoneViewController?.view.removeFromSuperview()
        })
      }
    }
  }
  
  
  // MARK: W3MicrophoneViewControllerDelegate
  
  /// Microphone view controller close button pressed
  func closeButtonPressed() {
    self.autoSuggestDataSource.stopListening()
    self.hideMicrophone()
  }
  
  func voiceButtonPressed() {
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


