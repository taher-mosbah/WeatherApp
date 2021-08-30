//
//  CacheClientInterface.swift
//  WeatherApp
//
//  Created by Mohamed Mosbah on 30/08/2021.
//

import Foundation
import Combine

public struct CacheClient {
    var loadWeather: (String) -> AnyPublisher<(DayWeather?, WeatherForecast?), Error>
    var saveWeather: (String, (DayWeather, WeatherForecast)) -> AnyPublisher<Void, Error>
}
