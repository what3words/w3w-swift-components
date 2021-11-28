//
//  TextFieldUITests.swift
//  TextFieldUITests
//
//  Created by Tim Smith on 10/09/2021.
//

import XCTest

class TextFieldUITests : BaseTest {
    
    func testSearchingAndSelectignAddressWithNoClipping() throws {
        try searchAndSelectAddress(address : "jazz.silver.bagels", clipping : "NoClipping")
    }
    
    func testAddressOutsideOfCicleIsntReturned() throws {
        try searchAndAssertAddressIsNotReturned(address : "jazz.silver.bagels", clipping : "Circle")
    }
    
    func testSearchingAndSelectignAddressInCircleCLipping() throws {
        try searchAndSelectAddress(address : "falters.curtains.point", clipping : "Circle")
    }
    
    func testAddressOutsideOfBoxIsntReturned() throws {
        try searchAndAssertAddressIsNotReturned(address : "falters.curtains.point", clipping : "Rectangle")
    }
    
    func testSearchingAndSelectignAddressInBoxCLipping() throws {
        try searchAndSelectAddress(address : "cliche.whom.passage", clipping : "Rectangle")
    }
    
    func testAddressOutsideOfCountryIsntReturned() throws {
        try searchAndAssertAddressIsNotReturned(address : "cliche.whom.passage", clipping : "CountryGB")
    }
    
    func testSearchingAndSelectignAddressInCountryCLipping() throws {
        try searchAndSelectAddress(address : "decent.chains.pages", clipping : "CountryGB")
    }
    
    func testAddressOutsideOfPolygonIsntReturned() throws {
        try searchAndAssertNoAddressIsReturned(address : "decent.chains.pages", clipping : "Polygon")
    }
    
    func testSearchingAndSelectignAddressInPolygonCLipping() throws {
        try searchAndSelectAddress(address : "advice.itself.mops", clipping : "Polygon")
    }
    
    func testSearchingforLongGermanAddress() throws {
        try searchAndSelectAddress(address : "postverwaltung.postverwaltung.postverwaltung", clipping : "NoClipping")
    }
    
    func testAutoSuggestCanReturn3AlternativeSuggestions() throws {
        app.launchEnvironment[TextFieldUITests.clippingSettings] = "Circle"
        app.launch()
        let textFieldPage = TextFieldPage(app : app)
        let returnedAddresses = textFieldPage.enterAddress("jazz.silver.bagels")
            .waitForReturnedMatches()
            .getReturnedAddresses()
        XCTAssertEqual(returnedAddresses.count,3)
        XCTAssertFalse(returnedAddresses.contains("///jazz.silver.bagels"))
    }
    
    func testNearIsDisplayed() throws {
        app.launchEnvironment[TextFieldUITests.clippingSettings] = "Circle"
        app.launch()
        let textFieldPage = TextFieldPage(app : app)
        XCTAssertEqual (textFieldPage.enterAddress("crazy.palace.moral")
            .waitForReturnedMatches()
            .getReturnedNearLocations()[0], "near Walthamstow, London")
    }
    
    func testNonRussianLocationsArentReturnedWhenClipppinToRussia() throws {
    try searchAndAssertAddressIsNotReturned(address : "decent.chains.pages", clipping : "CountryRU")
    }
    
    func testRussianAddressesAreReturnedWhenClippingToRussia() throws {
    try searchAndSelectAddress(address : "liked.shopper.remotes", clipping : "CountryRU")
    }
    
    func testDidYouMean() throws {
            let clipping : String =  "NoClipping"
            let address : String  = "crazy palace moral"
            app.launchEnvironment[TextFieldUITests.clippingSettings] = clipping
            app.launch()
            let textFieldPage = TextFieldPage(app : app)
        XCTAssertEqual(textFieldPage.enterAddress(address)
                        .waitForDidYouMean()
                        .didYouMeanAddressField().label, "///crazy.palace.moral")
        textFieldPage.didYouMeanAddressField().tap()
        assertValue(textFieldPage.textfield, "crazy.palace.moral")
        
    
    }
    
    func testPreferLandSetToFalse() throws {
        app.launchEnvironment[TextFieldUITests.clippingSettings] = "PreferLandOff"
        app.launch()
        let textFieldPage = TextFieldPage(app : app)
        XCTAssertEqual(textFieldPage.enterAddress("biochemists.replaced.wax")
                        .waitForReturnedMatches().getSeaResults().count, 3)
    }
    
    func testSettingResultsTo5() throws {
        app.launchEnvironment[TextFieldUITests.clippingSettings] = "FiveResults"
        app.launch()
        let textFieldPage = TextFieldPage(app : app)
        XCTAssertEqual(textFieldPage.enterAddress("daring.lion.race")
                        .waitForReturnedMatches().getReturnedAddresses().count, 5)
    }
    
}

