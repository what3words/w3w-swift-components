# <img valign='top' src="https://what3words.com/assets/images/w3w_square_red.png" width="64" height="64" alt="what3words">&nbsp;Objective-C Autosuggest Tutorial

Overview
--------

This is a tutorial for using `W3WObjcAutoSuggestTextField`.

<img src="autosuggest.png" width="250">

`W3WObjcAutoSuggestTextField` is derived from `UITextField`



Installation
------------


#### Authentication
To use this library you’ll need a what3words API key, which can be signed up for [here](https://what3words.com/select-plan).  If you wish to use the Voice API calls then you must add a Voice API plan to your [account](https://accounts.what3words.com/billing).

#### Install Components

Add the Swift Package at [https://github.com/what3words/w3w-swift-components](https://github.com/what3words/w3w-swift-components) to your project:

```
https://github.com/what3words/w3w-swift-components.git
```

1. From Xcode's `File` menu choose `Swift Packages` then `Add Package Dependancy`.  
2. The `Choose Package Repository` window appears.  Add [https://github.com/what3words/w3w-swift-components.git](https://github.com/what3words/w3w-swift-components.git) in the search box, and click on `Next`. 
3. If you are satisfied with the selected version branch choices, click `Next` again.
4. You should then be shown "Package Product" `W3WSwiftComponents`.  Choose `Finish`.

Xcode should now automatically install `w3w-swift-components`, and `w3w-swift-api`

<img src="swiftpm.png" width="640" style="padding: 16px;">

#### Write Code

Import the libraries into your Objective-C code:

```objective-c
@import W3WSwiftComponents;
@import W3WSwiftApi;
#import <MapKit/MapKit.h>
```

Add the following to your view controller's `-(void)viewDidLoad`:


```objective-c
- (void)viewDidLoad {
  [super viewDidLoad];

  // some coordinates for the component
  CGRect frame = CGRectMake(16.0, 64.0, self.view.frame.size.width - 32.0, 32.0);
  
  // make the autosuggest component
  W3WObjcAutoSuggestTextField *textfield = [[W3WObjcAutoSuggestTextField alloc] initWithFrame:frame];

  // assign the API key an set the desired language
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
```

#### Run The App

Give the app a run; type 'filled.count.soa' into the text field, and you should see:

<img src="phone.png" style="padding: 16px;">

If you get an error, check that you used your own API key.

#### Voice Support

If your API key has been given Voice API privilege, then you can add the following line to enable it:

```
[textfield setVoice: YES];
```
