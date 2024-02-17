# <img valign='top' src="https://what3words.com/assets/images/w3w_square_red.png" width="64" height="64" alt="what3words">&nbsp;AutoSuggest  Options for Swift


Overview
--------

You may set autosuggest options for a number of what3words components including `W3WAutoSuggestTextField`, `W3WAutoSuggestSearchController`, and any other w3w components that satisfy the `W3WOptionAcceptorProtocol` protocol.

If you use voice search, then these options will be automatically applied to that as well.

Option Types
------------

You may specify options as an array of `W3WOption`, or using the `W3WOptions` builder: 

```
let options = [
  W3WOption.clip(to: W3WBaseCountry(code: "GB")),
  W3WOption.focus(CLLocationCoordinate2D(latitude: 50.0, longitude: 0.1))
]
```
Or:

```    
let options = W3WOptions().focus(CLLocationCoordinate2D(latitude: 50.0, longitude: 0.1)).clip(to: W3WBaseCountry(code: "GB"))
```

Set()
-------------------

Whether you choose an option array or the builder pattern, you can set them like this:

```
w3wComponent.set(options: [W3WOption.clip(to: W3WBaseCountry(code: "GB"))])
```

```
w3wComponent.set(options: W3WOption.clip(to: W3WBaseCountry(code: "GB")))
```

Every call to `set(options:)` *resets* all the options.  This is a `set()` and not an `add()` function.

# W3WOption

`W3WOption` is an enum with each case carrying a parameter representing one possible option.  `W3WOptions` is a class that contains an array of `W3WOption`.

Here are the case values of W3WOption:

focus(CLLocationCoordinate2D)
----------------

We strongly suggest usage of at least the focus option, especially for voice, to help autosuggest rank results more accurately.  

The what3words system was designed with this in mind keeping similar sounding addresses as far apart as possible in order to reduce error of misunderstanding by humans and computers.

#### Example:

```
let coords = CLLocationCoordinate2D(latitude: 50.0, longitude: 0.1)
w3wComponent.set(options: W3WOption.focus(coords))
```

clipToCountry(W3WCountry) / clipToCountries([W3WCountry])
----------------
Filter results by country.  You can choose more than on country also:

```
w3wComponent.set(options: [W3WOption.clip(to: W3WBaseCountry(code: "GB"))])
```
```
w3wComponent.set(options: [W3WOption.clipToCountries(W3WBaseCountries(countries: [gb, ca, nz, au])])
```

clipToCircle(center:CLLocationCoordinate2D, radius: Double)
----------------
Filter results by a circle area:

```
let coord = CLLocationCoordinate2D(latitude: 51.520847, longitude: -0.195521)
w3wComponent.set(options: [W3WOption.clipToCircle(center: coord, radius: 10.0)])
```

clipToBox(southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D)
----------------
Filter results by a rectangular area:

```
let southWest = CLLocationCoordinate2D(latitude: 51.51481, longitude: -0.204366)
let northEast = CLLocationCoordinate2D(latitude: 51.535589, longitude: -0.168336)
w3wComponent.set(options: [W3WOption.clipToBox(southWest: southWest, northEast: northEast)])
```

clipToPolygon([CLLocationCoordinate2D])
----------------
Filter results with an poligonal area.

Points of the polygon, are given as an array of `CLLocationCoordinate2D`, where the last coordinate must be the same as the first:

```
let p0 = CLLocationCoordinate2D(latitude: 51.51481, longitude: -0.204366)
let p1 = CLLocationCoordinate2D(latitude: 51.56378, longitude: -0.329019)
let p2 = CLLocationCoordinate2D(latitude: 51.535589, longitude: -0.168336)
let p3 = CLLocationCoordinate2D(latitude: 51.402153, longitude: -0.075661)
w3wComponent.set(options: [W3WOption.clipToPolygon([p0, p1, p2, p3, p1])])
```
language(W3WLanguage)
----------------
Ask for results in a particulalr language.  Language object must be instantiated with an ISO 639-1 2 letter code, such as 'en' or 'fr'.

```
w3wComponent.set(options: [W3WOption.language("fr")])
```

voiceLanguage(W3WLanguage)
----------------
Ask for results from the voice API in a particulalr language.  Language object must be instantiated with an ISO 639-1 2 letter code, such as 'en' or 'fr'.

```
w3wComponent.set(options: [W3WOption.voiceLanguage("ar")])
```

Others
----------------
`inputType(W3WInputType)` is used if you are calling autosuggest with the output of a particular voice recognition system.  It doesn't apply to this component library

`numberOfResults(Int)` sets the number of results returned in an autosuggest call.  It defaults to 3 and it is reccomended that applicaitons use the default for best results and user experience.

`numberFocusResults(Int)` sets the number of results that will be sorted by the focus option.  It is reccomended that applicaitons do not use this, and let the system choose, for best results and user experience.

`preferLand(Bool)` defaults to true.  Unless your application deals mostly with locations in the ocean it's best to leave this default.
