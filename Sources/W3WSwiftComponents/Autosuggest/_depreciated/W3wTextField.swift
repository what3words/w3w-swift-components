//
//  W3wTextField.swift
//  W3wSuggestionField_Example
//
//  Created by Lshiva on 05/08/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import W3WSwiftApi

#if os(iOS)

public struct flag {
    static let rows         = 16
    static let cols         = 16
    static let width        = 64
    static let height       = 48
}

public struct W3wSuggestionError: Error {
  public let message: String
}

struct Coordinates {
  let latitude: Double
  let longitude: Double

  init(coordinateString: String) {
    let crdSplit = coordinateString.split(separator: ",")
    latitude = atof(String(crdSplit.first!))
    longitude = atof(String(crdSplit.last!))
  }
}

struct Clip {
    var coordinates = [CLLocationCoordinate2D]()
    let limitPolygon = 25 // number of coordinate pairs in polygon
    let limitBoundingBox = 2 // number of coordinate pairs in bounding box
    let limitCircle = 1 // number of coordinate pairs in cirlce with kilometers
    var kilometers = "" //
    
    init(polygon: String ) { // Parse comma seperated polygon
        let input = polygon.split(separator: ",")
        let _ = stride(from: 0, to: input.count - 1, by: 2).map {
            let coordinate = Coordinates(coordinateString: "\(input[$0]), \(input[$0+1])")
            let location = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            coordinates.append(location)
        }
    }
    
    init(boundingBox: String ) { // Parse comma seperated boundingbox
        let input = boundingBox.split(separator: ",")
        let _ = stride(from: 0, to: input.count - 1, by: 2).map {
            let coordinate = Coordinates(coordinateString: "\(input[$0]), \(input[$0+1])")
            let location = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            coordinates.append(location)
        }
    }
    
    init (circle: String ) { // Parse comma seperated Circle
        let input = circle.split(separator: ",")
         let _ = stride(from: 0, to: input.count - 1, by: 2).map {
            let coordinate = Coordinates(coordinateString: "\(input[$0]), \(input[$0+1])")
            coordinates.append(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }
        kilometers = String(input.last!)
    }
    // validate polygons
    func polygonCoordinates() -> [CLLocationCoordinate2D]? {
        return coordinates
    }
    // validate Bounding Box
    func boundingBoxCoordinates() -> [CLLocationCoordinate2D]? {
        return coordinates
    }
    // validate Circle
    func circleCoordinates() -> [CLLocationCoordinate2D]? {
        return coordinates
    }
}

@IBDesignable open class W3wTextField: UITextField {
    // autosuggest options wrapper
    fileprivate var options = [AutoSuggestOption]()
    // Debug mode
    fileprivate var isDebugMode : Bool = false
    // set corner radius
    @IBInspectable public var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    // set border color
    @IBInspectable public var borderColor: UIColor =  UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    // set border width
    @IBInspectable public var borderWidth: CGFloat = 0.5 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    // set list height
    @IBInspectable  public var listHeight: CGFloat = 350 {
        didSet { }
    }

    // set number of results to return
    @IBInspectable var nResults : Int = 3 {
        didSet {
            self.options.append(NumberResults(numberOfResults: nResults))
        }
    }
    //overwrite the validation error message with a custom value
    @IBInspectable var debug : Bool  = false {
        didSet {
            self.isDebugMode = debug
        }
    }

    // comma separated lat/lng of point to focus on
    @IBInspectable public var autoFocus: String  = "" {
        didSet {
            let coordinates = Coordinates(coordinateString: self.autoFocus)
            let coords = CLLocationCoordinate2D(latitude:coordinates.latitude, longitude:coordinates.longitude)
            if CLLocationCoordinate2DIsValid(coords) {
                self.options.append(Focus(focus: coords))
            }
        }
    }

