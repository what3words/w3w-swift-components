//
//  TestSearchInOtherLanguages.swift
//  TextFieldUITests
//
//  Created by Tim Smith on 17/11/2021.
//

import XCTest

class TestSearchCroppedToOtherCountries: BaseTest {

    func testSearchingInRussian() throws {
        try searchAndSelectAddress(address : "обилие.городовой.весенний", clipping : "NoClipping")
    }
    
    func testSearchingInArabic() throws {
        try searchAndSelectAddress(address : "القرفة.العامل.أسماك", clipping : "NoClipping")
    }
    
    func testSearchingforLongGermanAddress() throws {
        try searchAndSelectAddress(address : "postverwaltung.postverwaltung.postverwaltung", clipping : "NoClipping")
        //taticTexts["Did you mean?"]
    }
    
}
