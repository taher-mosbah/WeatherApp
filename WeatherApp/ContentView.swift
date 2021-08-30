//
//  ContentView.swift
//  WeatherApp
//
//  Created by Mohamed Mosbah on 28/08/2021.
//

import SwiftUI
import Combine

// TODO: cache data

public class AppViewModel: ObservableObject {
    @Published var isConnected = true
    @Published var errorMessage: String?
    @Published var weather: (DayWeather?, WeatherForecast?)?
    @Published var lastUpdated: Date?

    var cancellables = Set<AnyCancellable>()

    let weatherClient: WeatherClient
    let pathMonitorClient: PathMonitorClient
    
    public init(
        pathMonitorClient: PathMonitorClient,
        weatherClient: WeatherClient
    ) {
        self.weatherClient = weatherClient
        self.pathMonitorClient = pathMonitorClient
        
        self.pathMonitorClient.networkPathPublisher
            .map { $0.status == .satisfied }
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isConnected in
                guard let self = self else { return }
                self.isConnected = isConnected
                if self.isConnected {
                    self.refreshWeather()
                }
            }).store(in: &cancellables)
    }
    
    func refreshWeather() {
        self.weatherClient
            .weather("London")
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
                    self?.weather = response
                    self?.lastUpdated = Date()
                }).store(in: &cancellables)
    }
}

struct ForecastRow: View {
    var weather: DayWeather

    let dayOfWeekAndHourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE 'at' HH 'hours'"
        return formatter
    }()

    var body: some View {
        Text(dayOfWeekAndHourFormatter.string(from: weather.dtTxt ?? Date()).capitalized)
            .font(.title)
        if let wetherDetails = weather.weather.first {
            Text("Description: \(wetherDetails.description)")
                .bold()
        }
        Text("Average temp: \(weather.main.temp, specifier: "%.1f")°C")
            .bold()
        Text("Max temp: \(weather.main.tempMax, specifier: "%.1f")°C")
        Text("Min temp: \(weather.main.tempMin, specifier: "%.1f")°C")
    }
}

struct TodayRow: View {
    var dayWeather: DayWeather
    var lastUpdated: Date?

    let lastUpdatedFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    var body: some View {
        if let wetherDetails = dayWeather.weather.first {
            Text("Description: \(wetherDetails.description.capitalized)")
                .bold()
        }
        Text("Current temp: \(dayWeather.main.temp, specifier: "%.1f")°C")
            .bold()
        Text("Max temp: \(dayWeather.main.tempMax, specifier: "%.1f")°C")
        Text("Min temp: \(dayWeather.main.tempMin, specifier: "%.1f")°C")
        Text("Current humidity: \(dayWeather.main.humidity, specifier: "%.0f")%")
        if let lastUpdated = lastUpdated {
            Text("Last updated: \(lastUpdatedFormatter.string(from: lastUpdated))")
                .fontWeight(.light)
        }
    }
}

struct Toast: View {
    var text: String
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.octagon.fill")
            Text(text)
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.orange)
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
                ZStack(alignment: .bottomTrailing) {
                    if let results = self.viewModel.weather?.1 {
                        List {
                            Section(header: Text("Today")) {
                                if let dayWeather = self.viewModel.weather?.0 {
                                    TodayRow(dayWeather: dayWeather, lastUpdated: self.viewModel.lastUpdated)
                                }
                            }
                            Section(header: Text("5 days forecast")) {
                                ForEach(results.list, id: \.id) { weather in
                                    VStack(alignment: .leading) {
                                        ForecastRow(weather: weather)
                                    }
                                }
                            }
                        }.listStyle(GroupedListStyle())
                        Button(
                            action: { self.viewModel.refreshWeather() }
                        ) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                        }
                        .background(Color.black)
                        .clipShape(Circle())
                        .padding()
                    } else {
                        ProgressView()
                    }
                }
                if let errorMessage = self.viewModel.errorMessage {
                    Toast(text: "Error : \(errorMessage)")
                }
                if !self.viewModel.isConnected {
                    Toast(text: "Not connected to internet")
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
