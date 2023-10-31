//
//  WeatherDetailsFeature.swift
//  WeatherApp
//
//  Created by Yuri Moisieienko on 30.10.2023.
//

import ComposableArchitecture
import ComposableCoreLocation

struct WeatherDetails {
    @Dependency(\.locationManager) var locationManager
    @Dependency(\.openWeatherClient) var openWeatherClient
}

extension WeatherDetails: Reducer {
    public var body: some ReducerOf<Self> {
        CombineReducers {
            location
            Reduce { state, action in
                switch action {
                case .setup:
                    if state.isLocationSelected {
                        return .none
                    }
                    return .run { send in
                        await send(.setupLocation)
                        await withTaskGroup(of: Void.self) { group in
                            group.addTask {
                                await withTaskCancellation(id: 0, cancelInFlight: true) {
                                    for await action in await locationManager.delegate() {
                                        await send(.locationManager(action), animation: .default)
                                    }
                                }
                            }
                        }
                    }
                case .refresh:
                    return .run { [lat = state.lat, lon = state.lon] send in
                        await send(
                            .weatherResponse(
                                await TaskResult {
                                    try await self.openWeatherClient.weather(.init(lat: lat, lon: lon))
                                }
                            )
                        )
                    }
                case let .weatherResponse(.failure(error)):
                    var text = error.localizedDescription
                    if let error = error as? ApiError {
                        text = error.customDescription
                    }
                    state.alert = AlertState { TextState(text) }
                    return .none
                case .weatherResponse(.success(let result)):
                    state.temperature = "\(result.main.temp) ℃"
                    return .none
                    
                case .startRequestingCurrentLocation:
                    state.isRequestingCurrentLocation = true
                    return .run { send in
                        await locationManager.requestWhenInUseAuthorization()
                    }
                case .searchLocation(.presented( action: SearchLocation.Action.locationSelected(let location))):
                    state.lat = location.lat
                    state.lon = location.lon
                    state.isLocationSelected = true
                    state.searchLocation = nil
                    return .run { send in
                        await send(.refresh)
                    }
                case .setAlert(let alert):
                    state.alert = alert
                    return .none
                case .changeLocation:
                    state.searchLocation = .init()
                    return .none
                case .alert:
                    return .none
                case .searchLocation:
                    return .none
                case .setupLocation:
                    return .none
                case .locationManager:
                    return .none
                }
            }
            .ifLet(\.$alert, action: /Action.alert)
            .ifLet(\.$searchLocation, action: /Action.searchLocation) {
                SearchLocation()
            }
        }
    }
}

