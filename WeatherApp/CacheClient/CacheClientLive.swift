//
//  CacheClientLive.swift
//  WeatherApp
//
//  Created by Mohamed Mosbah on 30/08/2021.
//

import Foundation
import Combine
import Cache

extension CacheClient {
    static let dayStorage: Storage<String, DayWeather>? = {
        let diskConfig = DiskConfig(name: "Floppy")
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)

        let storage = try? Storage<String, DayWeather>(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: DayWeather.self)
        )
        return storage
    }()

    static let forecastStorage: Storage<String, WeatherForecast>? = {
        let diskConfig = DiskConfig(name: "Floppy")
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)

        let storage = try? Storage<String, WeatherForecast>(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: WeatherForecast.self)
        )
        return storage
    }()

    // Usually the user does not care if saving to / loading from cache failed, but maybe we can do better ..
    public static let live = Self { key in
        Just((try? CacheClient.dayStorage?.entry(forKey: key).object,
              try? CacheClient.forecastStorage?.entry(forKey: key).object))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    } saveWeather: { (date, weather) in
        do {
            try dayStorage?.setObject(weather.0, forKey: date)
            try forecastStorage?.setObject(weather.1, forKey: date)
        } catch let error {
            print("Error saving to cache \(error)")
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
