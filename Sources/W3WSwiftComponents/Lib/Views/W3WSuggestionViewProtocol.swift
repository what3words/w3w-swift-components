//
//  File.swift
//  
//
//  Created by Dave Duprey on 04/05/2021.
//

import UIKit
import W3WSwiftApi


/// layout and UI code for UIViews that display a three word address, such as W3WSuggestionTableViewCell and W3WSuggestionView
protocol W3WSuggestionViewProtocol : UIView {
  
  /// the three word address to display
  var suggestion: W3WSuggestion?  { get set }

  /// indicates if this one should stand out from the rest
  var highlight: Bool { get set }
  
  /// called when the dispaly colours should change, ei, light/dark mode
  func updateColours()

  /// the UI elements
  var wordsLabel: UILabel? { get set }
  var flagIcon: UIImageView? { get set }
  var nearestPlaceLabel: UILabel? { get set }
  var distanceLabel: UILabel? { get set }
}
 

/// functions for W3WSuggestionViewProtocol that display a three word address, such as W3WSuggestionTableViewCell and W3WSuggestionView
extension W3WSuggestionViewProtocol {
  
  /// assign the three words values to the UI elecments
  public func assign(suggestion: W3WSuggestion) {
    
    self.suggestion = suggestion
    
    let threeWordAddressText = W3WFormatter(suggestion.words)
    wordsLabel?.attributedText = threeWordAddressText.withSlashes(fontSize: W3WSettings.componentsAddressTextSize, slashColor: W3WSettings.color(named: "SlashesColor"), weight: .semibold)
    
    if let place = suggestion.nearestPlace {
      if (suggestion.language ?? "") == W3WSettings.defaultLanguage && !place.isEmpty {
        nearestPlaceLabel?.text = String(format: W3WSettings.componentsNearFormatText, place)
      } else {
        nearestPlaceLabel?.text = place
      }
    } else {
      nearestPlaceLabel?.text = ""
    }
    
    if let distance = suggestion.distanceToFocus {
      distanceLabel?.text = W3WFormatter.distanceAsString(kilometers: distance)
    } else {
      distanceLabel?.text = ""
    }
    
    if let code = suggestion.country {
      if let i = W3WFlags.get(countryCode: code) {
        flagIcon?.image = i
      } else {
        flagIcon?.image = nil
      }
    }
  }

  
  
  /// set up the UI stuff
  func instantiateUIElements() {
    
    backgroundColor = W3WSettings.color(named: "TableCellBacking")
    
    wordsLabel = UILabel()
    wordsLabel?.textColor = W3WSettings.color(named: "AddressTextColor")
    wordsLabel?.backgroundColor = .clear
    if let l = wordsLabel {
      addSubview(l)
    }
    
    flagIcon = UIImageView()
    flagIcon?.contentMode = .scaleAspectFill
    flagIcon?.layer.minificationFilter = CALayerContentsFilter.trilinear
    flagIcon?.layer.minificationFilterBias = 0.1
    if let f = flagIcon {
      addSubview(f)
    }
    
    nearestPlaceLabel = UILabel()
    nearestPlaceLabel?.textColor = W3WSettings.color(named: "NearestPlaceColor")
    nearestPlaceLabel?.backgroundColor = .clear
    if let p = nearestPlaceLabel {
      addSubview(p)
    }
    
    distanceLabel = UILabel()
    distanceLabel?.textColor = W3WSettings.color(named: "NearestPlaceColor")
    distanceLabel?.backgroundColor = .clear
    if let d = distanceLabel {
      addSubview(d)
    }
    
    if let cell = self as? UITableViewCell {
      let cellBackground = UIView()
      cellBackground.backgroundColor = W3WSettings.color(named: "HighlightBacking")
      cell.selectedBackgroundView = cellBackground
    }
    
  }
  
  
  /// set if this one should stand out form the rest
  public func set(highlight: Bool) {
    self.highlight = highlight
    updateColours()
  }
  

