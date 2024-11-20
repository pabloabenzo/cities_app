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
    private var deviceWidth = UIScreen.main.bounds.width
    
    var filteredCities: [CitiesInfo] {
        guard !searchBar.isEmpty else { return listResults }
        return listResults.filter { $0.name.lowercased().hasPrefix(searchBar.lowercased()) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(initialCitiesLoaded, id: \.name) { city in
                        HStack(spacing: deviceWidth / 8) {
                            NavigationLink("\(city.name), \(city.country)\nLon: \(city.coord["lon"]!), Lat: \(city.coord["lat"]!)", destination: ListOfCitiesMapView(listResult:city)
                            )
                            .frame(minWidth: deviceWidth / 1.5)
                            .onAppear {
                                loadMoreContentIfNeeded(city: city)
                            }
                            
                            Button {
                                print("hola")
                            } label: {
                                Image(systemName: "info.circle.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .padding(.leading, 10)
                            }
                            .padding(.leading, 10)
                            
                        }
                        .padding(.bottom, 20).padding(.leading, 10)
                    }
                }
                
            }
            .navigationTitle("Cities of world")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchBar, prompt: "filter")
        }
        .task {
            await fetchData()
        }
        
        
        
        if filteredCities.isEmpty {
            Text("No hay resultados.")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.bottom, UIScreen.main.bounds.height / 3)
        }
        
    }
    
    private func loadInitialCities() {
        let initialBatch = Array(listResults.prefix(20))
        initialCitiesLoaded.append(contentsOf: initialBatch)
    }

    private func loadMoreContentIfNeeded(city: CitiesInfo) {
        
        guard let lastCity = initialCitiesLoaded.last, city == lastCity else {
            return
        }
        
        if !isLoading && initialCitiesLoaded.count < listResults.count {
            isLoading = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                let nextBatchStart = initialCitiesLoaded.count
                let nextBatchEnd = min(initialCitiesLoaded.count + 20, filteredCities.count)
                let nextBatch = filteredCities[nextBatchStart..<nextBatchEnd]
                initialCitiesLoaded.append(contentsOf: nextBatch)
                
                isLoading = false
            }
        }
    }
    
    func fetchData() async {
        guard let url = URL(string: "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode([CitiesInfo].self, from: data) {
                let results = decodedResponse
                listResults = results.sorted { $0.name < $1.name }
                loadInitialCities()
                
            }
        } catch {
            print("data inválida")
        }
    }

}

#Preview {
    ListOfCitiesView()
}
