//
//  APIProvider.swift
//  WeatherApp
//
//  Created by Yuri Moisieienko on 30.10.2023.
//

import Foundation

enum ApiError: Error {
    case requestFailed(description: String)
    case responseUnsuccessful(description: String)
    case jsonConversionFailure(description: String)
    
    var customDescription: String {
        switch self {
        case let .requestFailed(description): return "Request Failed: \(description)"
        case let .responseUnsuccessful(description): return "Unsuccessful: \(description)"
        case let .jsonConversionFailure(description): return "JSON Conversion Failure: \(description)"
        }
    }
}

struct APIProvider {
    
    static let shared = APIProvider()
    
    private let BASE_URL = "http://api.openweathermap.org"
    private let session: URLSession
    private var apiKey: String = {
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "OpenWeatherAPIKEY") as? String {
            return apiKey
        }
        return ""
    }()
    
    init() {
        self.session = URLSession(configuration: .default)
    }
    
    func fetch<T: Codable>(type: T.Type, with request: APIRequest) async throws -> T {

        var urlRequest: URLRequest = {
            let urlString = "\(BASE_URL)\(request.path)&appid=\(apiKey)"
          let url = URL(string: urlString)!
          return URLRequest(url: url)
         }()
        
        let (data, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.requestFailed(description: "Invalid response")
        }
        guard httpResponse.statusCode == 200 else {
            throw ApiError.responseUnsuccessful(description: "Status code: \(httpResponse.statusCode)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: data)
        } catch {
            throw ApiError.jsonConversionFailure(description: error.localizedDescription)
        }
    }
}

