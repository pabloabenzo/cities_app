//
//  ListOfCitiesView.swift
//  Cities
//
//  Created by Pablo Benzo on 20/11/2024.
//

import SwiftUI

struct ListOfCitiesView: View {
    
    private var citiesVM = ListOfCitiesViewModel()
    @State private var isLandscape: Bool = UIDevice.current.orientation.isLandscape
    @State private var isLoading: Bool = false
    @State private var isFavorite: Bool = false
    @State private var searchBar = ""
    @State private var isSheetViewPresented = false
    private var deviceWidth = UIScreen.main.bounds.width
        
    var body: some View {
            if !isLandscape {
            NavigationStack {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(filteredSearch, id: \.name) { city in
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
                                    .padding(.leading, 10)
                                }
                                .frame(minWidth: deviceWidth / 1.5)
                                .onAppear {
                                    loadMoreContentIfNeeded(city: city)
                                    detectOrientation()
                                }
                                
                                Button {
                                    isSheetViewPresented = true
                                } label: {
                                    Image(systemName: "info.circle.fill")
                                        .resizable()
                                        .tint(Color.purple)
                                        .frame(width: 25, height: 25)
                                }
                                .padding(.leading, 10)
                                
                                Image(systemName: citiesVM.contains(city) ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                                    .onTapGesture {
                                        citiesVM.toggleFav(item: city)
                                    }
                                    .padding(.leading, 10)
                                
                            }
                            .padding(.bottom, 20).padding(.leading, 10)
                        }
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
            
            if filteredCities.isEmpty && !searchBar.isEmpty {
                Text("No hay resultados.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.bottom, UIScreen.main.bounds.height / 2)
            } else if filteredCities.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding(.bottom, UIScreen.main.bounds.height / 2)
            }
        } else {
            NavigationSplitView {
                Text("Prueba de vista landscape")
            } detail: {
//                Mapa de ciudad seleccionada
            }
            
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

#Preview {
    ListOfCitiesView()
}
