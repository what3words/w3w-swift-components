//
//  W3WMicrophoneViewController.swift
//  CoordinatorTemplate
//
//  Created by Dave Duprey on 13/07/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//
#if !os(macOS)

import UIKit
import W3WSwiftApi


public protocol W3WMicrophoneViewControllerDelegate {
  func closeButtonPressed()
  func voiceButtonPressed()
}


/// a viewcontroller for the W3WMicrophoneView
open class W3WMicrophoneViewController: UIViewController {
  
  // MARK: Vars
  
  /// delegate to return button events
  public var delegate: W3WMicrophoneViewControllerDelegate?
  
  /// the microphone for recording
  public var microphone: W3WMicrophone?
  
  /// close button for this viewcontroller
  var closeButton: UIButton!
  
  /// the view that shows the microphone icon
  var microphoneView: W3WMicrophoneView!
  
  /// header for top of a large format
  var headerLabel: UILabel!

  /// footer for bottom of a large format
  var footerLabel: UILabel!
  
  /// what3words logo for bottom of large format
  var logoImage = UIImageView(image: UIImage(named: "logo", in: Bundle.module, compatibleWith: nil))
  
  /// keep track of if this is in an error state
  var errorState = false
  
  /// text size is adjustable
  let textSize:CGFloat = 20.0
  
  /// if this is to be used in a small space then this should be true, otherwise if false all interface elements are shown
  var tinyMode = false
  
