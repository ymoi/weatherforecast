//
//  OpenWeatherClient.swift
//  WeatherApp
//
//  Created by Yuri Moisieienko on 30.10.2023.
//

import Foundation
import ComposableArchitecture

struct WeatherRequest: APIRequest {
    let lat: Double
    let lon: Double
    
    var path: String { "/data/2.5/weather?lat=\(lat)&lon=\(lon)&units=metric" }
}

struct WeatherResponse: Codable, Equatable {
    let base: String
    let main: MainData
    
    struct MainData: Codable, Equatable {
        let temp: Double
    }
}

struct OpenWeatherClient: Sendable {
    var weather: @Sendable (WeatherRequest) async throws -> WeatherResponse
}

extension OpenWeatherClient: DependencyKey {
    public static let liveValue: OpenWeatherClient = {
        return OpenWeatherClient(
            weather: {  request in
                var results: WeatherResponse?
                do {
                    results =  try await APIProvider.shared.fetch(type: WeatherResponse.self, with: request)
                }
                catch let error {
                    throw error
                }
                return results!
            }
        )}()
}

extension OpenWeatherClient: TestDependencyKey {
    static let testValue = Self(
        weather: unimplemented("\(Self.self).weather")
    )
}

extension DependencyValues {
    var openWeatherClient: OpenWeatherClient {
        get { self[OpenWeatherClient.self] }
        set { self[OpenWeatherClient.self] = newValue }
    }
}
