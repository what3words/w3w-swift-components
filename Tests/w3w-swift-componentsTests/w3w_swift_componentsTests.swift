import XCTest
@testable import W3WSwiftComponents
import W3WSwiftApi
import CoreLocation

final class w3w_swift_componentsTests: XCTestCase {
  
  var api: What3WordsV3!
  
  override func setUp() {
    super.setUp()
    
    if let apikey = ProcessInfo.processInfo.environment["APIKEY"] {
      api = What3WordsV3(apiKey: apikey)
    } else if let apikey = getApikeyFromFile() {
      api = What3WordsV3(apiKey: apikey)
    } else {
      print("Environment variable APIKEY must be set")
      abort()
    }
  }

  
  func getApikeyFromFile() -> String? {
    var apikey: String? = nil
    
    let url = URL(fileURLWithPath: "/tmp/key.txt")
    if let key = try? String(contentsOf: url, encoding: .utf8) {
      apikey = key.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    return apikey
  }
  
  
  func testApi() {
    let expectation = self.expectation(description: "Convert To 3wa")
    api.convertTo3wa(coordinates: CLLocationCoordinate2D(latitude: 51.521238, longitude: -0.203607), language: "en") { (place, error) in
      
      XCTAssertEqual(place?.words, "index.home.raft")
      XCTAssertNil(error)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  #if !os(macOS) && !os(watchOS)

  
  func testTextfield() {
    let expectation = self.expectation(description: "W3W Components")
    
    let vc = UIViewController()
    let field = W3WAutoSuggestTextField(api)
    vc.view.addSubview(field)
    
    field.onError = { error in
      XCTAssertNil(error)
      print("Error: ", error)
    }
    
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
    
    field.onError = { error in
      XCTAssertNil(error)
      print("Error: ", error)
    }

    let twa = "filled.count.soa"
    _ = field.searchBar(field.searchBar, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: twa)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
      XCTAssertTrue(field.autoSuggestViewController.autoSuggestDataSource.suggestions.count == 3)
      XCTAssertTrue(field.autoSuggestViewController.autoSuggestDataSource.suggestions[0].words == "filled.count.soap")
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 10.0, handler: nil)
  }
  

  #endif
  
}
