import SwiftUI

struct ListView: View {
    var presenter: CitiesPresenter
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
                                
                                Image(systemName: presenter.isFavorite(city) ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                                    .onTapGesture {
                                        Task {
                                            await presenter.action(.toggleFavorite(city))
                                        }
                                    }
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
        
        if !isLoadingMore && presenter.model.filteredCities.count < presenter.model.allCities.count {
            isLoadingMore = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let currentCount = presenter.model.filteredCities.count
                let allCount = presenter.model.allCities.count
                var updated = presenter.model.filteredCities
                let nextBatch = Array(presenter.model.allCities[currentCount..<min(currentCount + 20, allCount)])
                updated.append(contentsOf: nextBatch)
                presenter.model.filteredCities = updated
                isLoadingMore = false
            }
        }
    }
}
