# <img valign='top' src="https://what3words.com/assets/images/w3w_square_red.png" width="64" height="64" alt="what3words">&nbsp;Map Views


Overview
--------
<img src="map.png" width="140" style="float: right; padding: 16px;">

This document covers the functions available in all what3words map components. 

These functions are defined in the `W3WMapViewProtocol` protocol.  

The `W3WMapHelper`, `W3WMapView` and `W3WMapViewController` classes all conform to `W3WMapViewProtocol`.

`W3WMapView` is a `MKMapView`, and `W3WMapViewController` is a `UIViewController` which provides a simple interactive map which can return `W3WSuggestion`s on user selection.  `W3WMapHelper` conforms to `MkMapViewDelegate` and is designed to be an easy way to get what3words functionality into your existing map view.

These components depend on [what3words swift wrapper](https://github.com/what3words/w3w-swift-wrapper) for common what3words type definitions. 

Reference
---------

### set(language: String)

Set language will set the default language for all the calls that the map makes to the API (or SDK if you use that instead).

**examples**

```
map.set(language: "fr") // set default language to French
```

----------------

### addMarker(at: _, camera: W3WCenterAndZoom, color: UIColor?, style: W3WMarkerStyle)

Show will place an annotation on the map, if the map is zoomed in, it will appear as a square, and if zoomed out it shows as a what3words annotation icon.

`addMarker(at:camera:color)` takes one required parameter, and two optional ones.

The first is the location, this can be a what3words address as a `String`, or a `W3WSuggestion`, `W3WSquare`, or a `CLLocatioinCorrdinate2D`, or it can be an array of any of those.  

Note that if you pass in a `String`, or `W3WSuggestion`, a call to `convertToCoordinates` will be made automatically to get the coordinates, and this will count towards your account quota.  This parameter can also be an array of any of the above mentioned types.

The second and optional parameter is called `camera` and it indicates how to move the map view.  The choices are:

* `.zoom` - zooms the map in to the location right around the square
* `.center` - adjusts the map's center so that the location is in the center, but does not zoom in
* `.none` - this leaves the mapView showing the same area it was showing before the call

The third and optional parameter is `color` which takes a `UIColor` color for the annotation.  This defaults to what3words brand's red.

**examples**

```
map.addMarker(at:square, camera: .zoom)

map.addMarker(at:"filled.count.soap", style: .pin)

map.addMarker(at:["filled.count.soap", "index.home.raft"], camera: .center)

map.addMarker(at:["filled.count.soap", "index.home.raft"], color: .blue, camera: .center)
```

----------------

### removeMarker(at:)

This will hide an annotation that was previously placed on the map.  It takes one parameter and like `show()`, it can be a what3words address as a `String`, or a `W3WSuggestion`, `W3WSquare`, or a `CLLocatioinCorrdinate2D`, or arrays of those types.

**examples**

```
map.removeMarker(at: square)

map.removeMarker(at: "filled.count.soap")

map.removeMarker(at: ["filled.count.soap", "index.home.raft"])
```

----------------

### removeAllMarkers()

This will remove all what3words annotations, and squares from the map.

**examples**

```
map.removeAllMarkers()
```

----------------

### set(zoomInPointsPerSquare: CGFloat)

This will set how near the `addMarker(at: "filled.count.soap", camera: .zoom)` calls will zoom.

`zoomInPointsPerSquare` is the size of squares in points when .zoom is used in a show() call.  (points being 1x, 2x, 3x a pixel depending on which device you are using and if it has a "retina" display.


------------

### getMapAnnotationView(annotation: MKAnnotation) -> MKAnnotationView?

If the annotation is a what3words one, this gets a renderer, otherwise it returns nil.

If you are using `W3WMapHelper` then this is typically called in your `MKMapViewDelegate`'s call: `mapView(_, viewFor: MKAnnotation)`

----------------

### updateMap()

Updates the map view with annotations and lines.  

If you are using `W3WMapHelper` then this is typically called in your `MKMapViewDelegate`'s calls: `mapViewDidChangeVisibleRegion()` `mapView(_, regionWillChangeAnimated)`, and `mapView(_, regionDidChangeAnimated)`.

----------------

### mapRenderer(overlay: MKOverlay) -> MKOverlayRenderer?

This gets a renderer for the what3words grid if it is given a `W3WMapGridLines` or `W3WMapSquareLines` overlay, otherwise it returns nil.

If you are using `W3WMapHelper` then this is typically called in your `MKMapViewDelegate`'s call: `mapView(_, rendererFor: MKOverlay)`

