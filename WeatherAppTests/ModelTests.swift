//
//  ModelTests.swift
//  WeatherAppTests
//
//  Created by Mohamed Mosbah on 30/08/2021.
//

import XCTest
@testable import WeatherApp

class ModelTests: XCTestCase {
    let dayFixture =
        """
            {
              "coord": {
                "lon": -0.1257,
                "lat": 51.5085
              },
              "weather": [
                {
                  "id": 803,
                  "main": "Clouds",
                  "description": "broken clouds",
                  "icon": "04n"
                }
              ],
              "base": "stations",
              "main": {
                "temp": 15.98,
                "feels_like": 15.59,
                "temp_min": 13.89,
                "temp_max": 17.49,
                "pressure": 1027,
                "humidity": 75
              },
              "visibility": 10000,
              "wind": {
                "speed": 1.54,
                "deg": 0
              },
              "clouds": {
                "all": 52
              },
              "dt": 1630181098,
              "sys": {
                "type": 2,
                "id": 2006068,
                "country": "GB",
                "sunrise": 1630127223,
                "sunset": 1630177010
              },
              "timezone": 3600,
              "id": 2643743,
              "name": "London",
              "cod": 200
            }
            """
        .data(using: .utf8) ?? Data()

    /// TODO: Similar test for `WeatherForecast`
    func testDayWeatherDecoding() throws {
        let dto = try givenDayWeather(data: dayFixture)

        XCTAssert(dto.main.humidity == 75)
        XCTAssert(dto.main.temp == 15.98)
        XCTAssert(dto.main.tempMin == 13.89)
        XCTAssert(dto.main.tempMax == 17.49)
    }

    func givenDayWeather(data: Data) throws -> DayWeather {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return try decoder.decode(DayWeather.self, from: data)
    }
}
