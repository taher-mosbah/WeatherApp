//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Mohamed Mosbah on 28/08/2021.
//

import SwiftUI

@main
struct WeatherAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: AppViewModel(
                            pathMonitorClient: .live(queue: .main),
                            weatherClient: .live,
                            cacheClient: .live)
            )
        }
    }
}
