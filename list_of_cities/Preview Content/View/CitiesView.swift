//
//  CitiesView.swift
//  list_of_cities
//
//  Created by Pablo Benzo on 11/02/2025.
//

import SwiftUI

struct CitiesView: View {
    
    @StateObject var citiesVM = CitiesViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            if !isLandscape {
                ListView(citiesVM: citiesVM)
            } else {
                HStack {
                    ListView(citiesVM: citiesVM)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    if let city = citiesVM.selectedCity {
                        CityMapView(listResult: city)
                    } else if citiesVM.defaultCity != nil {
                        CityMapView(listResult: citiesVM.defaultCity!)
                    }
                    
                }
            }
        }
    }
    
}
