//
//  File.swift
//  
//
//  Created by Dave Duprey on 18/08/2021.
//
#if !os(macOS)

import Foundation
import UIKit
import W3WSwiftApi


public enum W3WViewPlacement {
  case topLeft
  case topRight
  case bottomLeft
  case bottomRight
  case topCenter
}


class W3WSubviewManager {
  
  /// views to manage
  var views: [W3WViewPlacement : [UIView]] = [
    .topLeft : [],
    .topCenter : [],
    .topRight : [],
    .bottomLeft : [],
    .bottomRight : []
  ]
  
  
  func add(view: UIView, position: W3WViewPlacement) {
    views[position]?.append(view)
    if let p = views[position]?.first?.center {
      view.center = p
    } else {
      view.center = .zero
    }
    view.alpha = 0.0
  }
  
  
  func layout(in view: UIView) {
    var insets = UIEdgeInsets.zero
    if #available(iOS 11.0, *) {
      insets = view.safeAreaInsets
    }

    if insets == UIEdgeInsets.zero {
      insets = UIEdgeInsets(top: W3WSettings.uiIndent, left: W3WSettings.uiIndent, bottom: W3WSettings.uiIndent, right: W3WSettings.uiIndent)
    }
    
    //DispatchQueue.main.async {
    UIView.animate(withDuration: 0.3, animations: {

      var y_line = insets.top // W3WSettings.uiIndent * 2.0 + insets.top
      
      var lowest_y = y_line
      var xl = W3WSettings.uiIndent * 2.0 + insets.left
      for subView in self.views[.topLeft] ?? [] {
        if !subView.isHidden {
          subView.frame = CGRect(
            x: xl,
            y: y_line,
            width: subView.frame.width,
            height: subView.frame.height)
          xl += subView.frame.width + W3WSettings.uiIndent * 2.0
          if lowest_y < subView.frame.height + W3WSettings.uiIndent * 2.0 + insets.top {
            lowest_y = subView.frame.height + W3WSettings.uiIndent * 2.0 + insets.top
          }
        }
      }
      
      var xr = view.frame.size.width - insets.right - W3WSettings.uiIndent * 2.0
      for subView in self.views[.topRight] ?? [] {
        if !subView.isHidden {
          subView.frame = CGRect(
            x: xr - subView.frame.width,
            y: y_line,
            width: subView.frame.width,
            height: subView.frame.height)
          xr -= (subView.frame.width + W3WSettings.uiIndent * 2.0)
          if lowest_y < subView.frame.height + W3WSettings.uiIndent * 2.0 + insets.top {
            lowest_y = subView.frame.height + W3WSettings.uiIndent * 2.0 + insets.top
          }
        }
      }
      
      y_line = lowest_y + W3WSettings.uiIndent * 2.0
      
      for subView in self.views[.topCenter] ?? [] {
        if !subView.isHidden {
          var width = view.frame.size.width - W3WSettings.uiIndent * 4.0 - insets.left - insets.right
          if view.frame.width > view.frame.height {
            width = view.frame.size.height - (W3WSettings.uiIndent * 4.0)
          }
          subView.frame = CGRect(x: W3WSettings.uiIndent * 2.0 + insets.left, y: y_line, width: width, height: 40.0)
        }
      }

      var yl = view.frame.size.height - insets.bottom
      for subView in self.views[.bottomLeft] ?? [] {
        if !subView.isHidden {
          yl -= (subView.frame.height + W3WSettings.uiIndent * 4.0)
          subView.frame = CGRect(
            x: W3WSettings.uiIndent * 2.0 + insets.left,
            y: yl,
            width: subView.frame.width,
            height: subView.frame.height)
        }
      }
      
      var y = view.frame.size.height - insets.bottom
      for subView in self.views[.bottomRight] ?? [] {
          if !subView.isHidden {
          y -= (subView.frame.height + W3WSettings.uiIndent * 4.0)
          subView.frame = CGRect(
            x: view.frame.width - insets.right - subView.frame.width - W3WSettings.uiIndent * 2.0,
            y: y,
            width: subView.frame.width,
            height: subView.frame.height)
        }
      }
    }, completion: { success in
      UIView.animate(withDuration: 0.3, delay: 0.3) {
        for subView in self.views[.topLeft] ?? [] {
          if subView.alpha == 0.0 {
            subView.alpha = 1.0
          }
        }
        for subView in self.views[.topRight] ?? [] {
          if subView.alpha == 0.0 {
            subView.alpha = 1.0
          }
        }
        for subView in self.views[.topCenter] ?? [] {
          if subView.alpha == 0.0 {
            subView.alpha = 1.0
          }
        }
        for subView in self.views[.bottomLeft] ?? [] {
          if subView.alpha == 0.0 {
            subView.alpha = 1.0
          }
        }
        for subView in self.views[.bottomRight] ?? [] {
          if subView.alpha == 0.0 {
            subView.alpha = 1.0
          }
        }
      }
    })
  }
  
}


#endif
