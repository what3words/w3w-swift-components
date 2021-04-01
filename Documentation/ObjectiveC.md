# <img valign='top' src="https://what3words.com/assets/images/w3w_square_red.png" width="64" height="64" alt="what3words">&nbsp;Objective-C and W3W Components

Overview
--------

This explains how to add what3words iOS components to your Objective C project.

While this is implemented in Swift, it is compatible with Objective C and designed to be used excusively with Objective C.  The thinking is that it made more sense to provide a light ObjC wrapper and maintain a pure Swift project than to infuse @obj directives throughout the entire code base, and to adjust for peculiarities of NSObject derived Swift classes.

Two text components are provided:

 - `W3WObjcAutoSuggestTextField` is derived from `UITextField`
 - `W3WAutoSuggestSearchController` is derived from `UISearchController`.

Other than the differences of the base classes, these both have the same interface.

TLDR
----

Too long? Don't want to read? Jump to the [example at the end of this document](#tldr), or go to the [Objective-C tutorial](ObjectiveCTutorial.md) document.


Installation
------------


#### Authentication
To use this library you’ll need a what3words API key, which can be signed up for [here](https://what3words.com/select-plan).  If you wish to use the Voice API calls then you must add a Voice API plan to your [account](https://accounts.what3words.com/billing).

#### Swift Package Manager

You can install with [Swift Package Manager](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) by adding the URL below to Swift Packages under your project settings:

```
https://github.com/what3words/w3w-swift-components.git
```

Import the libraries into your Objective-C code:

```objective-c
@import W3WSwiftComponents;
@import W3WSwiftApi;
#import <MapKit/MapKit.h>
```

##### Note:

If you are using the Voice API on device, you should include Microphone permissions in your Info.plist

Usage
-----

#### Setup

```objective-c
// some coordinates for the component
CGRect frame = CGRectMake(16.0, 300.0, self.view.frame.size.width - 32.0, 32.0);

// make the textfield
W3WObjcAutoSuggestTextField *textfield = [[W3WObjcAutoSuggestTextField alloc] initWithFrame:frame];

/// Assign the API key
[textfield setApiKey: @"YourApiKey"];

// Add it to your view
[self.view addSubview:textfield];
```


#### Callbacks

To be notified when the user selects an address:

```objective-c
[textfield setSuggestionCallback: ^(W3WObjcSuggestion *suggestion) {
  NSLog(@"%@", suggestion.words);
}];
```

To be notified about errors:

```objective-c
[textfield setErrorCallback: ^(NSError *error) {
  NSLog(@"Error: %@", error.localizedDescription);
}];
```

If you want to monitor the user input keystroke by keystroke

```objective-c
[textfield setTextChangedCallback: ^(NSString *text) {
  NSLog(@"%@", text);
}];
```

### Options

Options alter the behaviour of the autosuggest function and filter the addresses that are presented to the user.  For example, you can set an `ClipToCountry` option so that only addresses in a particular country are shown.

It is *strongly recoomended* that you at least set the focus option so that addresses nearest your user get priority.

Options are set using the `W3WObjcOptions` object:

```objective-c
// Make an option object
W3WObjcOptions *options = [[W3WObjcOptions alloc] init];

// Add any options you want
[options addFocus: CLLocationCoordinate2DMake(51.520847,-0.195521)];
[options addClipToCountry: @"GB"];

// Finally, set these options on the component:
[textfield setOptions: options];
```


<a name="tldr"></a>
### Example

Here is an example of presenting a W3WObjcAutoSuggestTextField in UIViewcontroller's viewDidLoad:

```objective-c
@import W3WSwiftComponents;
@import W3WSwiftApi;


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // some coordinates for the component
  CGRect frame = CGRectMake(16.0, 300.0, self.view.frame.size.width - 32.0, 32.0);
  
  // make the autosuggest component
  W3WObjcAutoSuggestTextField *textfield = [[W3WObjcAutoSuggestTextField alloc] initWithFrame:frame];

  // assign the API key an set the desired langauge
  [textfield setApiKey:@"YourApiKey"];
  [textfield setLanguage:@"en"];
  
  // make focus and countryClipping options
  W3WObjcOptions *options = [[W3WObjcOptions alloc] init];
  [options addFocus: CLLocationCoordinate2DMake(51.520847,-0.195521)];
  [options addClipToCountry: @"GB"];
  [textfield setOptions: options];
  
  // add the component to the view
  [self.view addSubview:textfield];

  // print out any address that the user chooses
  [textfield setSuggestionCallback: ^(W3WObjcSuggestion *suggestion) {
    NSLog(@"%@", suggestion.words);
  }];
  
  // print out any error
  [textfield setErrorCallback: ^(NSError *error) {
    NSLog(@"Error: %@", error.localizedDescription);
  }];

}

@end
```

### Method Reference

#### setApi

Set the API key

`  [textfield setApiKey:@"YourApiKey"];`

#### setLangauge

Set the expected input language.  Defaults to English.

`  [textfield setLanguage:@"en"];`

#### setVoice

Turn on voice recognition if available.  Set to true by default

`[textfield setVoice: YES];`

#### setAllowInvalid3wa

This prevents the component from sending an error if the user leaves the field without entering a valid three word address.  Default is `NO`.
  
`[textfield setAllowInvalid3wa: YES];'

#### setFreeformText

Allows any character to be typed in.  Defaults to `YES`.  If set to `NO` then all characters that are not part of a valid three word address will not be registered or displayed.

`[textfield setFreeformText:NO];`

#### setOptions
  
Sets the options to use when calling autosuggest
  
`[textfield setOptions: options];`  


#### setSuggestionCallback

Sets a closure that gets called when the user selects an address  
  
```
[textfield setSuggestionCallback: ^(W3WObjcSuggestion *suggestion) {
  NSLog(@"%@", suggestion.words);
}];
```

#### setErrorCallback

Sets a closure that gets called when there is an error
  
```
[textfield setErrorCallback: ^(NSError *error) {
  NSLog(@"Error: %@", error.localizedDescription);
}];
```  
  
#### setTextChangedCallback

Sets a closure that gets called when the text in the textfield changes

```
[textfield setTextChangedCallback: ^(NSString *text) {
  NSLog(@"%@", text);
}];
```  
 
### W3WObjcSuggestion

This object contains the values for a suggestion

```
NSString *words
NSString *country
NSString *nearestPlace
NSString *distanceToFocus
NSString *language
```

### W3WObjcOptions

To fully understand the options please read the options section in the [API documentation](https://developer.what3words.com/public-api/docs).

#### addFocus

Provides addresses sorted by relavance to a location

`[options addFocus: CLLocationCoordinate2DMake(51.520847,-0.195521)];`

#### addClipToCountry

Restricts addresses to only one country

`[options addClipToCountry: @"GB"];`


#### addClipToCountries

Restricts results to a list of countries

`[options addClipToCountries: @[@"GB", @"CA"]];`

#### addVoiceLanguage

Sets the language to use for voice input

`[options addVoiceLanguage: @"en"];`

#### addClipToCircle:radius

Restricts results to a geographic circle

`[options addClipToCircle: CLLocationCoordinate2DMake(50.0, -0.1) radius: 10.0];`

#### addClipToBoxSouthWest:northEast

Restricts results to a geographic rectangle

`[options addClipToBoxSouthWest:CLLocationCoordinate2DMake(51.51481,-0.204366) northEast:CLLocationCoordinate2DMake(51.535589,-0.168336)];`

#### addPreferLand

Gives preference to land based addresses.  Default is `YES`

`[options addPreferLand: NO];`

#### addClipToPolygon

Clips resutls to a geographic poliganal shape.

```
  [options addClipToPolygon: @[
    [NSValue valueWithMKCoordinate:CLLocationCoordinate2DMake(51.51481,-0.204366)],
    [NSValue valueWithMKCoordinate:CLLocationCoordinate2DMake(51.56378,-0.329019)],
    [NSValue valueWithMKCoordinate:CLLocationCoordinate2DMake(51.535589,-0.168336)],
    [NSValue valueWithMKCoordinate:CLLocationCoordinate2DMake(51.402153,-0.075661)],
    [NSValue valueWithMKCoordinate:CLLocationCoordinate2DMake(51.51481,-0.204366)]
  ]];
```





