# <img valign='top' src="https://what3words.com/assets/images/w3w_square_red.png" width="64" height="64" alt="what3words">&nbsp;AutoSuggest Component

The AutoSuggest Components

Overview
--------

This document covers `W3WAutoSuggestTextField` and `W3WAutoSuggestSearchController`, because they both conform to our `W3WAutoSuggestTextFieldProtocol` for returning any addresses the user choses, as well as to set options.

<img src="autosuggest.png" width="250">

These components depend on [what3words swift wrapper](https://github.com/what3words/w3w-swift-wrapper).

TLDR
----

Too long? Don't want to read? Jump to a comprehensive [example here](#tldrex).

A step by step tutorial for putting `W3WAutoSuggestTextField` into your app can be found [here](tutorial-textfield.md)


Example Projects
----------------

There are examples of both in this package:

#### W3WAutoSuggestTextField

An iOS UIKit example embedding a W3WAutoSuggestTextFieldcan be found at: [Examples/TextField/TextField.xcodeproj](../Examples/TextField/TextField.xcodeproj)

#### W3WAutoSuggestSearchController

An iOS UIKit example embedding a W3WAutoSuggestSearchController in a UINavigationController: [Examples/SearchController/SearchController.xcodeproj](../Examples/SearchController/SearchController.xcodeproj)

Usage
------------

### Initialise

Two text components are provided:

 - `W3WAutoSuggestTextField` is derived from `UITextField`
 - `W3WAutoSuggestSearchController` is derived from `UISearchController`.

Importantly, these both conform to our `W3WAutoSuggestTextFieldProtocol`, which describes [all the functions](#reference) you will use to interact with them.

##### Instantiate W3WAutoSuggestTextField

```
let textField = W3WAutoSuggestTextField(frame: CGRect(x: 32.0, y: 320.0, width: 300.0, height: 32.0))
``` 

##### Instantiate W3WAutoSuggestSearchController

```
let textField = W3WAutoSuggestSearchController()
``` 

### Configure

Whether you use `W3WAutoSuggestTextField` or `W3WAutoSuggestSearchController`, you must give it access to either the API or the SDK to that it can make `autosuggest` calls.  Here's how to initialize them and configure the text field of your choice:

##### Using the [API](https://github.com/what3words/w3w-swift-wrapper):

```swift
let api = What3WordsV3(apiKey: "YourApiKey")
textField.set(api)
```

##### Or, if you have a licensed copy of our [SDK](https://developer.what3words.com/enterprise-suite/mobile-offline-sdk):

```swift
let sdk = What3Words(dataPath: "/path/to/w3w-data")
textField.set(sdk)
```

More information about our SDK can be found [here](https://developer.what3words.com/enterprise-suite/mobile-offline-sdk).

### Deploy

`W3WAutoSuggestTextField` and `W3WAutoSuggestSearchController` may be used anywhere a `UITextField` or `UISearchController` would be used as they are derived from them.

You might add `W3WAutoSuggestTextField` to your ViewController's view:

```swift
viewController.view.addSubview(textField)
```

Or embed `W3WAutoSuggestSearchController` in your NavigationController:

```swift
navController.navigationItem.searchController = textField
```

### Employ

To be informed when the user chooses a suggestion from the list, assign a closure to `onSuggestionSelected`.  It is called with a struct that conforms to the `W3WSuggestion` protocol.  

```swift
textField.onSuggestionSelected = { suggestion in
  print("User chose:", suggestion.words ?? "")
}
```

### Options

You may set any of the autosuggest options for these text fields.  If you use voice search, then these options will be automatically applied to that as well.

You may specify options as an array of `W3WOption`, or using the `W3WOptions` builder: 

```
let options = [
  W3WOption.clipToCountry("GB"),
  W3WOption.focus(CLLocationCoordinate2D(latitude: 50.0, longitude: 0.1))
]
```
```    
let options = W3WOptions().clipToCountry("GB").focus(CLLocationCoordinate2D(latitude: 50.0, longitude: 0.1))
```

Either way, you can set them like this:

```
textField.set(options: options)
```

We **strongly suggest** that you use the **focus option**, especially for voice, to help autosuggest rank results more accurately.

Documentation and examples using options in Swift can be found in [Documentation/options.md](options.md)

<a name="tldrex"></a>
Example Code Snippets
---------------------


### W3WAutoSuggestTextField with API

To set up a `W3WAutoSuggestTextField` in the `viewDidLoad()` of your `ViewController`:

```swift
override func viewDidLoad() {
  super.viewDidLoad()

  let api = What3WordsV3(apiKey: "YourApiKey")
  let textField = W3WAutoSuggestTextField(frame: CGRect(x: 32.0, y: 160.0, width: 300.0, height: 32.0))

  textField.set(api)
  
  let coords = CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.34745)
  textField.set(options: W3WOption.focus(coords))

  textField.onSuggestionSelected = { suggestion in
    print("User chose:", suggestion.words ?? "")
  }

  view.addSubview(textField)
}
```

<a name="reference"></a>
Reference
---------

Both components conform to our `W3WAutoSuggestTextFieldProtocol` for returning any addresses the user choses, as well as to set options:


#### func set()  

* `func set(_ w3w: W3WProtocolV3, language: String)` - Gives what3words to the component, in the form of either the API or the SDK.  `language` is a two letter language code.  If omitted, it will default to `"en"` (English).
* `func set(includeCoordinates: Bool)` - This causes the component to use the converToCoordinates call to return coordinates with the results, which may count against your quota.  They are returned in as a W3WSquare which is a W3WSuggestion with coordinates included
* `func set(freeformText: Bool)` - Setting this to `false` will disallow the user to type any characters except legal three word address characters.
* `func set(allowInvalid3wa: Bool)` - `true` by default.  Setting this to false will stop the field from clearing when it looses focus.
* `func set(language l: String)` - accepts a two letter language code
* `func set(voice: Bool)` - turns voice recignition on or off
* `func set(options: W3WOptions)` - sets [autosuggest options](options.md)
* `func set(options: [W3WOption])` - sets [autosuggest options](options.md)
* `func set(options: W3WOption)` - sets one [autosuggest option](options.md)
  
#### var onSuggestionSelected

`var onSuggestionSelected: (W3WSuggestion) -> ()`

Use this to assign a closure to be executed when a user chooses a W3WSuggestion.  Example:

```
textField.onSuggestionSelected = { suggestion in
  print("User chose:", suggestion.words ?? "")
}
```  

  
#### var textChanged  
  
`var textChanged: (String?) -> ()`

You can receive updates when the text in the field changes by assigning a closure to `textChanged`. Example:

```
textField.textChanged = { text in
  print("TEXT: ", text ?? "none")
}
```




