//
//  iMusicTests.swift
//  iMusicTests
//
//  Created by Javier Fernández on 5/1/21.
//

import XCTest
@testable import iMusic

class iMusicTests: XCTestCase {

    var tableViewController: ArtistsView!
    
    // MARK: - Lifecycle
    override func setUpWithError() throws {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        tableViewController = try XCTUnwrap(storyboard.instantiateViewController(withIdentifier: "ArtistsViewID") as? ArtistsView)
        
        tableViewController.loadView() /// Cargamos la View
        tableViewController.viewDidLoad() /// Cargamos los datos de la View
    }
    
    override func tearDownWithError() throws {
        tableViewController = nil
    }
    
    // MARK: - Tests
    /// Comprobamos si recibimos datos JSON al realizar una petición GET a la API
    func testDataJSON() {
        var searchResults: SearchResults?
        let expectative = expectation(description: "Solicitud de datos JSON al servidor")
        
        if let url = URL(string: DataAPI.fetchRequest(value: "Phil Collins")) {
            NetworkingProvider.shared.loadNetworkData(url: url) { data in
                let dataJSON = try? JSONDecoder().decode(SearchResults.self, from: data)
                if let result = dataJSON {
                    searchResults = result
                    expectative.fulfill()
                }
            }
            waitForExpectations(timeout: 3, handler: nil) /// Necesario para espera la llamada al servidor, ya que los test no son asíncronos
            
            let searchResults = try? XCTUnwrap(searchResults)
            if let searchResults = searchResults, let results = searchResults.results {
                XCTAssertFalse(results.isEmpty, "Datos no recibidos del servidor")
            }
        }
    }
}
