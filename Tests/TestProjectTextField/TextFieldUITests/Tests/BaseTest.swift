//
//  Created by Tim Smith on 07/10/2021.
//

import XCTest

class BaseTest : XCTestCase
{
    let app = XCUIApplication()
    static let clippingSettings = "UI-TestingKey_Clipping"
    static let api_key = "UI-TestingKey_ApiKey"
    
    override func setUpWithError() throws {
        super.setUp()
        app.launchArguments += ["UI-Testing"]
    }
    
    func assertValue(_ element : XCUIElement ,_ expected : String)
    {
        if let text = element.value as? String
        {
            XCTAssertEqual(expected, text)
        }
        
        else
        {
            XCTFail()
        }
    }
    
    func searchAndAssertAddressIsNotReturned(address : String, clipping : String) throws {
        app.launchEnvironment[TextFieldUITests.clippingSettings] = clipping
        app.launch()
        let textFieldPage = TextFieldPage(app : app)
        let returnedAddresses = textFieldPage.enterAddress(address)
            .waitForReturnedMatches()
            .getReturnedAddresses()
        XCTAssertFalse(returnedAddresses.contains("///\(address)"))
    }
    
    func searchAndAssertNoAddressIsReturned(address : String, clipping : String) throws {
        app.launchEnvironment[TextFieldUITests.clippingSettings] = clipping
        app.launch()
        let textFieldPage = TextFieldPage(app : app)
        XCTAssertFalse(textFieldPage.enterAddress(address)
            .areSuggestionresultsPresent())
    }
    
    func searchAndSelectAddress(address : String, clipping : String) throws
    {
        app.launchEnvironment[TextFieldUITests.clippingSettings] = clipping
        app.launch()
        let textFieldPage = TextFieldPage(app : app)
        textFieldPage.enterAddress(address)
                        .waitForReturnedMatches()
                        .selectResult("///\(address)")
        assertValue(textFieldPage.textfield, "///\(address)")
    }
}
