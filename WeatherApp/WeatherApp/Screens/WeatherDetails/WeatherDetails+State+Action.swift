//
//  WeatherDetails+State+Action.swift
//  WeatherApp
//
//  Created by Yuri Moisieienko on 30.10.2023.
//

import ComposableArchitecture
import ComposableCoreLocation

extension WeatherDetails {
    struct State: Equatable {
        let screenName = "Weather"
        var temperature: String = ""
        var isRequestingCurrentLocation = false
        var lat: Double = 0.0
        var lon: Double = 0.0
        var isLocationSelected = false
        @PresentationState var alert: AlertState<Action.Alert>?
        @PresentationState var searchLocation: SearchLocation.State?
    }
    
    enum Action:Equatable {
        case setup
        case setupLocation
        case setAlert(AlertState<Action.Alert>?)
        case startRequestingCurrentLocation
        case locationManager(LocationManager.Action)
        case weatherResponse(TaskResult<WeatherResponse>)
        case alert(PresentationAction<Alert>)
        case changeLocation
        case searchLocation(PresentationAction<SearchLocation.Action>)
        case refresh
        
        enum Alert: Equatable {
            case dismissButtonTapped
        }
    }
}
