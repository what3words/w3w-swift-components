//
//  File.swift
//  
//
//  Created by Dave Duprey on 04/05/2021.
//

import UIKit
import W3WSwiftApi


public class W3WSuggestionView: UIView, W3WSuggestionViewProtocol {
  
  static let cellIdentifier = "W3SuggestionTableViewCell"
  
  /// the three word address to display
  var suggestion: W3WSuggestion?
  //var threeWordAddressText: W3WFormatter?
  
  /// indicates if this one should stand out form the rest
  var highlight = false
  
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
  
  /// lays out the UI elements, depending on how much info is present
  public override func layoutSubviews() {
    super.layoutSubviews()
    arrangeViews()
  }

  
  public func set(suggestion: W3WSuggestion) {
    assign(suggestion: suggestion)
  }
  
}


