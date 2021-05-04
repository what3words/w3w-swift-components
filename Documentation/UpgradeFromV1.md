# <img valign='top' src="https://what3words.com/assets/images/w3w_square_red.png" width="64" height="64" alt="what3words">&nbsp;Upgrading from v1 to v2


Overview
--------

Version 2 of this repository includes the version 1.3.0 autosuggest component which is depreciated.  Also the module name has changed.

The GitHub repository name has changed from `w3w-autosuggest-textfield-swift` to `w3w-swift-components`.  The old URL redirects to the new one.

This represents our intention to offer more than just the text field component.  In version 2.0.0 we also introduced a component based on `UISearchController`.

Installing
----------

The components are now best installed using Swift Package Manager.  See the instructions in our [documentation](https://github.com/what3words/w3w-swift-components/blob/master/Documentation/autosuggest.md).

Importing
---------

The module name has changed, and the API wrapper has been separated from the package and has been made a dependancy, so anywhere you currently have:

```swift
import W3wSuggestionField
```

Change this to:

```swift
import W3WSwiftApi
import W3WSwiftComponents
```

Usage
-----

With version 1.0 you might have used the component like this:

```swift
let suggestionField = W3wTextField()
suggestionField.setAPIKey(APIKey: "YourApiKey")
```

This will still work, but it will instantiate the old v1 component.  However, it is ***very strongly reccomended*** that you use the new component because `W3wTextField` is not being actively updated and will be removed from a future release.  

The new way to do this is:

```swift
let api = What3WordsV3(apiKey: "YourApiKey")
let textField = W3WAutoSuggestTextField(frame: yourFieldsDimensions)
textField.set(api)
```

#### Differences

| v1 | v2 |
|----|----|
|setAPIKey(APIKey:String)|set(What3WordsV3)|
|didSelect| suggestionSelected |

##### set(What3WordsV3):

```swift
let api = What3WordsV3(apiKey: "YourApiKey")
textField.set(api)
```

##### suggestionSelected:

```swift
textField.suggestionSelected = { suggestion in
  print("User chose:", suggestion.words ?? "")
}
```

#### Additional functionality

Version 2 has more functionality.  See the Reference section of the Autosuggest Component documentation [here](https://github.com/what3words/w3w-swift-components/blob/master/Documentation/autosuggest.md#reference).

