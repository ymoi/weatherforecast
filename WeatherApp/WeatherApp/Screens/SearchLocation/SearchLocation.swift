//
//  SearchLocation.swift
//  WeatherApp
//
//  Created by Yuri Moisieienko on 30.10.2023.
//

import Foundation
import ComposableArchitecture

struct SearchLocation: Reducer {
    
    @Dependency(\.geocodingClient) var openWeatherClient
    struct State: Equatable {
        @BindingState var searchText: String = ""
        var searchedItems: [GeocodeResponse] = []
        var showList = false
    }
    
    enum Action: BindableAction, Equatable {
        case setup
        case geocodeResponse(TaskResult<[GeocodeResponse]>)
        case binding(BindingAction<State>)
        case locationSelected(GeocodeResponse)
        case showList
    }
    
    enum CancelID: Int {
      case search
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .setup:
                return .none
            case let .geocodeResponse(.failure(error)):
                print(error.localizedDescription)
                return .none
            case .geocodeResponse(.success(let result)):
                state.searchedItems = result
                return .none
            case .locationSelected:
                return .none
            case .binding(\.$searchText):
                guard let fixedString = state.searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                    state.searchedItems = []
                    return .cancel(id: CancelID.search)
                }
                if fixedString.count < 3 {
                    state.searchedItems = []
                    return .cancel(id: CancelID.search)
                }
                return .run {[searchText = fixedString] send in
                    await send(
                        .geocodeResponse(
                            await TaskResult {
                                try await self.openWeatherClient.geocode(searchText)
                            }
                        )
                    )
                }
                .cancellable(id: CancelID.search, cancelInFlight: true)
            case .showList:
                state.showList = true
                return .none
            case .binding:
                return .none
            }
        }
    }
}

