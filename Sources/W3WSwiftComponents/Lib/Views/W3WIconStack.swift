//
//  W3WIconStack.swift
//  CoordinatorTemplate
//
//  Created by Dave Duprey on 05/10/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//

import UIKit


/// a view containing a number of icons for display in a textfield
class W3WIconStack: UIView {

  var icons   = [UIView]()
  var spacing = CGFloat(0.0)
  
  func add(left: UIView) {
    icons.insert(left, at: 0)
    addSubview(left)
    resize()
  }
  
  
  func add(right: UIView) {
    icons.append(right)
    addSubview(right)
    resize()
  }
  
  
  func getWidth() -> CGFloat {
    let size = frame.size.height

    var numberOfVisibleIcons = 0
    for icon in icons {
      if !icon.isHidden {
        numberOfVisibleIcons += 1
      }
    }
    
    return (size + spacing) * CGFloat(numberOfVisibleIcons) - spacing
  }
  

  func resize() {
    // make this view the right size for the number of icons
    let size = frame.size.height
    
    let width = getWidth()
    frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: width, height: size)

    layoutIcons()
  }
  
  
  override func didAddSubview(_ subview: UIView) {
    resize()
  }
  
  
  override func layoutSubviews() {
    resize()
    layoutIcons()
  }

  
  func layoutIcons() {
    let size = frame.size.height
    var x    = CGFloat(0.0)
    
    // force all icons to be square and place them where they should be
    for icon in icons {
      icon.frame = CGRect(x: x, y: 0.0, width: size, height: size)
      icon.center = CGPoint(x: x + (size / 2.0), y: size / 2.0)
      if !icon.isHidden {
        x += size + spacing
      }
    }
  }
  
  
  
}