    // set the number of results within what is returned to apply the focus to
    @IBInspectable var nFocusResults : Int = 3 {
        didSet {
            self.options.append(NumberFocusResults(numberFocusResults: nFocusResults))
        }
    }

    // confine results to a given country or comma separated list of countries
    @IBInspectable var clipToCountry : String  = "" {
        didSet {
            self.options.append(ClipToCountry(country: clipToCountry))
        }
    }

    // Confine results to a bounding box specified using co-ordinates
    @IBInspectable var clipToBoundingBox : String = "" {
        didSet {
            let clip = Clip(boundingBox: clipToBoundingBox).boundingBoxCoordinates()
            self.options.append(BoundingBox(south_lat: (clip?.first!.latitude)!, west_lng: (clip?.first!.longitude)!, north_lat: (clip?.last!.latitude)!, east_lng: (clip?.last!.longitude)!))
        }
    }
    
    // Restrict autosuggest results to a circle, specified by lat,lng,kilometres, where kilometres in the radius of the circle.
    @IBInspectable var clipToCircle : String  = "" {
        didSet {
            let clip = Clip(circle: clipToCircle)
            let clipCircle = clip.circleCoordinates()
            self.options.append(BoundingCircle(lat: (clipCircle?.first!.latitude)!, lng:  (clipCircle?.first?.longitude)!, kilometers: (clip.kilometers as NSString).doubleValue))
        }
    }

    // Restrict autosuggest results to a polygon, specified by a comma-separated list of lat,lng pairs.
    @IBInspectable var clipToPolygon : String = "" {
        didSet {
            let polygon = Clip(polygon: clipToPolygon).polygonCoordinates()
            self.options.append(BoundingPolygon(polygon: polygon!))
        }
    }
    
    var table : UITableView!
    public  var selectedIndex: Int?
    
    let countries = ["ad", "ae", "af", "ag", "ai", "al", "am", "ao", "aq", "ar", "as", "at", "au", "aw", "ax", "az", "ba", "bb", "bd", "be", "bf", "bg", "bh", "bi", "bj", "bl", "bm", "bn", "bo", "bq", "br", "bs", "bt", "bv", "bw", "by", "bz", "ca", "cc", "cd", "cf", "cg", "ch", "ci", "ck", "cl", "cm", "cn", "co", "cr", "cu", "cv", "cw", "cx", "cy", "cz", "de", "dj", "dk", "dm", "do", "dz", "ec", "ee", "eg", "eh", "er", "es", "et", "eu", "fi", "fj", "fk", "fm", "fo", "fr", "ga", "gb-eng", "gb-nir", "gb-sct", "gb-wls", "gb", "gd", "ge", "gf", "gg", "gh", "gi", "gl", "gm", "gn", "gp", "gq", "gr", "gs", "gt", "gu", "gw", "gy", "hk", "hm", "hn", "hr", "ht", "hu", "id", "ie", "il", "im", "in", "io", "iq", "ir", "is", "it", "je", "jm", "jo", "jp", "ke", "kg", "kh", "ki", "km", "kn", "kp", "kr", "kw", "ky", "kz", "la", "lb", "lc", "li", "lk", "lr", "ls", "lt", "lu", "lv", "ly", "ma", "mc", "md", "me", "mf", "mg", "mh", "mk", "ml", "mm", "mn", "mo", "mp", "mq", "mr", "ms", "mt", "mu", "mv", "mw", "mx", "my", "mz", "na", "nc", "ne", "nf", "ng", "ni", "nl", "no", "np", "nr", "nu", "nz", "om", "pa", "pe", "pf", "pg", "ph", "pk", "pl", "pm", "pn", "pr", "ps", "pt", "pw", "py", "qa", "re", "ro", "rs", "ru", "rw", "sa", "sb", "sc", "sd", "se", "sg", "sh", "si", "sj", "sk", "sl", "sm", "sn", "so", "sr", "ss", "st", "sv", "sx", "sy", "sz", "tc", "td", "tf", "tg", "th", "tj", "tk", "tl", "tm", "tn", "to", "tr", "tt", "tv", "tw", "tz", "ua", "ug", "um", "un", "us", "uy", "uz", "va", "vc", "ve", "vg", "vi", "vn", "vu", "wf", "ws", "ye", "yt", "za", "zm", "zw", "zz"]

