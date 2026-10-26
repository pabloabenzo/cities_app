import SwiftUI

struct ListView: View {
    @Bindable var presenter: CitiesPresenter
    @EnvironmentObject private var router: AppRouter
    var allowsNavigation: Bool = true
    
    @State private var searchBar: String = ""
    @State private var isSheetViewPresented: Bool = false
    @State private var isLoadingMore: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(presenter.model.filteredCities, id: \.self) { city in
                        HStack(alignment: .center) {
                            if allowsNavigation {
                                NavigationLink(destination: CityMapView(city: city)) {
                                    VStack(alignment: .leading) {
                                        Text("\(city.name), \(city.country)")
                                            .foregroundStyle(.primary)
                                            .bold()
                                            .tint(Color.indigo)
                                        Text("Lon: \(city.longitude), Lat: \(city.latitude)")
                                            .tint(Color.indigo)
                                    }
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    Task {
                                        await presenter.action(.selectCity(city))
                                    }
                                })
                                .buttonStyle(.plain)
                            } else {
                                VStack(alignment: .leading) {
                                    Text("\(city.name), \(city.country)")
                                        .foregroundStyle(.primary)
                                        .bold()
                                        .tint(Color.indigo)
                                    Text("Lon: \(city.longitude), Lat: \(city.latitude)")
                                        .tint(Color.indigo)
                                }
                                .onTapGesture {
                                    Task {
                                        await presenter.action(.selectCity(city))
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            HStack {
                                Button {
                                    isSheetViewPresented = true
                                } label: {
                                    Image(systemName: "info.circle.fill")
                                        .resizable()
                                        .tint(Color.purple)
                                        .frame(width: 25, height: 25)
                                }
                                .padding(.trailing, 30)
                                .buttonStyle(.plain)
                                
                                Button {
                                    Task {
                                        await presenter.action(.toggleFavorite(city))
                                    }
                                } label: {
                                    Image(systemName: presenter.isFavorite(city) ? "heart.fill" : "heart")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 10)
                        .onAppear {
                            if presenter.model.defaultCity == nil {
                                Task {
                                    await presenter.action(.setDefaultCity(city))
                                }
                            }
                            loadMoreContentIfNeeded(city: city)
                        }
                    }
                    .padding(.bottom, 30)
                    .padding(.leading, 10)
                }
            }
            .navigationDestination(for: CityModel.self) { city in
                if allowsNavigation {
                    CityMapView(city: city)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await presenter.action(.toggleFavoritesFilter)
                        }
                    } label: {
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
            .navigationTitle("Cities of world")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchBar, prompt: "filter")
            .onChange(of: searchBar) { _, newValue in
                Task {
                    await presenter.action(.search(newValue))
                }
            }
        }
    }
    
    private func loadMoreContentIfNeeded(city: CityModel) {
        guard let lastCity = presenter.model.filteredCities.last, city == lastCity else {
            return
        }
        
        if isLoadingMore {
            return
        }
        
        let currentCount = presenter.model.filteredCities.count
        guard currentCount < presenter.model.fullFilteredCities.count else {
            return
        }
        
        isLoadingMore = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let nextCount = min(currentCount + presenter.model.loadMoreSize, presenter.model.fullFilteredCities.count)
            let nextBatch = Array(presenter.model.fullFilteredCities[currentCount..<nextCount])
            presenter.model.filteredCities.append(contentsOf: nextBatch)
            isLoadingMore = false
        }
    }
}
