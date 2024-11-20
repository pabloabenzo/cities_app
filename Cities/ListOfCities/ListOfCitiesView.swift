//
//  ListOfCitiesView.swift
//  Cities
//
//  Created by Pablo Benzo on 20/11/2024.
//

import SwiftUI

struct ListOfCitiesView: View {
    
    @State var listResults = [CitiesInfo]()
    @State private var initialCitiesLoaded: [CitiesInfo] = []
    @State private var searchBar = ""
    @State private var isLoading: Bool = false
    
    var filteredCities: [CitiesInfo] {
        guard !searchBar.isEmpty else { return listResults }
        return listResults.filter { $0.name.lowercased().hasPrefix(searchBar.lowercased()) }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(filteredCities, id: \.name) { city in
                        
                        NavigationLink("\(city.name), \(city.country)\nLon: \(city.coord["lon"]!), Lat: \(city.coord["lat"]!)", destination: ListOfCitiesMapView(listResult:city)
                        )
                        
                        .padding(.leading, 10)
                        Button {
                            // logica MAS INFO
                        } label: {
                            Text("MAS INFO")
                        }
                        .frame(width: 100, height: 20)
                        .font(.system(size: 15)).italic()
                        .foregroundColor(.white)
                        .background(.red)
                        .cornerRadius(5)
                        .padding(.leading, 10)
                    }
                }
                .padding(.leading, 10)
            }
        }
        .task {
            await fetchData()
        }
        .navigationTitle("Cities of world")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchBar, prompt: "filter")
        
        
        if filteredCities.isEmpty {
            Text("No hay resultados.")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.bottom, UIScreen.main.bounds.height / 3)
        }
        
    }
    
    func fetchData() async {
        guard let url = URL(string: "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json") else { return }
        
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

#Preview {
    ListOfCitiesView()
}
