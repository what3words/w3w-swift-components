//
//  MicrophoneView.swift
//  UberApiTest
//
//  Created by Dave Duprey on 07/02/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//

import UIKit
import W3WSwiftApi
//import w3w_swift_voice_wrapper


// Should this go into w3w-swift-voice-wrapper?


@IBDesignable
open class W3WMicrophoneView: W3WVoiceIconView {
  
  // preset colours and radius, settable from Interface Builder
  @IBInspectable var micOnColor: UIColor   = UIColor(red: 0.810, green: 0.217, blue: 0.196, alpha: 1.0)
  @IBInspectable var micOffColor: UIColor  = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
  @IBInspectable var idealRadius: CGFloat = 40.0
  
  var microphone: W3WMicrophone?
  
  /// speed of the animation
  public var framesPerSecond = 30.0
  
  /// current volume shown in size of halo
  var volume:CGFloat        = 0.0
  
  /// the last set volume number, this is the value we animate towards
  var targetVolume: CGFloat = 0.0
  
  /// the maximum volume passed in so far
  var maxVolume:CGFloat     = 1.0
  
  /// the minimum volume passed in so far
  var minVolume:CGFloat     = 0.0
  
  /// indicates if the mic is engaged
  var engaged:Bool   = false
  
  /// timer to use to animate the fan getting larger or smaller inbetween calls to setVolume()
  var animationTimer: Timer?
  
  
  
  public init(microphone: W3WMicrophone?) {
    super.init(frame: CGRect(x: 0.0, y: 0.0, width: 64.0, height: 64.0))
    configure(microphone: microphone)
  }
  
  
  public init(frame: CGRect, microphone: W3WMicrophone?) {
    super.init(frame: frame)
    configure(microphone: microphone)
  }
  
  
  public required init?(coder: NSCoder, microphone: W3WMicrophone?) {
    super.init(coder: coder)
    configure(microphone: microphone)
  }
  
  
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  
  public func configure(microphone: W3WMicrophone?) {
    self.microphone = microphone
    
    microphone?.volumeUpdate = { volume in self.set(volume: CGFloat(volume)) }
    microphone?.listeningUpdate = { state in self.set(engaged: state == .started) }
    //microphone?.listeningUpdate.add({ state in self.set(engaged: state == .started) })
  }
  
  
  /// called when the user touches the center of the circle
  @objc override func tapHappened(recognizer: UITapGestureRecognizer) {
    
    // where did the user tap?
    let point = recognizer.location(in: self)
    
    // how far form the centre did the user tap?
    let centre = CGPoint(x:frame.size.width / 2.0, y:frame.size.height / 2.0)
    let xDist = centre.x - point.x
    let yDist = centre.y - point.y
    let distanceToCentre = sqrt((xDist * xDist) + (yDist * yDist))
    
    // if they tapped within the centre circle we call the clouse to tell anyone interested that the tap happened, and do a little animation for feedback
    if  distanceToCentre < chooseRadius() {
      tapped()
      if microphone?.isRecording() ?? false {
        microphone?.stop()
        self.set(engaged: false)
      } else {
        if let mic = microphone {
          mic.start()
          self.set(engaged: true)
        }
      }
      
    }
  }
  
  
  // MARK: Accessors
  
  
  /// set the microphone view in an 'on' or 'off' state
  /// - Parameters:
  ///     - engaged: true = engaged
  public func set(engaged: Bool) {
    self.engaged = engaged
    
    // if we are turing on, then start an animation timer
    if engaged {
      //animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/framesPerSecond, repeats: true) { timer in self.updateAnimation() }
      animationTimer = Timer.scheduledTimer(timeInterval: 1.0/framesPerSecond, target: self, selector: #selector(self.updateAnimation), userInfo: nil, repeats: true)
      
      // if we are turning off, then set volume to zero and stop the animation timer
    } else {
      self.volume = 0.0
      self.targetVolume = 0.0
      animationTimer?.invalidate()
      animationTimer = nil
    }
    
    // update the display
    DispatchQueue.main.async {
      self.setNeedsDisplay()
    }
  }
  
  
  /// updates the microphone view by inching the shown volume towards the target volume, this is called by the timer and incrementally moves the halo around
  @objc func updateAnimation() {
    volume = volume + 0.3 * (targetVolume - volume)
    DispatchQueue.main.async {
      self.setNeedsDisplay()
    }
  }
  
  
  /// sets the volume level to display.  this will automatically adjust for range.
  /// you can send in values from 0 -> 1, or -1000.0 -> 1000.0 or whatever and
  /// it will figure out the best place to show the halo
  /// - Parameters:
  ///     - v: the volume to show, can be a number of any value, the view will sort out how to display it relative to other values given to this function
  public func set(volume: CGFloat) {
    
    // remember the min and max values
    if volume > maxVolume { maxVolume = volume }
    if volume < minVolume { minVolume = volume }
    
    maxVolume = maxVolume * 0.95
    if maxVolume < 0.1 {
      maxVolume = 0.1
    }
    
    if maxVolume == minVolume { maxVolume += 0.1 } // never end up with devide by zero (see next line)
    
    // figure out a good number between zero and one to represent the current volume, given the max values
    let range = maxVolume - minVolume
    let normalizedVolume = (volume - minVolume) / (range - minVolume)
    
    // the targetVolume it where the animation will try to get to (by incrementing 'self.volume'
    targetVolume = self.engaged ? normalizedVolume : 0.0
    
    // update the animation
    updateAnimation()
  }
  
  
  
  
  // MARK: Drawing
  
  
  /// gets a radius for the innermost circle, ideally at the set size, but smaller if that doesn't fit
  func chooseRadius() -> CGFloat {
    var radius = idealRadius
    
    // if ideaRadius is too small, use a quarter of the smallest view size
    if idealRadius > min(frame.size.width, frame.size.height) / 4.0 {
      radius = min(frame.size.width, frame.size.height) / 4.0
    }
    
    return radius
  }
  
  
  /// draw the microphone
  public override func draw(_ rect: CGRect) {
    
    // gets a radius for the innermost circle
    let radius = chooseRadius()
    
    // find the centre
    let centre = CGPoint(x:rect.size.width / 2.0, y:rect.size.height / 2.0)
    
    // figure out how much room there is for the halo
    var maxRadius = min(frame.size.width, frame.size.height) / 2.0
    if maxRadius > 216.0 {
      maxRadius = 216.0
    }
    let fanRoom = maxRadius - radius
    
    let fanSpread = volumeToFanSpread()
    
    // draw the four circles and the icon on top
    circle(centre: centre, radius: radius + fanRoom * fanSpread * 0.9, colour: engaged ? micOnColor.withAlphaComponent(0.2) : micOffColor) //transparency: 0.2)
    circle(centre: centre, radius: radius + fanRoom * fanSpread * 0.6, colour: engaged ? micOnColor.withAlphaComponent(0.3) : micOffColor)
    circle(centre: centre, radius: radius + fanRoom * fanSpread * 0.3, colour: engaged ? micOnColor.withAlphaComponent(0.4) : micOffColor)
    circle(centre: centre, radius: radius, colour: engaged ? micOnColor : micOffColor)
    voiceIcon(centre: centre, radius: radius / 2.2, colour: engaged ? micOffColor : micOnColor)
  }
  
  
  func volumeToFanSpread() -> CGFloat {
    let ex = -5.0 * (volume * 2.0 - 1.0)
    let denominator = 1.0 + exp(ex)
    return 1.0 / denominator
  }
  

}


