import SwiftUI

struct ListView: View {
    @Bindable var presenter: CitiesPresenter
    @EnvironmentObject private var router: AppRouter
    
    @State private var searchBar: String = ""
    @State private var isSheetViewPresented: Bool = false
    @State private var isLoadingMore: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(presenter.model.filteredCities, id: \.self) { city in
                        HStack(alignment: .center) {
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
                CityMapView(city: city)
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
        
        let shown = Set(presenter.model.filteredCities)
        var candidates: [CityModel] = []
        
        for c in presenter.model.allCities {
            if shown.contains(c) {
                continue
            }
            if presenter.model.showingFavorites && !presenter.model.favoriteCityIds.contains(c.id) {
                continue
            }
            if !presenter.model.searchText.isEmpty && !c.name.lowercased().hasPrefix(presenter.model.searchText.lowercased()) {
                continue
            }
            candidates.append(c)
            if candidates.count >= 20 {
                break
            }
        }
        
        if candidates.isEmpty {
            return
        }
        
        isLoadingMore = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            presenter.model.filteredCities.append(contentsOf: candidates)
            isLoadingMore = false
        }
    }
}