    let cellIdentifier = "DropDownCell"
    // Setup row height
    public var rowHeight: CGFloat = 78
    // set up row Background color
    public var rowBackgroundColor: UIColor = .white
    // set up selected row color
    public var selectedRowColor: UIColor = .cyan
    // Hide the 3wa dropdown after selected
    public var hideOptionsWhenSelect = true
    // set isearchable
    public var isSearchEnable: Bool = true
    // set flag image
    let flagImage = UIImage(named: "flag.water.png")
    // table height
    fileprivate  var tableheightX: CGFloat = 350
    // set up the array
    fileprivate  var dataArray = [W3wSuggestion]()
    // parent view controller
    fileprivate  var parentController:UIViewController?
    // set the coordinate point to parent
    fileprivate  var pointToParent = CGPoint(x: 0, y: 0)
    // Set the background view
    fileprivate var backgroundView = UIView()
    // Keyboard height
    fileprivate var keyboardHeight:CGFloat = 0
    // left margin
    fileprivate let leftMargin: CGFloat = 15.0
    // set option array to collect suggestions
    public var optionArray = [W3wSuggestion]() {
        didSet{
            self.dataArray = self.optionArray
        }
    }
    
    var searchText = String()
    {
        didSet{
            guard !searchText.isEmpty else { // validate for Empty field
                return
            }
            
            W3wGeocoder.shared.autosuggest(input: searchText, options: options ) { (suggestions, error) in
            if let e = error {
                self.isDebugMode ? assertionFailure(e.message) : print(e.message)
            }
            
            guard suggestions?.count != nil else {
                return
            }
            
            self.optionArray.removeAll()
            self.dataArray.removeAll()
            for suggestion in suggestions ?? [] {
                self.optionArray.append(suggestion)
                self.dataArray = self.optionArray
                if self.dataArray.count > 0 {
                    DispatchQueue.main.async {
                        self.table.reloadData()
                    }
                }
            }
        }
        reSizeTable()
        selectedIndex = nil
        self.table.reloadData()
        }
    }

    public var handleKeyboard: Bool = true {
        didSet{
            // handle keyboard
        }
    }

    // Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        self.delegate = self
    }

  
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupUI()
        self.delegate = self
    }
  
  
    // set up API key
    public func setAPIKey(APIKey: String) {
        W3wGeocoder.setup(with: APIKey)
    }
    
    // text handler
    internal lazy var textHandler : String = {
        let hintLabel = UILabel(frame: CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width:23, height: self.frame.size.height))
        hintLabel.text = "///"
        hintLabel.textColor = #colorLiteral(red: 0.8809856772, green: 0.1242912188, blue: 0.150870949, alpha: 1)
        hintLabel.contentMode = .scaleAspectFit
        hintLabel.font = UIFont .systemFont(ofSize: 20, weight: .thin)
        return hintLabel.text!
    }()
    
    // Check mark view
    internal lazy var checkMarkView: UIView = {
        let rightViewImage = UIImageView(frame: CGRect(x: -10, y: 0, width: 23, height: 23))
        let bundle = Bundle.init(for: W3wTextField.self)
        let rightImage = UIImage(named: "checkmark", in: bundle, compatibleWith: nil)
        rightViewImage.image = rightImage
        let iconContainerView: UIView = UIView(frame:CGRect(x: 0, y: self.frame.size.height / 2, width: 30, height: 30))
        iconContainerView.addSubview(rightViewImage)
        return iconContainerView
    }()
    
    //MARK: Closures
    fileprivate var didSelectCompletion: (String) -> () = {selectedText in }
    fileprivate var TableWillAppearCompletion: () -> () = { }
    fileprivate var TableDidAppearCompletion: () -> () = { }
    fileprivate var TableWillDisappearCompletion: () -> () = { }
    fileprivate var TableDidDisappearCompletion: () -> () = { }
    
    func setupUI () {
        /* Textfield */
        self.borderStyle = .none
        self.layer.masksToBounds = false
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 4.0
        self.layer.sublayerTransform = CATransform3DMakeTranslation(leftMargin, 0.0, 0.0)
        self.keyboardType = .emailAddress
        // text handler
        let textHandler = UILabel(frame: CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width:23, height: self.frame.size.height))
        textHandler.text = "///"
        textHandler.textColor = UIColor .red
        textHandler.contentMode = .scaleAspectFit
        textHandler.font = UIFont(name: textHandler.font.fontName, size: 23)
        self.leftView = textHandler
        self.leftViewMode = .always
        self.rightView = checkMarkView
        self.rightViewMode = .always
        
        self.backgroundView.backgroundColor = .clear
        self.checkMarkView.isHidden = true

        if isSearchEnable && handleKeyboard{
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
                if self.isFirstResponder{
                let userInfo:NSDictionary = notification.userInfo! as NSDictionary
                    let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
                let keyboardRectangle = keyboardFrame.cgRectValue
                self.keyboardHeight = keyboardRectangle.height
                }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (notification) in
                if self.isFirstResponder{
                self.keyboardHeight = 0
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // touch action
    @objc public func touchAction() {

        isSelected ?  hideList() : showList()
    }
    
    func getConvertedPoint(_ targetView: UIView, baseView: UIView?)->CGPoint{
        var pnt = targetView.frame.origin
        if nil == targetView.superview{
            return pnt
        }
        var superView = targetView.superview
        while superView != baseView{
            pnt = superView!.convert(pnt, to: superView!.superview)
            if nil == superView!.superview{
                break
            }else{
                superView = superView!.superview
            }
        }
        return superView!.convert(pnt, to: baseView)
    }
    //MARK: Actions Methods
    public func showList() {
        if parentController == nil {
            parentController = self.parentViewController
            backgroundView.frame = parentController?.view.frame ?? backgroundView.frame
            pointToParent = getConvertedPoint(self, baseView: parentController?.view)
        }
        
        parentController?.view.insertSubview(backgroundView, aboveSubview: self)
        
        TableWillAppearCompletion()
        
        if listHeight > rowHeight * CGFloat( dataArray.count) {
            self.tableheightX = rowHeight * CGFloat(dataArray.count)
        }else{
            self.tableheightX = listHeight
        }
        table = UITableView(frame: CGRect(x: pointToParent.x ,y: pointToParent.y + self.frame.height, width: self.frame.width, height: self.frame.height))
        table.dataSource = self
        table.delegate = self
        table.alpha = 0
        table.separatorStyle = .none
        table.layer.cornerRadius = 10
        table.rowHeight = table.bounds.height
        table.layer.cornerRadius = 0.0
        table.backgroundColor = .clear
        parentController?.view.addSubview(table)
        self.table.register(SuggestionTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.isSelected = true
        let height = (self.parentController?.view.frame.height ?? 0) - (self.pointToParent.y + self.frame.height + 5)
        var y = self.pointToParent.y+self.frame.height + 5
        if height < (keyboardHeight+tableheightX) {
            y = self.pointToParent.y - tableheightX
        }
        UIView.animate(withDuration: 0.9, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: { () -> Void in
            self.table.frame = CGRect(x: self.pointToParent.x, y: y, width: self.frame.width, height: self.tableheightX)
            self.table.alpha = 1
        }, completion: { (finish) -> Void in
            self.layoutIfNeeded()
        })
    }

    public func hideList() {
        TableWillDisappearCompletion()
        UIView.animate(withDuration: 1.0, delay: 0.4, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: { () -> Void in
            self.table.frame = CGRect(x: self.pointToParent.x, y: self.pointToParent.y+self.frame.height, width: self.frame.width, height: 0)
        }, completion: { (didFinish) -> Void in
            self.table.removeFromSuperview()
            self.backgroundView.removeFromSuperview()
            self.isSelected = false
            self.TableDidDisappearCompletion()
        })
    }
    
    func reSizeTable() {
        if listHeight > rowHeight * CGFloat( dataArray.count) {
            self.tableheightX = rowHeight * CGFloat(dataArray.count)
        }else{
            self.tableheightX = listHeight
        }
        //let height = (self.parentController?.view.frame.height ?? 0) - (self.pointToParent.y + self.frame.height)
        let y = self.pointToParent.y+self.frame.size.height + 5
        UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: { () -> Void in
            self.table.frame = CGRect(x: self.pointToParent.x, y: y, width: self.frame.width, height: self.tableheightX)
        }, completion: { (didFinish) -> Void in
            self.layoutIfNeeded()
        })
    }

    public func didSelect(completion: @escaping (_ selectedText: String ) -> ()) {
        didSelectCompletion = completion
    }

    public func listWillAppear(completion: @escaping () -> ()) {
        TableWillAppearCompletion = completion
    }

    public func listDidAppear(completion: @escaping () -> ()) {
        TableDidAppearCompletion = completion
    }

    public func listWillDisappear(completion: @escaping () -> ()) {
        TableWillDisappearCompletion = completion
    }

    public func listDidDisappear(completion: @escaping () -> ()) {
        TableDidDisappearCompletion = completion
    }

}

//MARK: UITextFieldDelegate
extension W3wTextField : UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.isSelected = false
        self.backgroundView.isHidden = true
        return true
    }
    public func  textFieldDidBeginEditing(_ textField: UITextField) {
        self.optionArray.removeAll()
        self.dataArray = self.optionArray
        touchAction()
    }
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return isSearchEnable
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.backgroundView.isHidden = false
        if string != "" {
            self.searchText = "\(textField.text!)\(string)"
        } else{
            let subText = self.text?.dropLast()
            self.searchText = String(subText!)
        }
        
        if !isSelected {
            hideList()
        }
        
        W3wGeocoder.shared.convertToCoordinates(words: self.searchText)  { (place, error) in
            if (( place?.coordinates ) != nil)
            {
                DispatchQueue.main.async {
                    self.checkMarkView.isHidden = false
                }
            } else {
                DispatchQueue.main.async {
                    self.checkMarkView.isHidden = true
                }
            }
        }
        return true;
    }
}

