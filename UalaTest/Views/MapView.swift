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

    @State private var region = MKCoordinateRegion()
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
                .onChange(of: city) { _, newCity in
                    updateRegion(city: newCity)
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
                Text("Más Información")
                    .font(.title2)
                    .fontWeight(.bold)
            })
            .buttonStyle(.borderedProminent)
            .tint(.mint.opacity(0.85))
            .buttonBorderShape(.roundedRectangle(radius: 15))
            .padding()
        }
        .onAppear {
            updateRegion(city: city)
        }
    }

    private func updateRegion(city: City) {
        self.region = MKCoordinateRegion(
            center: city.getCoord(),
            span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
        )
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

                Text("\(ciudad.country) \(flag(country: ciudad.country))")
                    .font(.title)
                    .fontWeight(.medium)

                Text("Latitud: \(ciudad.coord.lat)")
                    .font(.title2)

                Text("Longitud: \(ciudad.coord.lon)")
                    .font(.title2)

            }
            .frame(height: 200)
            .background(Color.clear)
            .padding()
            Spacer()
        }
    }

    func flag(country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
}

#Preview {
    MapView(city: City(country: "Ar", name: "Mendoza", id: 123123, coord: Coordinate(lon: -3.7038, lat: 40.4168)))
}
