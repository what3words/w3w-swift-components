//
//  TextFieldPage.swift
//  TextFieldUITests
//
//  Created by Tim Smith on 07/10/2021.
//

import Foundation
import XCTest
import CloudKit
import AudioToolbox

class TextFieldPage : BasePage
{
    lazy var textfield: XCUIElement = app.textFields["w3wTextField"]
    lazy var results : XCUIElementQuery = app.tables.cells.descendants(matching: .staticText)
    lazy var searchResultContainers : XCUIElementQuery = app.tables.cells
    lazy var errorMessage : XCUIElement = app.alerts.staticTexts.element(boundBy: 1)

    func enterAddress(_ address : String) -> TextFieldPage
    {
        textfield.tap()
        textfield.typeText(address)
        return self
    }
    
    func waitForReturnedMatches() -> TextFieldPage
    {
        XCTAssertTrue(areSuggestionresultsPresent())
        return self
    }
    
    func areSuggestionresultsPresent() -> Bool
    {
        return searchResultContainers.firstMatch.waitForExistence(timeout: 4)
    }
    
    func selectResult(_ address : String)
    {
        var addressToSelect : XCUIElement = results[address]
        XCTAssertTrue(addressToSelect.waitForExistence(timeout: 4))
        addressToSelect.tap()
    }
    
    func waitForDidYouMean() -> TextFieldPage
    {
        XCTAssertTrue(app.staticTexts["Did you mean?"].waitForExistence(timeout: 4))
        return self
    }
    
    func didYouMeanAddressField() -> XCUIElement{
        let parent : XCUIElementQuery = app.otherElements.containing(.staticText, identifier: "Did you mean?")
        XCTAssertEqual(parent.staticTexts.allElementsBoundByIndex.count, 2)
        return parent.staticTexts.element(boundBy: 1)
    }

//    func getLabelsForSuggestedAddress() -> [String]
//    {
//        let elements = app.tables.cells.descendants(matching: .staticText).allElementsBoundByIndex
//        var labelsReturned : [String] = []
//        for element in elements
//        {
//            labelsReturned.append(element.label)
//            print("label is" + element.label)
//        }
//        return labelsReturned
//    }
//
//    func getNumberOfReturnedAddress() -> Int
//    {
//        return searchResultContainers.count
//    }
        
    func getElementsContainingText(elements : [XCUIElement], text : String) -> [XCUIElement]
    {
        var addressElements : [XCUIElement] = []
        for element in elements
        {
            if (element.elementType == XCUIElement.ElementType.staticText && element.label.hasPrefix(text))
            {
                addressElements.append(element)
            }
        }
        return addressElements
    }
    
    func getSeaResults() -> [XCUIElement]
    {
        var seaResults : [XCUIElement] = []
        for cell in searchResultContainers.allElementsBoundByIndex
        {
            if cell.images["flag.water"].exists
            {
                seaResults.append(cell)
            }
        }
        return seaResults
    }
    
    func getReturnedSeaAddresses() -> [String]
    {
        var resultElements : [XCUIElement] = []
        for cell in getSeaResults()
        {
            for element in cell.children(matching: .staticText).allElementsBoundByIndex
            {
                resultElements.append(element)
            }
        }
        return getLabels(getElementsContainingText(elements : resultElements, text : "///"))
    }
    
    func getLabels(_ elements : [XCUIElement]) -> [String]
    {
        var labels : [String] = []
        for element in elements
        {
            labels.append(element.label)
        }
        return labels
    }
    
    func getReturnedAddresses() -> [String]
    {
        return getLabels(getElementsContainingText(elements : searchResultContainers.children(matching: .staticText).allElementsBoundByIndex, text : "///"))
    }
    
    func getReturnedNearLocations() -> [String]
    {
        return getLabels(getElementsContainingText(elements : searchResultContainers.children(matching: .staticText).allElementsBoundByIndex, text : "near "))
    }
}
    
    
    //    func getErrorMessage()
    //    {
    //        var errorMessage : XCUIElement = app.alerts.staticTexts.element(boundBy: 1)
    //    }
        
    //    func getAllElementsForReturnedAddress(position : Int) -> [XCUIElement]{
    ////        var type : XCUIElement.ElementType
    //        for element in app.tables.cells.element(boundBy: position).children(matching: .any).allElementsBoundByIndex
    //        {
    //            print("&&&& ELEMENT TYPE")
    //            print(element.elementType.rawValue)
    //                  }
    //        return app.tables.cells.element(boundBy: position).children(matching: .any).allElementsBoundByIndex
    //    }
        

    //    func listElements( )
    //    {
    //        print("___ __ _ ___ _")
    //        for element in getAllElementsForReturnedAddress(position: 0)
    //        {
    //            if element.elementType == XCUIElement.ElementType.staticText
    //            {
    //            print("*** * ** * * element debug")
    ////            print(element.debugDescription)
    //                print("returned element is \(element.elementType.self)")
    //            }
    //        }
    //    }
        
        
        
    //    func getAllElementsInTextfield()
    //    {
    //        var elements = app.otherElements.allElementsBoundByIndex
    //        print(elements.count)
    //        print(textfield.debugDescription)
    //        print(type(of: textfield))
    //        var i : Int = 1
    //        for element in elements
    //        {
    //            print(">>> > > >>> >>   > > Elements no " + String(i))
    //            print(type(of : element))
    ////            print(element.debugDescription)
    //             i += 1
    //            print(">>> > > >>> >>   > >end of element search ")
    //        }
    //    }
