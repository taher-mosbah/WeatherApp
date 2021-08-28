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
    var weather: (String) -> AnyPublisher<DayWeather, Error>
    var forecast: (String) -> AnyPublisher<WeatherForecast, Error>

    init(
        weather: @escaping (String) -> AnyPublisher<DayWeather, Error>,
        forecast: @escaping (String) -> AnyPublisher<WeatherForecast, Error>
    ) {
        self.weather = weather
        self.forecast = forecast
    }
}

struct WeatherForecast: Decodable, Equatable {
    var list: [DayWeather]
}

struct DayWeather: Decodable, Equatable {
    init(main: DayWeather.MainWeather, weather: [DayWeather.Weather], dtTxt: Date) {
        self.main = main
        self.weather = weather
        self.dtTxt = dtTxt
    }

    var main: MainWeather
    var weather: [Weather]
    var dtTxt: Date?
    var id: String {
        "\(weather.first!.id)" // TODO
    }

    struct MainWeather: Decodable, Equatable {
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

    struct Weather: Decodable, Equatable {
        init(id: Double, description: String) {
            self.id = id
            self.description = description
        }

        var id: Double
        var description: String
    }
}

// TODO: Use a flat object