  /// indicates if the close button should be shown or not
  var closeButtonEnabled = false
  
  
    // MARK: Accessors
  
  
  /// set the microphone to use
  public func set(microphone: W3WMicrophone?) {
    self.microphone = microphone
  }
  
  
  /// if this is to be used in a small space then this should be true, otherwise if false all interface elements are shown
  public func set(tinyMode: Bool) {
    self.tinyMode = tinyMode
  }
  
  
  /// recording text
  func setRecordingText() {
    if !errorState {
      headerLabel?.text = "Say a 3 word address"
      footerLabel?.text = ""
    }
  }
  
  
  /// paused text
  func setPausedText() {
    if !errorState {
      headerLabel?.text = "Tap to speak"
      footerLabel?.text = "eg: ”limit.broom.flip“"
    }
  }
  
  
  /// error text
  public func set(errorText: String) {
    errorState = true
    set(engaged: false)
    headerLabel?.text = "Error"
    footerLabel?.text = errorText
  }
  
  
  /// background shadow
  func set(shadow: Bool) {
    DispatchQueue.main.async {
      if shadow {
        self.microphoneView?.layer.shadowColor = W3WSettings.color(named: "MicShadow").cgColor
        self.microphoneView?.layer.shadowOpacity = 0.25
        self.microphoneView?.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.microphoneView?.layer.shadowRadius = 1
      } else {
        self.microphoneView?.layer.shadowColor = UIColor.clear.cgColor
        self.microphoneView?.layer.shadowOpacity = 0
        self.microphoneView?.layer.shadowOffset = .zero // CGSize(width: 2.0, height: 2.0)
        self.microphoneView?.layer.shadowRadius = 0
      }
    }
  }
  
  
  /// switch design to recording or stopped
  func set(engaged: Bool) {
    set(shadow: !engaged)
    microphoneView?.set(engaged: engaged)
    
    if engaged {
      setRecordingText()
    } else {
      setPausedText()
    }
  }
  
  
  /// sets the volume of the microphone
  public func set(volume: CGFloat) {
    microphoneView?.set(volume: volume)
  }
  
  
  // MARK: UIViewController Stuff
  
  
  /// initiaize the views
  public override func viewWillAppear(_ animated: Bool) {
    self.view.backgroundColor = W3WSettings.color(named: "MicBackground")
    
    if microphoneView == nil {
      microphoneView = W3WMicrophoneView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.width), microphone: microphone)
    }
    
    logoImage.frame = CGRect(x: 0.0, y: 0.0, width: W3WSettings.componentsLogoSize, height: W3WSettings.componentsLogoSize)
    
    if tinyMode {
      tinyModeSetup()
    } else {
      largeModeSetup()
    }
    
    setRecordingText()

    microphoneView.set(engaged: microphone?.isRecording() ?? false)
  }
  
  
  /// reset when view disappears
  public override func viewDidDisappear(_ animated: Bool) {
    errorState = false
  }
  
  
  
  /// reorganize subviews
  public override func viewWillLayoutSubviews() {
    if tinyMode {
      tinyModeLayout()
    } else {
      largeModeLayout()
    }
  }
  

  
  // MARK: Layout
  
  /// setup for tiny mode
  func tinyModeSetup() {
    self.view.backgroundColor = .clear
    
    let size = min(self.view.frame.size.width, self.view.frame.size.height)
    microphoneView.frame = CGRect(x: 0.0, y: 0.0, width: size, height: size)
    microphoneView.backgroundColor = UIColor.clear
    microphoneView.set(engaged: true)
    microphoneView.tapped = { self.microphoneTapped() }
    view.addSubview(microphoneView)
    
    tinyModeLayout()
  }
  
  
  /// setup for large mode
  func largeModeSetup() {
    self.view.backgroundColor = W3WSettings.color(named: "MicBackground")
    
    let size = self.view.frame.size.width / 2.0
    microphoneView.frame = CGRect(x: size / 2.0, y: size / 2.0, width: size, height: size)
    microphoneView.backgroundColor = UIColor.clear
    microphoneView.set(engaged: true)
    microphoneView.tapped = { self.microphoneTapped() }
    view.addSubview(microphoneView)
    
    if headerLabel == nil {
      headerLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: size * 1.5, height: textSize))
    }
    headerLabel.center = CGPoint(x: size, y: microphoneView.center.y / 3.0)
    headerLabel.textAlignment = .center
    headerLabel.textColor = W3WSettings.color(named: "MicTextColor") 
    headerLabel.font = UIFont.systemFont(ofSize: textSize, weight: .light)
    view.addSubview(headerLabel)
    
    if footerLabel == nil {
      footerLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: size, height: textSize))
    }
    footerLabel.center = CGPoint(x: size, y: self.view.frame.height - microphoneView.center.y / 3.0)
    footerLabel.textAlignment = .center
    footerLabel.textColor = W3WSettings.color(named: "MicTextSecondary")
    footerLabel.font = UIFont.systemFont(ofSize: textSize * 0.8, weight: .light)
    footerLabel.minimumScaleFactor = 0.5
    footerLabel.adjustsFontSizeToFitWidth = true
    view.addSubview(footerLabel)
    
    view.addSubview(logoImage)
    logoImage.isHidden = true
    
    if closeButtonEnabled {
      if closeButton == nil {
        closeButton = UIButton(type: .custom)
      }
      closeButton.frame = CGRect(x: 0.0, y: 0.0, width: textSize, height: textSize)
      closeButton.setImage(W3WCloseIconView(frame: closeButton.frame).asImage(), for: .normal)
      closeButton.center = CGPoint(x: view.frame.size.width - textSize * 1.5, y: textSize * 1.5)
      closeButton.addTarget(self, action: #selector(self.pressed), for: .touchUpInside)
      view.addSubview(closeButton)
    }
    
    largeModeLayout()
  }
  
  
  /// layout for tiny mode
  func tinyModeLayout() {
    let size = min(self.view.frame.size.width, self.view.frame.size.height)
    microphoneView.frame = CGRect(x: 0.0, y: 0.0, width: size, height: size)
    //let size = self.view.frame.size.width * 0.8
    //microphoneView.frame = CGRect(x: size / 2.0, y: size / 2.0, width: size, height: size)
    //microphoneView.center = CGPoint(x: self.view.frame.size.width / 2.0, y: self.view.frame.size.height / 2.0)
  }
  
  
  /// layout for large mode
  func largeModeLayout() {
    let size = self.view.frame.size.width / 2.0
    microphoneView?.frame = CGRect(x: size / 2.0, y: size / 2.0, width: size, height: size)
    headerLabel?.center = CGPoint(x: size, y: microphoneView.center.y / 3.0)
    headerLabel?.textAlignment = .center
    footerLabel?.center = CGPoint(x: size, y: self.view.frame.height - microphoneView.center.y / 3.0)
    footerLabel?.textAlignment = .center
    closeButton?.frame = CGRect(x: 0.0, y: 0.0, width: textSize, height: textSize)
    closeButton?.center = CGPoint(x: view.frame.size.width - textSize * 1.5, y: textSize * 1.5)
    placeLogo()
  }
  

  /// only shows the logo if there is space
  func placeLogo() {
    // don't show logo if it will be patially covered
    let bottomOfLogo = CGPoint(x: view.frame.size.width / 2.0, y: view.frame.size.height - W3WSettings.componentsLogoSize * 1.5)
    if view == view.hitTest(bottomOfLogo, with: nil) && view.frame.contains(bottomOfLogo) {
      logoImage.isHidden = false
      logoImage.center = CGPoint(x: view.frame.size.width / 2.0, y: view.frame.size.height - W3WSettings.componentsLogoSize * 1.5)
    } else {
      logoImage.isHidden = true
    }
  }
  
  
  // MARK: Events
  
  
  /// called when the button is pressed
  @objc func pressed() {
    delegate?.closeButtonPressed()
  }
  
  
  /// microphone button tapped
  func microphoneTapped() {
    errorState = false
    delegate?.voiceButtonPressed()
  }
  
  
  /// react to microphone view events
  func update(microphoneState: W3WVoiceListeningState) {
    switch microphoneState {
    case .started:
      set(engaged: true)
    case .stopped:
      set(engaged: false)
    }
  }
  
}


#endif
