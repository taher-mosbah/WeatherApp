//
//  MockCacheClient.swift
//  WeatherApp
//
//  Created by Mohamed Mosbah on 30/08/2021.
//

import Foundation
import Combine

extension CacheClient {
    public static let happyPath = Self { _ in
        Just(
            (DayWeather(main: .init(humidity: 10, temp: 10, tempMin: 8, tempMax: 12),
                        weather: [.init(id: 1, description: "sunny")],
                        dtTxt: Date()),
             WeatherForecast(list: [
                .init(main: .init(humidity: 10, temp: 10, tempMin: 8, tempMax: 12),
                      weather: [.init(id: 1, description: "sunny")],
                      dtTxt: Date())
             ])
            )
        )
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    } saveWeather: { _,_  in
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