///MARK: UITableViewDataSource
extension W3wTextField: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:SuggestionTableViewCell = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! SuggestionTableViewCell?)!
        let range = ("\(textHandler)\(dataArray[indexPath.row].words)" as NSString).range(of: "///")
        let attributedString = NSMutableAttributedString(string: "\(textHandler)\(dataArray[indexPath.row].words)")
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: range)
        cell.three_word_address.attributedText = attributedString
        cell.nearest_place.text = "\(dataArray[indexPath.row].nearestPlace), \(dataArray[indexPath.row].country)"
        cell.layer.borderColor = #colorLiteral(red: 0.4313323498, green: 0.4313982427, blue: 0.4313178957, alpha: 1)
        cell.layer.borderWidth = 0.5
        //let country_index = countries.firstIndex(of: "\(dataArray[indexPath.row].country.lowercased())")
        //if let index = country_index {
            //let row = index % flag.cols
            //let col = index / flag.rows
            //let x = row * flag.width
            //let y = col * flag.height
            //let clearImage = UIImage(named: "flags", in: Bundle.module, compatibleWith: nil)
            //cell.country_flag.image = UIImage(cgImage: (clearImage?.cgImage?.cropping(to: CGRect(x: x, y: y, width: flag.width, height: flag.height)))!)
        //}
        return cell
    }
}

