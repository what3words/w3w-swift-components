import XCTest
@testable import W3WSwiftComponents
import W3WSwiftApi

final class w3w_swift_componentsTests: XCTestCase {
  
  var api: What3WordsV3!
  
  override func setUp() {
    super.setUp()
    
    if let apikey = ProcessInfo.processInfo.environment["APIKEY"] {
      api = What3WordsV3(apiKey: apikey)
    } else {
      print("Environment variable APIKEY must be set")
      abort()
    }
  }
  

  
  func testTextfield() {
    let expectation = self.expectation(description: "W3W Components")
    
    let vc = UIViewController()
    let field = W3WAutoSuggestTextField(api)
    vc.view.addSubview(field)
    
    let twa = "filled.count.soa"
    _ = field.textField(field, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: twa)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
      XCTAssertTrue(field.autoSuggestViewController.autoSuggestDataSource.suggestions.count == 3)
      XCTAssertTrue(field.autoSuggestViewController.autoSuggestDataSource.suggestions[0].words == "filled.count.soap")
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 10.0, handler: nil)
  }
  
  
  func testSearchController() {
    let expectation = self.expectation(description: "W3W Components")
    
    let field = W3WAutoSuggestSearchController()
    field.set(api)
    
    let twa = "filled.count.soa"
    _ = field.searchBar(field.searchBar, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: twa)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
      XCTAssertTrue(field.autoSuggestViewController.autoSuggestDataSource.suggestions.count == 3)
      XCTAssertTrue(field.autoSuggestViewController.autoSuggestDataSource.suggestions[0].words == "filled.count.soap")
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 10.0, handler: nil)
  }
  

}
