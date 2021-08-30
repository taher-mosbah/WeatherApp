//
//  AppViewModel.swift
//  WeatherApp
//
//  Created by Mohamed Mosbah on 30/08/2021.
//

import Foundation
import Combine

public class AppViewModel: ObservableObject {
    @Published var isConnected = true
    @Published var errorMessage: String?
    @Published var weather: (DayWeather?, WeatherForecast?)?
    @Published var lastUpdated: Date?

    var cancellables = Set<AnyCancellable>()

    let weatherClient: WeatherClient
    let pathMonitorClient: PathMonitorClient
    let cacheClient: CacheClient

    let cacheDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    public init(
        pathMonitorClient: PathMonitorClient,
        weatherClient: WeatherClient,
        cacheClient: CacheClient
    ) {
        self.weatherClient = weatherClient
        self.pathMonitorClient = pathMonitorClient
        self.cacheClient = cacheClient

        self.pathMonitorClient.networkPathPublisher
            .map { $0.status == .satisfied }
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isConnected in
                guard let self = self else { return }
                self.isConnected = isConnected
                if self.isConnected {
                    self.refreshWeather()
                } else {
                    self.loadFromCache()
                }
            }).store(in: &cancellables)
    }

    func refreshWeather() {
        self.weatherClient
            .weather("London")
            .handleEvents(receiveOutput: { [weak self] weather in
                guard let self = self else { return }
                let date = self.cacheDateFormatter.string(from: self.lastUpdated ?? Date())
                self.cacheClient.saveWeather(date, weather)
                    .sink(receiveCompletion: { _ in } , receiveValue: { _ in })
                    .store(in: &self.cancellables)
            })
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        print(error)
                        // TODO: we can transform errors to more user friendly messages ...
                        self?.errorMessage = error.localizedDescription
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    self.lastUpdated = Date()
                    self.weather = response
                }).store(in: &cancellables)
    }

    func loadFromCache() {
        self.cacheClient
            .loadWeather(cacheDateFormatter.string(from: Date()))
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    self.weather = response
                }).store(in: &cancellables)
    }
}