  func updateColours() {
    // set the background colour
    backgroundColor = W3WSettings.color(named: "TableCellBacking")

    // deal with highlight colour in UITableViewCell
    if let cell = self as? UITableViewCell {
      cell.isHighlighted = highlight
      cell.selectedBackgroundView?.backgroundColor = W3WSettings.color(named: "HighlightBacking")
    }
    
    // deal with highlight colour in non-UITableViewCell
    if self.highlight {
      backgroundColor = W3WSettings.color(named: "HighlightBacking")
    } else {
      backgroundColor = W3WSettings.color(named: "TableCellBacking")
    }

    wordsLabel?.textColor = W3WSettings.color(named: "AddressTextColor")

    if let words = suggestion?.words {
      let threeWordAddressText = W3WFormatter(words)
      wordsLabel?.attributedText = threeWordAddressText.withSlashes(fontSize: wordsTextHeight(), slashColor: W3WSettings.color(named: "SlashesColor"), weight: .semibold)
    }

    nearestPlaceLabel?.textColor = W3WSettings.color(named: "NearestPlaceColor")
    distanceLabel?.textColor = W3WSettings.color(named: "NearestPlaceColor")
  }
  
  
  func wordsTextHeight() -> CGFloat {
    return frame.size.height * (17.0 / 72.0)
  }
  
  
  func descriptionTextHeight() -> CGFloat {
    return frame.size.height * (13.0 / 72.0)
  }
  
  
  func wordsLabelHeight() -> CGFloat {
    return frame.size.height * (22.0 / 72.0)
  }
  
  
  func descriptionLabelHeight() -> CGFloat {
    return frame.size.height * (18.0 / 72.0)
  }
  
  
  func spacing() -> CGFloat {
    return frame.size.height * (12.0 / 72.0)
  }
  
  
  func leadingSpace() -> CGFloat {
    return spacing() * 1.5
  }

