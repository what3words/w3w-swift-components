//
//  File.swift
//  
//
//  Created by Dave Duprey on 17/08/2021.
//
#if !os(macOS)

import Foundation
import MapKit
import W3WSwiftApi


public protocol W3WMapViewProtocol: AnyObject, W3WMapKitCompatibility { //}: W3WMapGrid, W3WMapPins, W3WMapSquares {
  var w3wMapView: MKMapView { get }
  var w3wMapData:W3WMapData? { get set }

  /// returns the error enum for any error that occurs
  var onError: W3WMapErrorResponse { get set }  
}



extension W3WMapViewProtocol {
  
  
  public func set(language: String) {
    w3wMapData?.set(language: language)
  }
  

  public func mapRenderer(overlay: MKOverlay) -> MKOverlayRenderer? {

    if #available(iOS 13, *) {
      if let o = overlay as? W3WMapGridLines {
        return getMapGridRenderer(overlay: o)
      }
    }
        
    if let o = overlay as? W3WMapSquareLines {
      return getMapSquaresRenderer(overlay: o)
    }

  return nil
  }
  
  
  /// update things that need to be updated
  public func updateMap() {
    updateGrid()
    
    if let lastZoomPointsPerSquare = w3wMapData?.lastZoomPointsPerSquare {
      let squareSize = getPointsPerSquare()
      if (squareSize < W3WSettings.mapAnnotationTransitionPointsPerSquare && lastZoomPointsPerSquare > W3WSettings.mapAnnotationTransitionPointsPerSquare) || (squareSize > W3WSettings.mapAnnotationTransitionPointsPerSquare && lastZoomPointsPerSquare < W3WSettings.mapAnnotationTransitionPointsPerSquare) {
        redrawPins()
      }
        
      w3wMapData?.lastZoomPointsPerSquare = squareSize
    }
  }
  
  
  
  /// force a redrawing of the map and all it's anotations pins and gridlines
  func redrawAll() {
    redrawPins()
    redrawGrid()
    redrawSquares()
  }

  
  
  
  
  
  // MARK: Grid Lines
  
  /// calls api.gridSection() and gets the lines for the grid, then calls presentNewGrid() to present the map on the view
  func updateGrid() {
    updateGridAlpha()
    w3wMapData?.gridUpdateDebouncer.handler = { self.makeGrid() }
    w3wMapData?.gridUpdateDebouncer.call()
  }
  
  
  func makeGrid() {
    checkConfiguration()

    // ask for a grid twice the size of the currently showing map area
    let sw = CLLocationCoordinate2D(latitude: region.center.latitude - region.span.latitudeDelta * 2.0, longitude: region.center.longitude - region.span.longitudeDelta * 2.0)
    let ne = CLLocationCoordinate2D(latitude: region.center.latitude + region.span.latitudeDelta * 2.0, longitude: region.center.longitude + region.span.longitudeDelta * 2.0)
    
    // call w3w api for lines, if the area is not too great
    if let distance = self.w3wMapData?.w3w?.distance(from: sw, to: ne) {
      if distance < W3WSettings.maxMetersDiagonalForGrid && distance > 0.0 {
        self.w3wMapData?.w3w?.gridSection(southWest:sw, northEast:ne) { lines, error in
          self.dealWithAnyApiError(error: error)
          self.presentNewGrid(lines: lines)
        }
      }
    }
  }
  
  
  /// show the grid on the view
  func presentNewGrid(lines: [W3WLine]?) {
    if #available(iOS 13, *) {
      DispatchQueue.main.async {
        // make the MKMultiPolyLine
        self.makePolygons(lines: lines)
        
        // replace the overlay with a new one with the new lines
        if let overlay = self.w3wMapData?.gridLines {
          self.removeGrid()
          self.addOverlay(overlay)
        }
      }
    }
  }
  
  
  /// makes an MKMultiPolyline from the grid lines
  func makePolygons(lines: [W3WLine]?) {
    if #available(iOS 13, *) {
      var multiLine = [MKPolyline]()
      
      for line in lines ?? [] {
        multiLine.append(MKPolyline(coordinates: [line.start, line.end], count: 2))
      }
      
      w3wMapData?.gridLines = W3WMapGridLines(multiLine)
    }
  }
  
  
  
  /// remove the grid overlay
  func removeGrid() {
    if #available(iOS 13.0, *) {
      for overlay in overlays {
        if let gridOverlay = overlay as? W3WMapGridLines {
          self.removeOverlay(gridOverlay)
        }
      }
    }
  }
  
  
  func getMapGridRenderer(overlay: MKOverlay) -> MKOverlayRenderer? {
    
    if #available(iOS 13, *) {
      if let gridLines = overlay as? W3WMapGridLines {
        w3wMapData?.gridRenderer = W3WMapGridRenderer(multiPolyline: gridLines)
        w3wMapData?.gridRenderer?.strokeColor = W3WSettings.color(named: "MapGridColor")
        w3wMapData?.gridRenderer?.lineWidth = W3WSettings.mapGridLineThickness
        updateGridAlpha()
        return w3wMapData?.gridRenderer
      }
    }
    
    return nil
  }
  
  
  func getSpanDistance() -> Double? {
    checkConfiguration()
    let p0 = CLLocationCoordinate2D(latitude: region.center.latitude + region.span.latitudeDelta, longitude: region.center.longitude + region.span.longitudeDelta)
    let p1 = CLLocationCoordinate2D(latitude: region.center.latitude - region.span.latitudeDelta, longitude: region.center.longitude - region.span.longitudeDelta)
    return w3wMapData?.w3w?.distance(from: p0, to: p1)
  }
  
  
  func getPointsPerSquare() -> CGFloat {
    let threeMeterMapSquare = MKCoordinateRegion(center: w3wMapView.centerCoordinate, latitudinalMeters: 3, longitudinalMeters: 3);
    let threeMeterViewSquare = w3wMapView.convert(threeMeterMapSquare, toRectTo: nil)
    
    return threeMeterViewSquare.size.height
  }
  
  
  func updateGridAlpha() {
    if #available(iOS 13, *) {
      var alpha = CGFloat(0.0)
      
      let pointsPerSquare = getPointsPerSquare()
      if pointsPerSquare > W3WSettings.mapGridInvisibleAtPointsPerSquare {
        alpha = (pointsPerSquare - W3WSettings.mapGridInvisibleAtPointsPerSquare) / W3WSettings.mapGridOpaqueAtPointsPerSquare
      }
    
      if alpha > 1.0 {
        alpha = 1.0

      } else if alpha < 0.0 {
        alpha = 0.0
      }
      
      
      w3wMapData?.gridRenderer?.alpha = alpha
    }
  }
  
  
  /// force a redrawing of all grid lines
  func redrawGrid() {
    makeGrid()
  }
  
  
  
  // MARK: Pins / Annotations
  
  
  public func getMapAnnotationView(annotation: MKAnnotation) -> MKAnnotationView? {
    if let a = annotation as? W3WAnnotation {
      let squareSize = getPointsPerSquare()
      if squareSize > W3WSettings.mapAnnotationTransitionPointsPerSquare {
        if let square = a.square {
          showOutline(square)
        }
        let box = MKAnnotationView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
        return box
      } else {
        if let square = a.square {
          hideOutline(square)
        }
        return getMapPinView(annotation: a)
      }
    }

    return nil
  }
  
  
  /// put a what3words annotation on the map showing the address, and optionally center the map around it
  public func show(_ square: W3WSquare?, camera: W3WCenterAndZoom = .zoom, color: UIColor? = nil, style: W3WMarkerStyle = .circle) {
    W3WThread.runOnMain {
      if let sq = square {
        W3WThread.runInBackground {
          if let s = self.ensureSquareHasCoordinates(square: sq) {
            
            self.addAnnotation(square: s, color: color, style: style)
            
            let center = self.region.center
            //var span   = self.region.span
            
            // just center the map without zooming
            if camera == .center {
              self.set(center: s.coordinates ?? center)
              
              // center and zoom into the square
            } else if camera == .zoom {
              let resolution = UIScreen.main.bounds
              let minPointsInView = min(resolution.width, resolution.height)
              let squaresToShow = minPointsInView / W3WSettings.mapDefaultZoomPointsPerSquare
              let metersToShow = Double(squaresToShow * 3.0)
              self.set(center: s.coordinates ?? center, latitudeSpanMeters: metersToShow, longitudeSpanMeters: metersToShow)
            }
          }
        }
      }
    }
  }
  
  
  /// put a what3words annotation on the map showing the address
  public func show(_ suggestion: W3WSuggestion?, camera: W3WCenterAndZoom = .zoom, color: UIColor? = nil, style: W3WMarkerStyle = .circle) {
    if let words = suggestion?.words {
      show(words, camera: camera, color: color, style: style)
    }
  }
  
  
  /// put a what3words annotation on the map showing the address
  public func show(_ words: String?, camera: W3WCenterAndZoom = .zoom, color: UIColor? = nil, style: W3WMarkerStyle = .circle) {
    W3WThread.runOnMain {
      if let w = words {
        self.checkConfiguration()
        self.w3wMapData?.w3w?.convertToCoordinates(words: w) { square, error in
          self.dealWithAnyApiError(error: error)
          if let s = square {
            self.show(s, camera: camera, color: color, style: style)
          }
        }
      }
    }
  }
  
  
  /// put a what3words annotation on the map showing the address
  public func show(_ coordinates: CLLocationCoordinate2D?, camera: W3WCenterAndZoom = .zoom, color: UIColor? = nil, style: W3WMarkerStyle = .circle) {
    W3WThread.runOnMain {
      if let c = coordinates {
        self.checkConfiguration()
        self.w3wMapData?.w3w?.convertTo3wa(coordinates: c, language: self.w3wMapData?.language ?? W3WSettings.defaultLanguage) { square, error in
          self.dealWithAnyApiError(error: error)
          if let s = square {
            self.show(s, camera: camera, color: color, style: style)
          }
        }
      }
    }
  }
  
  
  
  /// put a what3words annotation on the map showing the address
  public func show(_ squares: [W3WSquare]?, camera: W3WCenterAndZoom = .zoom, color: UIColor? = nil, style: W3WMarkerStyle = .circle) {
    W3WThread.runOnMain {
      if let s = squares {
        W3WThread.runInBackground {
          let goodSquares = self.ensureSquaresHaveCoordinates(squares: s)

          let area = W3WAreaMath()
          
          for square in goodSquares {
            self.addAnnotation(square: square, color: color, style: style)
            if let c = square.coordinates {
              area.add(coordinates: c)
            }
          }

          let center = area.getCenter()
          let (latSpan, longSpan) = area.getSpan()

          if camera == .zoom {
            self.set(center: center, latitudeSpanDegrees: latSpan, longitudeSpanDegrees: longSpan)
          } else if camera == .center {
            self.set(center: center)
          }
        }
      }
    }
  }
  
  
  /// put a what3words annotation on the map showing the address
  public func show(_ suggestions: [W3WSuggestion]?, camera: W3WCenterAndZoom = .zoom, color: UIColor? = nil, style: W3WMarkerStyle = .circle) {
    W3WThread.runOnMain {
      if let s = suggestions {
        W3WThread.runInBackground {
          self.show(self.convertToSquaresWithCoordinates(suggestions: s), camera: camera, color: color, style: style)
        }
      }
    }
  }
  
  
  /// put a what3words annotation on the map showing the address
  public func show(_ words: [String]?, camera: W3WCenterAndZoom = .zoom, color: UIColor? = nil, style: W3WMarkerStyle = .circle) {
    W3WThread.runOnMain {
      if let w = words {
        W3WThread.runInBackground {
          self.show(self.convertToSquaresWithCoordinates(words: w), camera: camera, color: color, style: style)
        }
      }
    }
  }
  
  
  /// put a what3words annotation on the map showing the address
  public func show(_ coordinates: [CLLocationCoordinate2D]?, camera: W3WCenterAndZoom = .zoom, color: UIColor? = nil, style: W3WMarkerStyle = .circle) {
    W3WThread.runOnMain {
      if let c = coordinates {
        W3WThread.runInBackground {
          self.show(self.convertToSquares(coordinates: c), camera: camera, color: color, style: style)
        }
      }
    }
  }
  

  
  /// remove a what3words annotation from the map if it is present
  public func hide(_ suggestion: W3WSuggestion?) {
    if let words = suggestion?.words {
      hide(words)
    }
  }
  
  
  /// remove a what3words annotation from the map if it is present
  public func hide(_ words: String?) {
    if let w = words {
      checkConfiguration()
      w3wMapData?.w3w?.convertToCoordinates(words: w) { square, error in
        self.dealWithAnyApiError(error: error)
        if let s = square {
          self.hide(s)
        }
      }
    }
  }
  
  
  /// remove what3words annotations from the map if they are present
  public func hide(_ squares: [W3WSquare]?) {
    for square in squares ?? [] {
      hide(square)
    }
  }
  
  
  /// remove what3words annotations from the map if they are present
  public func hide(_ suggestions: [W3WSuggestion]?) {
    for suggestion in suggestions ?? [] {
      hide(suggestion)
    }
  }
  
  
  /// remove what3words annotations from the map if they are present
  public func hide(_ words: [String]?) {
    for word in words ?? [] {
      hide(word)
    }
  }
  
  
  
  /// remove a what3words annotation from the map if it is present
  /// this is the one that actually does the work.  The other remove calls
  /// end up calling this one.
  public func hide(_ square: W3WSquare?) {
    if let s = square {
      if let annotation = findPin(s) {
        removeAnnotation(annotation)
        hideOutline(s)
      }
    }
  }
  
  
  /// remove what3words annotations from the map if they are present
  public func hideAll() {
    for annotation in annotations {
      if let w3wAnnotation = annotation as? W3WAnnotation {
        removeAnnotation(w3wAnnotation)
        if let square = w3wAnnotation.square {
          hideOutline(square)
        }
      }
    }
  }
  

  
  func findPin(_ square: W3WSquare?) -> W3WAnnotation? {
    for annotation in annotations {
      if let a = annotation as? W3WAnnotation {
        if a.square?.words == square?.words || (a.square?.coordinates?.latitude == square?.coordinates?.latitude && a.square?.coordinates?.longitude == square?.coordinates?.longitude) {
          return a
        }
      }
    }
    
    return nil
  }
  
  
  
  /// add an annotation to the map given a square this compensates for missing words or missing
  /// coordiantes, and does nothing if neither is present
  /// this is the one that actually does the work.  The other addAnnotations calls end up calling this one.
  func addAnnotation(square: W3WSquare, color: UIColor? = nil, style: W3WMarkerStyle = .circle) {
    W3WThread.runOnMain {
      W3WThread.runInBackground {
        if let s = self.ensureSquareHasCoordinates(square: square) {
          W3WThread.runOnMain {
            self.hide(square)
            self.addAnnotation(W3WAnnotation(square: s, color: color, style: style))
          }
        }
      }
    }
  }
  
  
  /// make a custom annotation view
  func pinView(annotation: W3WAnnotation) -> MKAnnotationView? {
    let identifier = "w3wPin"

    // marker size
    var aframe = CGRect(x: 0.0, y: 0.0, width: W3WSettings.pinSize, height: W3WSettings.pinSize)
    
    // if marker is a pin then set it up a little higher, if it's a circle make it half size
    if annotation.style == .pin {
      aframe = CGRect(x: 0.0, y: 0.0, width: W3WSettings.pinSize, height: W3WSettings.pinSize * 1.25)
    } else if annotation.style == .circle {
      aframe = CGRect(x: 0.0, y: 0.0, width: W3WSettings.pinSize / 2.0, height: W3WSettings.pinSize / 2.0)
    }
    
    // make the image
    let pin = W3WMapPin(frame: aframe, text: annotation.square?.words, style: annotation.style, color: annotation.colour)
    let pinImage = pin.asImage()
    
    let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
    annotationView.image = pinImage
    annotationView.centerOffset = pin.getOffset()
    annotationView.canShowCallout = true
    
    return annotationView
  }
  
  
  func getMapPinView(annotation: W3WAnnotation) -> MKAnnotationView? {
    return pinView(annotation: annotation)
  }
  
  
  /// force a redrawing of all annotations
  func redrawPins() {
    for annotation in annotations {
      removeAnnotation(annotation)
      addAnnotation(annotation)
    }
  }
  
  

  
  
  
  
  
  // MARK: Map Camera
  
  
  /// set the map center to a coordinate, and set the minimum visible area
  func set(center: CLLocationCoordinate2D) {
    W3WThread.runOnMain {
      self.setCenter(center, animated: true)
    }
  }
  
  
  /// set the map center to a coordinate, and set the minimum visible area
  func set(center: CLLocationCoordinate2D, latitudeSpanDegrees: Double, longitudeSpanDegrees: Double) {
    W3WThread.runOnMain {
      let coordinateRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latitudeSpanDegrees, longitudeDelta: longitudeSpanDegrees))
      self.setRegion(coordinateRegion, animated: true)
    }
  }
  
  
  /// set the map center to a coordinate, and set the minimum visible area
  func set(center: CLLocationCoordinate2D, latitudeSpanMeters: Double, longitudeSpanMeters: Double) {
    W3WThread.runOnMain {
      let coordinateRegion = MKCoordinateRegion(center: center, latitudinalMeters: latitudeSpanMeters, longitudinalMeters: longitudeSpanMeters)
      self.setRegion(coordinateRegion, animated: true)
    }
  }
  

  /// sets the size of a square after .zoom is used in a show() call
  /// - Parameters:
  ///     - zoomInPointsPerSquare: the size that squares should be, measured in points (1/163 of an inch), after a .zoom
  public func set(zoomInPointsPerSquare: CGFloat) {
    w3wMapData?.visibleZoomPointsPerSquare = zoomInPointsPerSquare
  }
  
  
  
  
  
  // MARK: Grid Squares
  
  

  /// makes overlays from the squares
  func updateSquares() {
    var boxes = [MKPolyline]()
    
    for square in w3wMapData?.squares ?? [] {
      if let ne = square.northEastBounds, let sw = square.southWestBounds {
        let nw = CLLocationCoordinate2D(latitude: ne.latitude, longitude: sw.longitude)
        let se = CLLocationCoordinate2D(latitude: sw.latitude, longitude: ne.longitude)
        boxes.append(W3WMapSquareLines(coordinates: [nw, ne, se, sw, nw], count: 5))
      }
    }
    
    W3WThread.runOnMain {
      self.removeSquareOverlays()
      for square in boxes {
        self.addOverlay(square)
      }
    }
  }
  
  
  func showOutline(_ square: W3WSquare) {
    if findSquare(square) == nil {
      W3WThread.runInBackground {
        if let s = self.ensureSquareHasCoordinates(square: square) {
          self.w3wMapData?.squares.append(s)
        }
        self.updateSquares()
      }
    }
  }
  
  
  func hideOutline(_ square: W3WSquare) {
    w3wMapData?.squares.removeAll(where: { s in
      return s.words == square.words || (s.coordinates?.latitude == square.coordinates?.latitude && s.coordinates?.longitude == square.coordinates?.longitude)
    })
    updateSquares()
  }
  
  
  func isShowingOutline(_ square: W3WSquare) -> Bool {
    return findSquare(square) != nil
  }
  
  
  /// remove the grid overlay
  func removeSquareOverlays() {
    for overlay in overlays {
      if let squareOverlay = overlay as? W3WMapSquareLines {
        self.removeOverlay(squareOverlay)
      }
    }
  }
  
  
  
  func getMapSquaresRenderer(overlay: MKOverlay) -> MKOverlayRenderer? {
    
    if #available(iOS 13, *) {
      if let squares = overlay as? W3WMapSquareLines {
        let squaresRenderer = W3WMapSquaresRenderer(overlay: squares)
        squaresRenderer.lineWidth = W3WSettings.mapSquareLineThickness
        
        // use dark mode colour scheme for satilite views
        squaresRenderer.strokeColor = (mapType == .standard || mapType == .mutedStandard) ? W3WSettings.color(named: "MapSquareColor") : W3WSettings.color(named: "MapSquareColor", forMode: .dark)
        
        return squaresRenderer
      }
    }
    
    return nil
  }
  
  
  // MARK: Utility
  
  
  func checkConfiguration() {
    if w3wMapData == nil {
      onError(W3WMapError.mapNotConfigured)
    }
  }
  
  
  
  func findSquare(_ square: W3WSquare) -> W3WSquare? {
    for s in w3wMapData?.squares ?? [] {
      if s.words == square.words || (s.coordinates?.latitude == square.coordinates?.latitude && s.coordinates?.longitude == square.coordinates?.longitude) {
        return s
      }
    }
    
    return nil
  }
  
  
  func convertToSquaresWithCoordinates(suggestions: [W3WSuggestion]) -> [W3WSquare] {
    var squares = [W3WSquare]()
    
    for suggestion in suggestions {
      squares.append(W3WApiSquare(words: suggestion.words))
    }
    
    return ensureSquaresHaveCoordinates(squares: squares)
  }
  
  
  func convertToSquaresWithCoordinates(words: [String]) -> [W3WSquare] {
    var squares = [W3WSquare]()
    
    for word in words {
      squares.append(W3WApiSquare(words: word))
    }
    
    return ensureSquaresHaveCoordinates(squares: squares)
  }
  
  
  func convertToSquares(coordinates: [CLLocationCoordinate2D]) -> [W3WSquare] {
    var squares = [W3WSquare]()
    
    for coordinate in coordinates {
      squares.append(W3WApiSquare(coordinates: coordinate))
    }
    
    return ensureSquaresHaveCoordinates(squares: squares)
  }
  
  
  func ensureSquareHasCoordinates(square: W3WSquare) -> W3WSquare? {
    let s = ensureSquaresHaveCoordinates(squares: [square])
    return s.first
  }
  
  
  func ensureSquaresHaveCoordinates(squares: [W3WSquare]) -> [W3WSquare] {
    checkConfiguration()
    if W3WThread.isMain() {
      print(#function, " must NOT be called on main thread")
      abort()
    }
    
    var goodSquares = [W3WSquare]()
    
    let tasks = DispatchGroup()
    
    // for each square, make sure it is complete with coordinates and words
    for square in squares {
      tasks.enter()
      complete(square: square) { completeSquare in
        if let s = completeSquare {
          goodSquares.append(s)
        }
        tasks.leave()
      }
    }

    // wait for all the squares to be completed
    tasks.wait()
    
    return goodSquares
  }

  
  /// check a square and fill out it's words or coordinates as needed, then return a completed square via completion block
  func complete(square: W3WSquare, completion: @escaping (W3WSquare?) -> ()) {

    // if the square has words but no coordinates
    if square.coordinates == nil {
      if let words = square.words {
        self.w3wMapData?.w3w?.convertToCoordinates(words: words) { result, error in
          self.dealWithAnyApiError(error: error)
          completion(result)
        }
        
      // else if the square has no words and no coordinates then it is useless and we omit it
      } else {
        completion(nil)
      }
      
    // else if the square has coordinates but no words
    } else if square.words == nil {
      if let coordinates = square.coordinates {
        self.w3wMapData?.w3w?.convertTo3wa(coordinates: coordinates, language: self.w3wMapData?.language ?? W3WSettings.defaultLanguage) { result, error in
          self.dealWithAnyApiError(error: error)
          completion(result)
        }
        
      // else if the square has no words and no coordinates then it is useless and we omit it
      } else {
        completion(nil)
      }
      
    // else the square already has coordinates and words
    } else {
      completion(square)
    }
  }
  
  
  /// force a redrawing of all highlighted squares
  func redrawSquares() {
    updateSquares()
  }

  
  /// check fro error and if there is one, report it
  func dealWithAnyApiError(error: W3WError?) {
    if let e = error {
      self.onError(W3WMapError.apiError(error: e))
    }
  }
  
}


#endif
