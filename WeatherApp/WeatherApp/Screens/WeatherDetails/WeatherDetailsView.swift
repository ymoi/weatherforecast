//
//  WeatherDetailsView.swift
//  WeatherApp
//
//  Created by Yuri Moisieienko on 30.10.2023.
//

import SwiftUI
import ComposableArchitecture

struct WeatherDetailsView: View {
    
    let store: StoreOf<WeatherDetails>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
                VStack(spacing: 30) {
                    Text(viewStore.temperature)
                        .font(.system(size: 36))
                    Button("Find my City") {
                        viewStore.send(.changeLocation)
                    }
                    Button("Refresh") {
                        viewStore.send(.refresh)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(viewStore.screenName)
                .task { await viewStore.send(.setup).finish() }
                .alert(store:
                        self.store.scope(
                            state: \.$alert,
                            action: WeatherDetails.Action.alert
                        )
                )
                .navigationDestination(store: self.store.scope(
                    state: \.$searchLocation,
                    action: { .searchLocation($0) }
                ),
                    destination: SearchLocationView.init
                )
        }
    }
    @ViewBuilder var navigationLinks: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            
        }
    }
}
