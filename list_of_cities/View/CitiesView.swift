import SwiftUI

struct CitiesView: View {
    @State private var presenter = CitiesPresenter()
    @StateObject private var router = AppRouter()
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            if !isLandscape {
                ListView(presenter: presenter, allowsNavigation: true)
                    .environmentObject(router)
            } else {
                HStack {
                    ListView(presenter: presenter, allowsNavigation: false)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .environmentObject(router)
                    
                    if let city = presenter.model.selectedCity {
                        CityMapView(city: city)
                    } else if let city = presenter.model.defaultCity {
                        CityMapView(city: city)
                    }
                }
            }
        }
        .task {
            await presenter.action(.loadCities)
        }
    }
}
