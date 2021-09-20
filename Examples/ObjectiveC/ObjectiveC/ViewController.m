//
//  ViewController.m
//  ObjectiveC
//
//  Created by Dave Duprey on 01/04/2021.
//

@import W3WSwiftComponents;
@import W3WSwiftApi;
#import <MapKit/MapKit.h>
#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

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


@end
