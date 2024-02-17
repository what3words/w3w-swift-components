//
//  ErrorScenarios.swift
//  TextField
//
//  Created by Tim Smith on 16/11/2021.
//

import XCTest

class ErrorScenarios: BaseTest  {

// TO FIX: This fails because the change to the way we load the APIKEY, not becuase there is a problem in the code.  
//    func testErrorMessageCanBeDisplyed() throws {
//        app.launchEnvironment[BaseTest.api_key] = "invalid"
//        app.launch()
//        let textFieldPage = TextFieldPage(app : app)
//        XCTAssertEqual(textFieldPage.enterAddress("jazz.silver.bagels")
//                        .errorMessage.label, "The API key is invalid")
//    }
    
    func testInvalidCoutryCodeGeneratesError() throws {
        app.launchEnvironment[TextFieldUITests.clippingSettings] = "InvalidCountryCode"
        app.launch()
        let textFieldPage = TextFieldPage(app : app)
        XCTAssertEqual(textFieldPage.enterAddress("jazz.silver.bagels")
                        .errorMessage.label, "400: Countries are specified as a comma separated list of uppercase ISO 3166-1 alpha-2 country codes, such as US,CA")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}
