//
//  W3WMicrophoneViewController.swift
//  CoordinatorTemplate
//
//  Created by Dave Duprey on 13/07/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//

import UIKit
import W3WSwiftApi


public protocol W3WMicrophoneViewControllerDelegate {
  func closeButtonPressed()
  func voiceButtonPressed()
}


open class W3WMicrophoneViewController: UIViewController {
  
  public var delegate: W3WMicrophoneViewControllerDelegate?
  
  public var microphone: W3WMicrophone?
  
  var closeButton: UIButton!
  var microphoneView: W3WMicrophoneView!
  var headerLabel: UILabel!
  var footerLabel: UILabel!
  var logoImage = UIImageView(image: UIImage(named: "logo", in: Bundle.module, compatibleWith: nil))
  
  var errorState = false
  
  let textSize:CGFloat = 20.0
  var tinyMode = false
  
  var closeButtonEnabled = false
  
  
  public func set(microphone: W3WMicrophone?) {
    self.microphone = microphone
  }
  
  
  public func set(tinyMode: Bool) {
    self.tinyMode = tinyMode
  }
  
  
  public override func viewWillAppear(_ animated: Bool) {
    self.view.backgroundColor = UIColor(red: 0.975, green: 0.975, blue: 0.975, alpha: 1.0)
    
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
  
  
  public override func viewDidDisappear(_ animated: Bool) {
    errorState = false
  }
  
  
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
  
  
  func largeModeSetup() {
    self.view.backgroundColor = UIColor(red: 0.975, green: 0.975, blue: 0.975, alpha: 1.0)
    
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
    headerLabel.textColor = UIColor.black
    headerLabel.font = UIFont.systemFont(ofSize: textSize, weight: .light)
    view.addSubview(headerLabel)
    
    if footerLabel == nil {
      footerLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: size, height: textSize))
    }
    footerLabel.center = CGPoint(x: size, y: self.view.frame.height - microphoneView.center.y / 3.0)
    footerLabel.textAlignment = .center
    footerLabel.textColor = UIColor.gray
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
  
  
  func tinyModeLayout() {
    let size = min(self.view.frame.size.width, self.view.frame.size.height)
    microphoneView.frame = CGRect(x: 0.0, y: 0.0, width: size, height: size)
    //let size = self.view.frame.size.width * 0.8
    //microphoneView.frame = CGRect(x: size / 2.0, y: size / 2.0, width: size, height: size)
    //microphoneView.center = CGPoint(x: self.view.frame.size.width / 2.0, y: self.view.frame.size.height / 2.0)
  }
  
  
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
  
  
  public override func viewWillLayoutSubviews() {
    if tinyMode {
      tinyModeLayout()
    } else {
      largeModeLayout()
    }
  }
  
  
  @objc func pressed() {
    delegate?.closeButtonPressed()
  }
  
  
  func setRecordingText() {
    if !errorState {
      headerLabel?.text = "Say a 3 word address"
      footerLabel?.text = ""
    }
  }
  
  
  func setPausedText() {
    if !errorState {
      headerLabel?.text = "Tap to speak"
      footerLabel?.text = "eg: ”limit.broom.flip“"
    }
  }
  
  
  public func set(errorText: String) {
    errorState = true
    set(engaged: false)
    headerLabel?.text = "Error"
    footerLabel?.text = errorText
  }
  
  
  func set(shadow: Bool) {
    DispatchQueue.main.async {
      if shadow {
        self.microphoneView?.layer.shadowColor = UIColor.darkGray.cgColor
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
  
  
  func set(engaged: Bool) {
    set(shadow: !engaged)
    microphoneView?.set(engaged: engaged)
    
    if engaged {
      setRecordingText()
    } else {
      setPausedText()
    }
  }
  
  
  public func set(volume: CGFloat) {
    microphoneView?.set(volume: volume)
  }
  
  
  func microphoneTapped() {
    errorState = false
    delegate?.voiceButtonPressed()
  }
  
  
  func update(microphoneState: W3WVoiceListeningState) {
    switch microphoneState {
    case .started:
      set(engaged: true)
    case .stopped:
      set(engaged: false)
    }
  }
  
}
