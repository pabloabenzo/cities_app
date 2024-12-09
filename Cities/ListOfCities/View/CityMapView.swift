//
//  CityMapView.swift
//  Cities
//
//  Created by Pablo Benzo on 20/11/2024.
//

import SwiftUI
import MapKit

struct CityMapView: View {
    let listResult: CitiesInfo
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            MapView(latitude: listResult.coord.lat, longitude: listResult.coord.lon)
                .ignoresSafeArea(.container, edges: .bottom)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .tint(.black)
                        Text("Back")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct MapView: UIViewRepresentable {
    
    let latitude: Double
    let longitude: Double
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        view.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        view.addAnnotation(annotation)
    }
}
