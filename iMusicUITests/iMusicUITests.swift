//
//  iMusicUITests.swift
//  iMusicUITests
//
//  Created by Javier Fernández on 5/1/21.
//

import XCTest

class iMusicUITests: XCTestCase {

    var app = XCUIApplication()
    
    // MARK: - Lifecycle
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDownWithError() throws {
        
    }
    
    // MARK: - Tests
    /// Comprobamos que la app arranca y carga el primer navigationBar y la tableView
    func testRunApp() {
        XCTAssert(app.navigationBars["InitAppArtistViewNavBar"].exists)
        XCTAssert(app.tables["InitAppArtistTableView"].exists)
    }
    
    
    //    func testLaunchPerformance() throws {
    //        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
    //            // This measures how long it takes to launch your application.
    //            measure(metrics: [XCTApplicationLaunchMetric()]) {
    //                XCUIApplication().launch()
    //            }
    //        }
    //    }
}
