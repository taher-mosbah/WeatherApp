//
//  WeatherClientMocks.swift
//  WeatherApp
//
//  Created by Mohamed Mosbah on 28/08/2021.
//

import Foundation
import Combine

extension WeatherClient {
    public static let happyPath = Self(
        weather: { _ in
            Just(
                DayWeather.init(main: .init(humidity: 10, temp: 10, tempMin: 8, tempMax: 12),
                                weather: [.init(id: 1, description: "sunny")],
                                dtTxt: Date())
            )
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }, forecast: { _ in
            Just(
                WeatherForecast(list: [
                    .init(main: .init(humidity: 10, temp: 10, tempMin: 8, tempMax: 12),
                          weather: [.init(id: 1, description: "sunny")],
                          dtTxt: Date())
                ])
            )
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        })

    public static let failed = Self(
        weather: { _ in
            Fail(error: NSError(domain: "", code: 1))
                .eraseToAnyPublisher()
        }, forecast: { _ in
            Fail(error: NSError(domain: "", code: 2))
                .eraseToAnyPublisher()
        })
}

