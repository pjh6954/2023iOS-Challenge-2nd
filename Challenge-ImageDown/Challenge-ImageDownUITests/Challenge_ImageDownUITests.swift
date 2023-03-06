//
//  Challenge_ImageDownUITests.swift
//  Challenge-ImageDownUITests
//
//  Created by Dannian Park on 2023/03/05.
//

import XCTest

final class Challenge_ImageDownUITests: XCTestCase {
    let app = XCUIApplication()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    /*
    // 성능 측정 시 사용
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    */
    
    func testAllImageLoadAction() throws {
        app.launch()
        let loadAll = app.buttons.matching(identifier: "btnLoadAll").element
        // let loadAll2 = app.buttons["btnLoadAll"]
        // let loadAll3 = app.buttons.element(matching: .button, identifier: "btnLoadAll")
        
        loadAll.tap()
        
        sleep(5)
        
        let loadThirdCell = app.tables.cells.element(boundBy: 2)
        loadThirdCell.buttons["loadButton"].tap()
        
        sleep(5)
    }
}