  func internalSpacing() -> CGFloat {
    return spacing() / 3.0
  }
  
  
  func lineInset() -> CGFloat {
    return spacing() * 2.8
  }
  
  
  /// lays out the UI elements, depending on how much info is present
  func arrangeViews() {
    
    // if no suggestion, or no words
    if suggestion == nil || (suggestion?.words?.isEmpty ?? false) || suggestion?.words == nil {
      layoutEmpty()
    
    // if there are words
    } else {
      layoutContent()
    }
    
  }
  
  
  /// lalyout for suggestions with nothing in them.  Shows a dashed line
  func layoutEmpty() {
    
    let space  = spacing()
    let lead   = leadingSpace()
    let height = wordsLabelHeight()

    let threeWordAddressText = W3WFormatter("")
    wordsLabel?.attributedText = threeWordAddressText.withSlashes(fontSize: wordsTextHeight(), slashColor: W3WSettings.color(named: "SlashesColor"), weight: .semibold)
    wordsLabel?.sizeToFit()

    if W3WSettings.leftToRight {
      wordsLabel?.frame = CGRect(x: lead, y: (frame.height - height) / 2.0, width: frame.size.width - space, height: height)
    } else {
      wordsLabel?.frame = CGRect(x: frame.size.width - lead - (wordsLabel?.frame.width ?? 0.0), y: (frame.height - height) / 2.0, width: frame.size.width - space, height: height)
    }

    let dashes = W3WDashes(frame: CGRect(x: lead * 2.0, y: (frame.height - height) / 2.0, width: frame.size.width - lead * 4.0, height: height))
    addSubview(dashes)

    // hide the others
    flagIcon?.isHidden = true
    nearestPlaceLabel?.isHidden = true
    distanceLabel?.isHidden = true
  }
  
  
  /// layout the elements
  func layoutContent() {
    if (suggestion?.nearestPlace?.count ?? 0) > 0 || suggestion?.distanceToFocus != nil || suggestion?.country?.uppercased() == "ZZ"  {
      layoutForTwoLinesOfText()
    } else {
      layoutForOneLineOfText()
    }
  }
  
  
  /// layout for a suggestion only showing an address
  func layoutForOneLineOfText() {
    //let space  = spacing()
    let lead   = leadingSpace()
    let height = wordsLabelHeight()

    if W3WSettings.leftToRight {
      wordsLabel?.textAlignment = .left
    } else {
      wordsLabel?.textAlignment = .right
    }

    wordsLabel?.frame = CGRect(x: lead, y: (frame.height - height) / 2.0, width: frame.size.width - lead * 2.0, height: height)
    if let words = suggestion?.words {
      let threeWordAddressText = W3WFormatter(words)
      wordsLabel?.attributedText = threeWordAddressText.withSlashes(fontSize: wordsTextHeight(), slashColor: W3WSettings.color(named: "SlashesColor"), weight: .semibold)
    }
  }
  
  
  /// layout for a suggestion showing an address and a nearest place
  func layoutForTwoLinesOfText() {
    let space     = spacing()
    let lead       = leadingSpace()
    var inset       = lineInset()
    let height       = wordsLabelHeight()
    let secondHeight  = descriptionLabelHeight()
    let internalSpace  = internalSpacing()
    
    if W3WSettings.leftToRight {
      wordsLabel?.textAlignment = .left
      nearestPlaceLabel?.textAlignment = .left
    } else {
      wordsLabel?.textAlignment = .right
      nearestPlaceLabel?.textAlignment = .right
    }

    var lineWidth = frame.size.width - lead * 2.0
    
    wordsLabel?.frame = CGRect(x: lead, y: space, width: lineWidth, height: height)
    if let words = suggestion?.words {
      let threeWordAddressText = W3WFormatter(words)
      wordsLabel?.attributedText = threeWordAddressText.withSlashes(fontSize: wordsTextHeight(), slashColor: W3WSettings.color(named: "SlashesColor"), weight: .semibold)
    }

    let y = space + height + internalSpace
    
    if suggestion?.country?.uppercased() == "ZZ" {
      if let fi = flagIcon {
        if W3WSettings.leftToRight {
          fi.frame = CGRect(x: inset, y: y, width: secondHeight * 1.2, height: secondHeight * 1.2)
        } else {
          fi.frame = CGRect(x: frame.width - inset - secondHeight * 1.2, y: y, width: secondHeight * 1.2, height: secondHeight * 1.2)
        }
        flagIcon?.isHidden = false
        inset += secondHeight * 1.6
        lineWidth -= secondHeight
      }
    }

    if suggestion?.distanceToFocus != nil {
      distanceLabel?.font = wordsLabel?.font.withSize(descriptionTextHeight())
      distanceLabel?.sizeToFit()
      if W3WSettings.leftToRight {
        distanceLabel?.frame = CGRect(x: frame.width - (distanceLabel?.frame.width ?? 0.0) - space, y: y, width: (distanceLabel?.frame.width ?? 0.0), height: secondHeight)
      } else {
        distanceLabel?.frame = CGRect(x: space, y: y, width: (distanceLabel?.frame.width ?? 0.0), height: secondHeight)
      }
      distanceLabel?.isHidden = false
      lineWidth = lineWidth - (distanceLabel?.frame.width ?? 0.0)
    }
    
    if suggestion?.nearestPlace != nil {
      // get the same font as used by the address, but the regular version of it
      if let font = wordsLabel?.font {
        let descriptor = font.fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.regular]])
        nearestPlaceLabel?.font = UIFont(descriptor: descriptor, size: descriptionTextHeight())
      }
      nearestPlaceLabel?.sizeToFit()
      if W3WSettings.leftToRight {
        nearestPlaceLabel?.frame = CGRect(x: inset, y: y, width: frame.width - inset - space - internalSpace - (distanceLabel?.frame.width ?? 0.0), height: secondHeight)
      } else {
        nearestPlaceLabel?.frame = CGRect(x: (distanceLabel?.frame.maxX ?? space) + space, y: y, width: frame.width - inset - space * 1.75 - internalSpace - (distanceLabel?.frame.width ?? 0.0), height: secondHeight)
      }
      nearestPlaceLabel?.isHidden = false
    }
  
  }

}


