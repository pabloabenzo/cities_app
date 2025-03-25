//
//  CitiesTests.swift
//  CitiesTests
//
//  Created by Pablo Benzo on 21/11/2024.
//

import XCTest
@testable import Cities

protocol NetworkingService {
    func fetchData(url: URL, completion: @escaping (Data?, Error?) -> Void)
}

final class CitiesTests: XCTestCase {
    
    var apiClient: CitiesAPIClient!
    
    override func setUp() {
        super.setUp()

        let mockNetworkingService = MockNetworkingService()
        apiClient = CitiesAPIClient(networkingService: mockNetworkingService)
    }
    override func tearDown() {
        apiClient = nil
        super.tearDown()
    }
    
    func testFetchCitiesData() {
        let expectation = self.expectation(description: "Fetch cities data.")
        apiClient.fetchCitiesData { result in
            switch result {
            case .success(let cities):
                XCTAssertFalse(cities.isEmpty, "The result should not be empty.")
                
                if let firstCity = cities.first {
                    XCTAssertEqual(firstCity.country, "UA")
                    XCTAssertEqual(firstCity.name, "Hurzuf")
                } else {
                    XCTFail("The array is empty.")
                }
            case .failure(let error):
                XCTFail("Error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    class MockNetworkingService: NetworkingService {
        func fetchData(url: URL, completion: @escaping (Data?, Error?) -> Void) {

            let jsonString = """
               [
                {
                    "country":"UA",
                    "name":"Hurzuf",
                    "_id":707860,
                    "coord":{"lon":34.283333,"lat":44.549999}
                }
               ]
            """
            if let data = jsonString.data(using: .utf8) {
                completion(data, nil)
            } else {
                let error = NSError(domain: "MockNetworkingServiceErrorDomain", code: -1, userInfo: nil)
                completion(nil, error)
            }
        }
    }
    
    class CitiesAPIClient {
        private let networkingService: NetworkingService

    init(networkingService: NetworkingService) {
            self.networkingService = networkingService
        }
        func fetchCitiesData(completion: @escaping (Result<[CitiesInfo], Error>) -> Void) {
            guard let url = URL(string: "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json") else { return }
            networkingService.fetchData(url: url) { data, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let decoder = JSONDecoder()
                do {
                    let news = try decoder.decode([CitiesInfo].self, from: data!)
                    completion(.success(news))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
}
    