extension W3wTextField: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = (indexPath as NSIndexPath).row
        let selectedText = self.dataArray[self.selectedIndex!]
        tableView.cellForRow(at: indexPath)?.alpha = 0
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            tableView.cellForRow(at: indexPath)?.alpha = 1.0
            tableView.cellForRow(at: indexPath)?.backgroundColor = .none
        } , completion: { (didFinish) -> Void in
            self.text = "\(selectedText.words)"
            tableView.reloadData()
        })
        if hideOptionsWhenSelect {
            touchAction()
            self.endEditing(true)
        }
        didSelectCompletion(selectedText.words )
    }
}

extension UIView {
//    var parentViewController: UIViewController? {
//        var parentResponder: UIResponder? = self
//        while parentResponder != nil {
//          parentResponder = parentResponder!.next
//          if let viewController = parentResponder as? UIViewController {
//              return viewController
//          }
//        }
//        return nil
//    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

}

class SuggestionTableViewCell: UITableViewCell {
    
    fileprivate let Margin: CGFloat = 15.0
    
    let containerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    let three_word_address : UILabel = {
        let hintLabel = UILabel()
        hintLabel.textColor = #colorLiteral(red: 0.04098141938, green: 0.1890356243, blue: 0.2865650356, alpha: 1)
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        return hintLabel
        
    }()
    
    let nearest_place : UILabel = {
        let hintLabel = UILabel()
        hintLabel.textColor = #colorLiteral(red: 0.4313323498, green: 0.4313982427, blue: 0.4313178957, alpha: 1)
        hintLabel.clipsToBounds = true
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        return hintLabel

    }()
    
    let country_flag : UIImageView = {
        let flag = UIImageView()
        flag.translatesAutoresizingMaskIntoConstraints = false
        flag.clipsToBounds = true
        return flag
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.containerView.addSubview(three_word_address)
        //self.containerView.addSubview(country_flag)
        self.containerView.addSubview(nearest_place)
        self.contentView.addSubview(containerView)
        // set up container view
        containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant: Margin).isActive = true
        containerView.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant: -Margin).isActive = true
        containerView.heightAnchor.constraint(equalTo:self.contentView.heightAnchor).isActive = true
        // set up three word address
        three_word_address.topAnchor.constraint(equalTo:self.containerView.topAnchor, constant: self.frame.height / 8.0 ).isActive = true
        three_word_address.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
        three_word_address.widthAnchor.constraint(equalTo: self.containerView.widthAnchor).isActive = true
        three_word_address.heightAnchor.constraint(equalTo: self.containerView.heightAnchor, multiplier: 0.5 ).isActive = true
        //three_word_address.font = three_word_address.font.withSize(self.frame.height / 1.5)
        three_word_address.sizeToFit()
        // set up nearest place
        nearest_place.topAnchor.constraint(equalTo:self.three_word_address.bottomAnchor, constant: self.frame.height / 8.0 ).isActive = true
        //nearest_place.leadingAnchor.constraint(equalTo:self.country_flag.trailingAnchor, constant: 5.0).isActive = true
        nearest_place.leadingAnchor.constraint(equalTo:self.three_word_address.leadingAnchor).isActive = true
        //nearest_place.font = nearest_place.font.withSize(self.frame.height / 3)
        nearest_place.sizeToFit()
        // set up country flag
        //country_flag.leadingAnchor.constraint(equalTo:self.three_word_address.leadingAnchor).isActive = true
        //country_flag.centerYAnchor.constraint(equalTo: self.nearest_place.centerYAnchor).isActive = true
        //country_flag.widthAnchor.constraint(equalToConstant:self.frame.height / 2.0 ).isActive = true
        //country_flag.heightAnchor.constraint(equalToConstant: self.frame.height / 2.0 / 1.3).isActive = true
    }
}

#endif
