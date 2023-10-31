//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Yuri Moisieienko on 30.10.2023.
//

import SwiftUI
import ComposableArchitecture

@main
// When I noticed that name I decided not to change
// I guess almost all apps have names like "Forecast"
// This one will single out with the name :)
struct WeatherAppApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                WeatherDetailsView(
                    store: Store(initialState: WeatherDetails.State()) {
                        WeatherDetails()
                    }
                )
            }
        }
    }
}

