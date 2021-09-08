//
//  File.swift
//  
//
//  Created by Dave Duprey on 04/05/2021.
//

import UIKit
import W3WSwiftApi


/// displays a W3WSuggestion, W3WSuggestionViewProtocol does most the heavy lifting
public class W3WSuggestionView: UIView, W3WSuggestionViewProtocol {
  
  static let cellIdentifier = "W3SuggestionTableViewCell"
  
  /// the three word address to display
  var suggestion: W3WSuggestion?
  //var threeWordAddressText: W3WFormatter?
  
  /// indicates if this one should stand out from the rest
  var highlight = false

  /// indicates  if the view should ignore dark mode
  var disableDarkmode: Bool = false
  
  /// the UI elements
  var wordsLabel: UILabel?
  var flagIcon: UIImageView?
  var nearestPlaceLabel: UILabel?
  var distanceLabel: UILabel?

  
  public override init(frame: CGRect) {
    super.init(frame: frame)
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

  
  public func set(suggestion: W3WSuggestion) {
    assign(suggestion: suggestion)
  }
  
}


