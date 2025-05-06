//
//  ListView.swift
//  list_of_cities
//
//  Created by Pablo Benzo on 12/02/2025.
//

import SwiftUI

struct ListView: View {
    
    @ObservedObject var citiesVM: CitiesViewModel
    var deviceWidth = UIScreen.main.bounds.width
    @State private var isFavorite: Bool = false
    @State private var searchBar = ""
    @State private var isSheetViewPresented = false
    @State private var isLandscape: Bool = UIDevice.current.orientation.isLandscape
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(filteredSearch, id: \.name) { city in
                        HStack() {
                            if isLandscape {
                                VStack(alignment: .leading) {
                                    Text("\(city.name), \(city.country)")
                                        .foregroundStyle(.primary)
                                        .bold()
                                        .tint(Color.indigo)
                                    Text("Lon: \(city.coord.lon), Lat: \(city.coord.lat)")
                                        .tint(Color.indigo)
                                }
                                .padding(.leading, 10)
                                .onTapGesture {
                                    citiesVM.selectedCity = city
                                }
                            } else {
                                NavigationLink(destination: CityMapView(listResult: city)) {
                                    VStack(alignment: .leading) {
                                        Text("\(city.name), \(city.country)")
                                            .foregroundStyle(.primary)
                                            .bold()
                                            .tint(Color.indigo)
                                        Text("Lon: \(city.coord.lon), Lat: \(city.coord.lat)")
                                            .tint(Color.indigo)
                                    }
                                    .padding(.leading, 10)
                                }
                            }
                            Spacer()
                                .frame(maxWidth: 30, alignment: .trailing)
                            
                                Button {
                                    isSheetViewPresented = true
                                } label: {
                                    Image(systemName: "info.circle.fill")
                                        .resizable()
                                        .tint(Color.purple)
                                        .frame(width: 25, height: 25)
                                }
                                
                                Spacer()
                                    .frame(maxWidth: 30, alignment: .trailing)
                                Image(systemName: citiesVM.contains(city) ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                                    .onTapGesture {
                                        citiesVM.toggleFav(item: city)
                                    }
                        }
                        .frame(minWidth: deviceWidth / 1.5)
                        .onAppear {
                            loadMoreContentIfNeeded(city: city)
                            detectOrientation()
                            citiesVM.defaultCity = filteredSearch[0]
                        }
                    }
                    .padding(.bottom, 30).padding(.leading, 10)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            citiesVM.sortFavs()
                        }) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .resizable()
                                    .frame(width: 30, height: 25)
                                    .tint(Color.red)
                            }
                        }
                    }
                }
                .sheet(isPresented: $isSheetViewPresented) {
                    SheetView()
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
        
        if filteredCities.isEmpty && !searchBar.isEmpty {
            Text("No results.")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top, UIScreen.main.bounds.height / 2)
                .padding(.leading, UIScreen.main.bounds.width / 2.5)
        } else if filteredCities.isEmpty {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
                .padding(.top, UIScreen.main.bounds.height / 2)
                .padding(.leading, UIScreen.main.bounds.width / 2)
        }
    }
    
    var filteredSearch: [CitiesInfo]  {
        if searchBar.isEmpty {
            return citiesVM.filteredItems
        }
        return filteredCities
    }
    
    var filteredCities: [CitiesInfo] {
        guard !searchBar.isEmpty else { return citiesVM.listResults }
        return citiesVM.listResults.filter { $0.name.lowercased().hasPrefix(searchBar.lowercased()) }
    }
    
    private func loadInitialCities() {
        let initialBatch = Array(citiesVM.listResults.prefix(20))
        citiesVM.initialCitiesLoaded.append(contentsOf: initialBatch)
    }
    
    private func loadMoreContentIfNeeded(city: CitiesInfo) {
        
        guard let lastCity = citiesVM.initialCitiesLoaded.last, city == lastCity else {
            return
        }
        
        if !isLoading && citiesVM.initialCitiesLoaded.count < citiesVM.listResults.count {
            isLoading = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                let nextBatchStart = citiesVM.initialCitiesLoaded.count
                let nextBatchEnd = min(citiesVM.initialCitiesLoaded.count + 20, filteredCities.count)
                let nextBatch = filteredCities[nextBatchStart..<nextBatchEnd]
                citiesVM.initialCitiesLoaded.append(contentsOf: nextBatch)
                
                isLoading = false
            }
        }
    }
    
    func detectOrientation() {
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            isLandscape = UIDevice.current.orientation.isLandscape
        }
    }
}
