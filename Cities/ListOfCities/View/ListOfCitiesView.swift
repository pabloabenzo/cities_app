//
//  ListOfCitiesView.swift
//  Cities
//
//  Created by Pablo Benzo on 20/11/2024.
//

import SwiftUI

struct ListOfCitiesView: View {
    
    private var citiesVM = ListOfCitiesViewModel()
    @State private var initialCitiesLoaded: [CitiesInfo] = []
    @State private var isLoading: Bool = false
    @State private var searchBar = ""
    @State private var isSheetViewPresented = false
    private var deviceWidth = UIScreen.main.bounds.width
    
    var filteredCities: [CitiesInfo] {
        guard !searchBar.isEmpty else { return citiesVM.listResults }
        return citiesVM.listResults.filter { $0.name.lowercased().hasPrefix(searchBar.lowercased()) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(searchBar.isEmpty ? initialCitiesLoaded : filteredCities, id: \.name) { city in
                        HStack(spacing: deviceWidth / 20) {
                            NavigationLink(destination: CityMapView(listResult: city)) {
                                VStack(alignment: .leading) {
                                    Text("\(city.name), \(city.country)")
                                        .foregroundStyle(.primary)
                                        .bold()
                                        .tint(Color.indigo)
                                    Text("Lon: \(city.coord["lon"]!), Lat: \(city.coord["lat"]!)")
                                        .tint(Color.indigo)
                                }
                            }
                            .frame(minWidth: deviceWidth / 1.5)
                            .onAppear {
                                loadMoreContentIfNeeded(city: city)
                            }
                            
                            Button {
                                isSheetViewPresented = true
                            } label: {
                                Image(systemName: "info.circle.fill")
                                    .resizable()
                                    .tint(Color.purple)
                                    .frame(width: 25, height: 25)
                                    .padding(.leading, 10)
                            }
                            
                            Button {
                                // logica fav.
                            } label: {
                                Image(systemName: "star")
                                    .foregroundColor(.gray)
                            }
                            .padding(.leading, 10)
                            
                        }
                        .padding(.bottom, 20).padding(.leading, 10)
                    }
                }
                .sheet(isPresented: $isSheetViewPresented) {
                    InfoSheetView()
                        .presentationDetents([.medium])
                }
            }
            .navigationTitle("Cities of world")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchBar, prompt: "filter")
        }
        .task {
            await citiesVM.fetchData(from: citiesVM.url!)
            loadInitialCities()
        }
        
        if filteredCities.isEmpty {
            Text("No hay resultados.")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.bottom, UIScreen.main.bounds.height / 3)
        }
        
    }
    
    private func loadInitialCities() {
        let initialBatch = Array(citiesVM.listResults.prefix(20))
        initialCitiesLoaded.append(contentsOf: initialBatch)
    }
    
    private func loadMoreContentIfNeeded(city: CitiesInfo) {
        
        guard let lastCity = initialCitiesLoaded.last, city == lastCity else {
            return
        }
        
        if !isLoading && initialCitiesLoaded.count < citiesVM.listResults.count {
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

}

#Preview {
    ListOfCitiesView()
}
