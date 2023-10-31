//
//  WeatherDetails+LocationManager.swift
//  WeatherApp
//
//  Created by Yuri Moisieienko on 30.10.2023.
//

import ComposableArchitecture
import ComposableCoreLocation

extension WeatherDetails {
    @ReducerBuilder<State, Action>
    var location: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .setupLocation:
                return .run { send in
                    guard await locationManager.locationServicesEnabled() else {
                        await send(.setAlert(.init(title: TextState("Location services are turned off."))))
                        return
                    }
    
                    switch await locationManager.authorizationStatus() {
                    case .notDetermined:
                        await send(.startRequestingCurrentLocation)
                    case .restricted:
                        await send(.setAlert(.init(title: TextState("Please give us access to your location in settings."))))
                    case .denied:
                        await send(.setAlert(.init(title: TextState("Please give us access to your location in settings."))))
                    case .authorizedAlways, .authorizedWhenInUse:
                        await locationManager.requestLocation()
                    @unknown default:
                        break
                    }
                }
            case .locationManager(.didChangeAuthorization(.authorizedAlways)),
                    .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):
                return .run { _ in await locationManager.requestLocation() }
            case .locationManager(.didChangeAuthorization(.denied)):
                if state.isRequestingCurrentLocation {
                    state.alert = .init(
                        title: TextState("Location makes this app better. Please consider giving us access.")
                    )
                    state.isRequestingCurrentLocation = false
                }
                return .none
            case .locationManager(.didUpdateLocations(let locations)):
                state.isRequestingCurrentLocation = false
                guard let location = locations.first else { return .none }
                state.lat = location.coordinate.latitude
                state.lon = location.coordinate.longitude
                return .run { send in
                    await send(.refresh)
                }
            default:
                return .none
            }
        }
    }
}
