//
//  CitiesTests.swift
//  CitiesTests
//
//  Created by Pablo Benzo on 21/11/2024.
//

import XCTest
@testable import Cities

final class CitiesTests: XCTestCase {
    var mockCitiesVM = ListOfCitiesViewModel()
    
    func testFetchData() async {
        let url = URL(string: "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json")
        let expectation = self.expectation(description: "Llamada exitosa al endpoint")
        
        await mockCitiesVM.fetchData(from: url!) { result in
            
            switch result {
            case .success(let data):
                XCTAssertNotNil(data, "Los datos no deben ser nulos")
            case .failure(let error):
                XCTFail("La llamada falló con el error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        await waitForExpectations(timeout: 10, handler: nil)
    }
    
}
    

