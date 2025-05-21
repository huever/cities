//
//  MapView.swift
//  UalaTest
//
//  Created by Luciano Putignano on 20/05/2025.
//

import SwiftUI
import MapKit

struct MapView: View {

    let city: City
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )
    @State private var ciudadSeleccionada: City? = nil

    var body: some View {

        ZStack(alignment: .bottom) {
            NavigationStack {
                Map(coordinateRegion: $region, annotationItems: [city]) { ciudad in
                    MapAnnotation(coordinate: ciudad.getCoord()) {
                        Button(action: {
                            ciudadSeleccionada = ciudad
                        }) {
                            VStack {
                                Image(systemName: "pin.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .sheet(item: $ciudadSeleccionada) { ciudad in
                    CiudadDetalleView(ciudad: ciudad)
                        .presentationDetents([.fraction(0.25), .medium])
                        .presentationBackground(.thinMaterial)
                }
            }

            Button(action: {
                ciudadSeleccionada = city
            }, label: {
                Text("Detalles")
                    .font(.title2)
                    .fontWeight(.bold)
            })
            .buttonStyle(.borderedProminent)
            .tint(.mint.opacity(0.85))
            .buttonBorderShape(.roundedRectangle(radius: 15))
            .padding()
        }
        .onAppear {
            self.region = MKCoordinateRegion(
                center: city.getCoord(),
                span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
            )
        }
    }
}

struct CiudadDetalleView: View {
    let ciudad: City

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(ciudad.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(ciudad.country)
                    .font(.title)
                    .fontWeight(.medium)

                Text("Latitude: \(ciudad.coord.lat)")
                    .font(.title2)

                Text("Longitude: \(ciudad.coord.lon)")
                    .font(.title2)

            }
            .background(Color.clear)
            .padding()
            Spacer()
        }
    }
}

#Preview {
    MapView(city: City(country: "Ar", name: "Mendoza", id: 123123, coord: Coordinate(lon: -3.7038, lat: 40.4168)))
}
