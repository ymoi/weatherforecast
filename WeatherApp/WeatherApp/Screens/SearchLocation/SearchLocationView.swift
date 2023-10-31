//
//  SearchLocationView.swift
//  WeatherApp
//
//  Created by Yuri Moisieienko on 30.10.2023.
//

import Foundation

import SwiftUI
import ComposableArchitecture

struct SearchLocationView: View {
    
    let store: StoreOf<SearchLocation>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                if viewStore.showList {
                    List {
                        ForEach(viewStore.searchedItems, id: \.self) { item in
                            Button(item.name, action: {
                                viewStore.send(.locationSelected(item))
                            })
                        }
                    }
                    .searchable(text: viewStore.$searchText, prompt: "City Name")
                }
            }
            .onAppear {
                viewStore.send(.showList)
            }
            .navigationTitle("Find your location")
        }
    }
}
