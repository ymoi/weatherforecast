//
//  GeocodingClient.swift
//  WeatherApp
//
//  Created by Yuri Moisieienko on 30.10.2023.
//

import Foundation
import ComposableArchitecture

struct GeocodeResponse: Codable, Equatable, Hashable {
    let name: String
    let lat: Double
    let lon: Double
}

struct GeocodeRequest: APIRequest{
    let name: String
    var path: String { "/geo/1.0/direct?q=\(name)&limit=10" }
}

struct GeocodingClient: Sendable {
    var geocode: @Sendable (String) async throws -> [GeocodeResponse]
}

extension GeocodingClient: DependencyKey {
    public static let liveValue: GeocodingClient = {
        return GeocodingClient(
        geocode: { name in
            let req = GeocodeRequest(name: name)
            var results: [GeocodeResponse] = []
            do {
                results =  try await APIProvider.shared.fetch(type: [GeocodeResponse].self, with: req)
            }
            catch let error {
                throw error
            }
            return results
        }
    )}()
}

extension GeocodingClient: TestDependencyKey {
static let testValue = Self(
    geocode: unimplemented("\(Self.self).geocode")
  )
}

extension DependencyValues {
    var geocodingClient: GeocodingClient {
        get { self[GeocodingClient.self] }
        set { self[GeocodingClient.self] = newValue }
    }
}

