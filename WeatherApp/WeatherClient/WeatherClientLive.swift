//
//  WeatherClientLive.swift
//  WeatherApp
//
//  Created by Mohamed Mosbah on 28/08/2021.
//

import Foundation
import Combine

// TODO: refactor constructing the request
extension WeatherClient {
    private static var key = "bb53995398d058363d372de8ab356e14"
    public static let live = Self(
        weather: { city in
            URLSession.shared.dataTaskPublisher(for: URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(key)&units=metric")!)
                .tryMap() { element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                    return element.data
                }
                .decode(type: DayWeather.self, decoder: weatherJsonDecoder)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        },
        forecast: { city in
            URLSession.shared.dataTaskPublisher(for: URL(string: "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(key)&units=metric")!)
                .tryMap() { element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                    return element.data
                }
                .decode(type: WeatherForecast.self, decoder: weatherJsonDecoder)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        })
}

private let weatherJsonDecoder: JSONDecoder = {
    let jsonDecoder = JSONDecoder()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    jsonDecoder.dateDecodingStrategy = .formatted(formatter)
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    return jsonDecoder
}()
