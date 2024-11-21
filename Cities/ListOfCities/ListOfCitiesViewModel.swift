//
//  ListOfCitiesViewModel.swift
//  Cities
//
//  Created by Pablo Benzo on 20/11/2024.
//

import Foundation
import Observation

@Observable
class ListOfCitiesViewModel {
    
    var listResults = [CitiesInfo]()
    let url = URL(string: "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json")
    
    func fetchData(from url: URL, completion: ((Result<Data, any Error>) -> Void)? = nil) async {
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode([CitiesInfo].self, from: data) {
                let results = decodedResponse
                listResults = results.sorted { $0.name < $1.name }
                
            }
        } catch {
            print("data inválida")
        }
    }
    
    
}
