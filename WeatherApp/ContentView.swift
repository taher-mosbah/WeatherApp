//
//  ContentView.swift
//  WeatherApp
//
//  Created by Mohamed Mosbah on 28/08/2021.
//

import SwiftUI
import Combine


public class AppViewModel: ObservableObject {
    @Published var isConnected = true
    @Published var weatherForecast: WeatherForecast?
    @Published var dayWeather: DayWeather?

    var weatherCancellables = Set<AnyCancellable>()
    var pathUpdateCancellable: AnyCancellable?
    
    let weatherClient: WeatherClient
    let pathMonitorClient: PathMonitorClient
    
    public init(
        pathMonitorClient: PathMonitorClient,
        weatherClient: WeatherClient
    ) {
        self.weatherClient = weatherClient
        self.pathMonitorClient = pathMonitorClient
        
        self.pathUpdateCancellable = self.pathMonitorClient.networkPathPublisher
            .map { $0.status == .satisfied }
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isConnected in
                guard let self = self else { return }
                self.isConnected = isConnected
                if self.isConnected {
                    self.refreshWeather()
                } else {
                    self.weatherForecast = nil
                }
            })
    }
    
    func refreshWeather() {
        self.dayWeather = nil
        
        self.weatherClient
            .weather("London")
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print(error)
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] response in
                    self?.dayWeather = response
                }).store(in: &weatherCancellables)

        self.weatherForecast = nil

        self.weatherClient
            .forecast("London")
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print(error)
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] response in
                    self?.weatherForecast = response
                }).store(in: &weatherCancellables)

    }
}

public struct ContentView: View {
    @ObservedObject var viewModel: AppViewModel
    
    public init(viewModel: AppViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ZStack(alignment: .topLeading) {
                    if let dayWeather = self.viewModel.dayWeather {
                        VStack(alignment: .leading) {
                            Text("Today")
                                .font(.headline)
                            Text("Current temp: \(dayWeather.main.temp, specifier: "%.1f")°C")
                                .italic()
                            Text("Current humidity: \(dayWeather.main.humidity, specifier: "%.0f")%")
                                .italic()
                            Text("Max temp: \(dayWeather.main.tempMax, specifier: "%.1f")°C")
                                .underline()
                            Text("Min temp: \(dayWeather.main.tempMin, specifier: "%.1f")°C")
                                .underline()
                        }
                    }
                }
                ZStack(alignment: .bottomTrailing) {
                    if let results = self.viewModel.weatherForecast {
                        List {
                            ForEach(results.list, id: \.id) { weather in
                                VStack(alignment: .leading) {
                                    Text(dayOfWeekFormatter.string(from: weather.dtTxt ?? Date()).capitalized)
                                        .font(.title)

                                    Text("Current temp: \(weather.main.temp, specifier: "%.1f")°C")
                                        .bold()
                                    Text("Current humidity: \(weather.main.humidity, specifier: "%.0f")%")
                                        .bold()
                                    Text("Max temp: \(weather.main.tempMax, specifier: "%.1f")°C")
                                    Text("Min temp: \(weather.main.tempMin, specifier: "%.1f")°C")
                                }
                            }
                        }
                    }
                }
                
                if !self.viewModel.isConnected {
                    HStack {
                        Image(systemName: "exclamationmark.octagon.fill")
                        
                        Text("Not connected to internet")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                }
            }
            .navigationBarTitle("London Weather")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView(
            viewModel: AppViewModel(
                pathMonitorClient: .satisfied,
                weatherClient: .happyPath
            )
        )
    }
}

let dayOfWeekFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    return formatter
}()
