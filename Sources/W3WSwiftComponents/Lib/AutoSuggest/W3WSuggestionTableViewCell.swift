//
//  SuggestionTableViewCell.swift
//  CoordinatorTemplate
//
//  Created by Dave Duprey on 04/07/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//

import UIKit
import W3WSwiftApi


/// a UITableViewCell for displaying a W3WSuggestion
public class W3WSuggestionTableViewCell: UITableViewCell {

  static let cellIdentifier = "W3SuggestionTableViewCell"
  
  /// the flags image, static so it is loaded once
  static let flags = W3WFlags()

  /// the three word address to display
  var threeWordAddressText: W3WAddress?
  
  /// indicates if this one should stand out form the rest
  var highlight = false
  
  /// the UI elemants
  var threeWordAddressLabel: UILabel!
  var flagIcon: UIImageView!
  var nearestPlaceLabel: UILabel!

  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    instantiateUIElements()
  }
  
  
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    instantiateUIElements()
  }
  
  
  /// set up the UI stuff
  func instantiateUIElements() {
    
    backgroundColor = .white
    
    threeWordAddressLabel = UILabel()
    threeWordAddressLabel.textColor = W3WSettings.componentsAddressTextColor //UIColor(red: 0.0391, green: 0.1875, blue: 0.2852, alpha: 1.0)
    threeWordAddressLabel.backgroundColor = .clear
    addSubview(threeWordAddressLabel)
    
    flagIcon = UIImageView()
    flagIcon.contentMode = .scaleAspectFill
    addSubview(flagIcon)
    
    nearestPlaceLabel = UILabel()
    nearestPlaceLabel.textColor = W3WSettings.componentsNearestPlaceColor //UIColor(red: 0.3203, green: 0.3203, blue: 0.3203, alpha: 1.0)
    nearestPlaceLabel.backgroundColor = .clear
    addSubview(nearestPlaceLabel)
  }
  

  /// assign the three words values to the UI elecments
  public func set(address: String?, countryCode: String?, nearestPlace: String?, language: String?) {
    
    threeWordAddressText = W3WAddress(address)
    if let text = threeWordAddressText {
      threeWordAddressLabel.attributedText = text.withSlashes(fontSize: W3WSettings.componentsAddressTextSize, slashColor: W3WSettings.componentsSlashesColor)
    }
    
    if let place = nearestPlace {
      if (language ?? "") == "en" {
        nearestPlaceLabel.text = String(format: W3WSettings.componentsNearFormatText, place)
      } else {
        nearestPlaceLabel.text = place
      }
    } else {
      nearestPlaceLabel.text = ""
    }

    if let code = countryCode {
      if let i = W3WSuggestionTableViewCell.flags.get(countryCode: code) {
        flagIcon.image = i
      }
    }
  }
  
  
  /// set if this one should stand out form the rest
  public func set(highlight: Bool) {
    self.highlight = highlight
    set(titleFontSize: threeWordAddressLabel.font.fontDescriptor.pointSize)
  }

  
  /// adjust the font size of the title
  func set(titleFontSize: CGFloat) {
    if self.highlight {
      threeWordAddressLabel.font = UIFont.systemFont(ofSize: titleFontSize, weight: .semibold)
    } else {
      self.threeWordAddressLabel.font = UIFont.systemFont(ofSize: titleFontSize, weight: .regular)
    }
  }
  
  
  public override func awakeFromNib() {
    super.awakeFromNib()
  }

  
  /// lays out the UI elements, depending on how much info is present
  public override func layoutSubviews() {
    super.layoutSubviews()

    // if there is a nearest place set
    if (nearestPlaceLabel.text?.count ?? 0) > 0 {
      layoutForTwoLinesOfText()
    } else {
      layoutForOneLineOfText()
    }
  }
  
  
  /// layou t for a suggestion only showing an address
  func layoutForOneLineOfText() {
    let cellHeight = frame.size.height
    let horizontalInset = cellHeight / 3.0
    let verticalInset = horizontalInset / 2.0
    let addressHeight = cellHeight - verticalInset * 2.0
    let addressFontSize = cellHeight / 2.4

    if W3WSettings.leftToRight {
      threeWordAddressLabel.textAlignment = .left
    } else {
      threeWordAddressLabel.textAlignment = .right
    }
    
    //threeWordAddressLabel.font = UIFont.systemFont(ofSize: addressFontSize, weight: .regular)
    threeWordAddressLabel.frame = CGRect(x: horizontalInset, y: verticalInset, width: frame.size.width - horizontalInset * 2.0, height: addressHeight)
    if let text = threeWordAddressText {
      threeWordAddressLabel.attributedText = text.withSlashes(fontSize: addressFontSize, slashColor: W3WSettings.componentsSlashesColor)
    }

    //flagIcon.frame = CGRect(x: 16.0, y: frame.size.height-36.0, width: 16.0, height: 12.0)
    flagIcon.isHidden = true
    nearestPlaceLabel.isHidden = true
  }
  
  
  /// layou t for a suggestion showing an address and a nearest place
  func layoutForTwoLinesOfText() {
    let cellHeight       = frame.size.height
    let inset             = cellHeight * (16.0 / 74.0)
    let flagSpacing        = cellHeight * (4.0 / 74.0)
    let flagHeight          = cellHeight * (12.0 / 74.0)
    let addressHeight        = cellHeight * (20.0 / 74.0)
    let addressFontSize       = cellHeight * (18.0 / 74.0)
    let nearestPlaceHeight     = cellHeight * (14.0 / 74.0)
    let nearestPlaceFontHeight  = cellHeight * (14.0 / 74.0)

    if W3WSettings.leftToRight {
      threeWordAddressLabel.textAlignment = .left
      nearestPlaceLabel.textAlignment     = .left
    } else {
      threeWordAddressLabel.textAlignment = .right
      nearestPlaceLabel.textAlignment     = .right
    }

    set(titleFontSize: addressFontSize)
    threeWordAddressLabel.frame = CGRect(x: inset, y: inset, width: frame.size.width - inset * 2.0, height: addressHeight)

    var secondLineY = cellHeight - inset - nearestPlaceHeight
    
    var flagWidth = CGFloat(0.0)
    
    if W3WSettings.leftToRight {
      if flagIcon.image != nil {
        flagWidth = nearestPlaceHeight / 3.0 * 4.0
        flagIcon?.isHidden = false
        flagIcon?.frame = CGRect(x: inset, y: secondLineY, width: flagWidth, height: flagHeight)
        flagWidth += flagSpacing
      }
      
      secondLineY -= cellHeight * (0.5 / 74.0)

      nearestPlaceLabel.isHidden = false
      nearestPlaceLabel.font = UIFont.systemFont(ofSize: nearestPlaceFontHeight, weight: .regular)
      nearestPlaceLabel.frame = CGRect(x: inset + flagWidth, y: secondLineY, width: frame.size.width - inset * 2.0, height: nearestPlaceHeight)
    } else {
      if flagIcon.image != nil {
        flagWidth = nearestPlaceHeight / 3.0 * 4.0
        flagIcon?.isHidden = false
        flagIcon?.frame = CGRect(x: frame.size.width - inset - flagWidth, y: secondLineY, width: flagWidth, height: flagHeight)
        flagWidth -= flagSpacing
      }
      
      secondLineY -= cellHeight * (0.5 / 74.0)
      
      nearestPlaceLabel.isHidden = false
      nearestPlaceLabel.font = UIFont.systemFont(ofSize: nearestPlaceFontHeight, weight: .regular)
      nearestPlaceLabel.frame = CGRect(x: inset, y: secondLineY, width: frame.size.width - flagWidth - inset * 2.5, height: nearestPlaceHeight)
    }
  }
  
  
  /// return an flag emoji given a country code (used as backup if flag images faill)
  func flag(country:String) -> String {
    let base : UInt32 = 127397
    var s = ""
    for v in country.uppercased().unicodeScalars {
      s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
    }
    return String(s)
  }
  
}
