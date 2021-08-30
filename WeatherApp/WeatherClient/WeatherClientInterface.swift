//
//  WeatherClientInterface.swift
//  WeatherApp
//
//  Created by Mohamed Mosbah on 28/08/2021.
//

import Foundation
import Combine

/// A client for fetching weather data.
public struct WeatherClient {
    var weather: (String) -> AnyPublisher<(DayWeather, WeatherForecast), Error>

    init(
        weather: @escaping (String) -> AnyPublisher<(DayWeather, WeatherForecast), Error>
    ) {
        self.weather = weather
    }
}

struct WeatherForecast: Codable, Equatable {
    var list: [DayWeather]
}

struct DayWeather: Codable, Equatable {
    init(main: DayWeather.MainWeather, weather: [DayWeather.Weather], dtTxt: Date) {
        self.main = main
        self.weather = weather
        self.dtTxt = dtTxt
    }

    var main: MainWeather
    var weather: [Weather]
    var dtTxt: Date?
    var id: String {
        UUID().uuidString
    }

    struct MainWeather: Codable, Equatable {
        init(humidity: Double, temp: Double, tempMin: Double, tempMax: Double) {
            self.humidity = humidity
            self.temp = temp
            self.tempMin = tempMin
            self.tempMax = tempMax
        }

        var humidity: Double
        var temp: Double
        var tempMin: Double
        var tempMax: Double
    }

    struct Weather: Codable, Equatable {
        init(id: Double, description: String) {
            self.id = id
            self.description = description
        }

        var id: Double
        var description: String
    }
}
