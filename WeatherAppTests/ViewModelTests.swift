//
//  ViewModelTests.swift
//  WeatherAppTests
//
//  Created by Mohamed Mosbah on 30/08/2021.
//

import XCTest
import Combine
@testable import WeatherApp

extension WeatherClient {
    static let unimplemented = Self(
        weather: { _ in fatalError() }
    )
}

extension CacheClient {
    static let unimplemented = Self(
        loadWeather: { _ in fatalError() },
        saveWeather:  { _,_  in fatalError() }
    )
}

class ViewModelTests: XCTestCase {
    func testBasics() throws {
        let appViewModel = AppViewModel(
            pathMonitorClient: .satisfied,
            weatherClient: .happyPath,
            cacheClient: .happyPath
        )

        let mockWeather = (DayWeather(main: .init(humidity: 10, temp: 10, tempMin: 8, tempMax: 12),
                                      weather: [.init(id: 1, description: "sunny")],
                                      dtTxt: Date()),
                           WeatherForecast(list: [
                            .init(main: .init(humidity: 10, temp: 10, tempMin: 8, tempMax: 12),
                                  weather: [.init(id: 1, description: "sunny")],
                                  dtTxt: Date())
                           ])
        )
        XCTAssertTrue(appViewModel.isConnected)
        XCTAssertNil(appViewModel.errorMessage)
        XCTAssertEqual(appViewModel.weather!.0!.main.humidity, mockWeather.0.main.humidity)
        XCTAssertEqual(appViewModel.weather!.0!.main.temp, mockWeather.0.main.temp)
        XCTAssertEqual(appViewModel.weather!.0!.main.tempMin, mockWeather.0.main.tempMin)
        XCTAssertEqual(appViewModel.weather!.0!.main.tempMax, mockWeather.0.main.tempMax)
    }

    func testDisconnected() {
        let viewModel = AppViewModel(
            pathMonitorClient: .unsatisfied,
            weatherClient: .unimplemented,
            cacheClient: .happyPath
        )

        XCTAssertEqual(viewModel.isConnected, false)
    }

    func testPathUpdates() {
        let pathUpdateSubject = PassthroughSubject<NetworkPath, Never>()
        let viewModel = AppViewModel(
            pathMonitorClient: PathMonitorClient(
                networkPathPublisher: pathUpdateSubject
                    .eraseToAnyPublisher()
            ),
            weatherClient: .happyPath,
            cacheClient: .happyPath
        )
        pathUpdateSubject.send(.init(status: .satisfied))
        XCTAssertEqual(viewModel.isConnected, true)
        pathUpdateSubject.send(.init(status: .unsatisfied))
        XCTAssertEqual(viewModel.isConnected, false)
        pathUpdateSubject.send(.init(status: .satisfied))
        XCTAssertEqual(viewModel.isConnected, true)
    }

    // TODO: Add cache interaction tests ..
}
