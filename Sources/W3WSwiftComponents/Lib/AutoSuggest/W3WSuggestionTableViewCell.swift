//
//  SuggestionTableViewCell.swift
//  CoordinatorTemplate
//
//  Created by Dave Duprey on 04/07/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//
#if !os(macOS)

import UIKit
import W3WSwiftApi


/// a UITableViewCell for displaying a W3WSuggestion, W3WSuggestionViewProtocol does all the heavy lifting
public class W3WSuggestionTableViewCell: UITableViewCell, W3WSuggestionViewProtocol {

  static let cellIdentifier = "W3SuggestionTableViewCell"
  
  /// the three word address to display
  var suggestion: W3WSuggestion?
  //var threeWordAddressText: W3WFormatter?
  
  /// indicates if this one should stand out form the rest
  var highlight = false
  
  /// indicates  if the view should ignore dark mode
  var disableDarkmode: Bool = false

  /// the UI elements
  var wordsLabel: UILabel?
  var flagIcon: UIImageView?
  var nearestPlaceLabel: UILabel?
  var distanceLabel: UILabel?

  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    instantiateUIElements()
  }
  
  
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    instantiateUIElements()
  }
  
  
  public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    updateColours()
  }

  
  /// lays out the UI elements, depending on how much info is present
  public override func layoutSubviews() {
    super.layoutSubviews()
    arrangeViews()
  }
  
  
  
  public override func awakeFromNib() {
    super.awakeFromNib()
  }

  
  public func set(suggestion: W3WSuggestion) {
    assign(suggestion: suggestion)
  }

  
}
<<<<<<< HEAD
=======


#endif
>>>>>>> 43a11ffcb92ed6131dad6b872343efea08bb7986
