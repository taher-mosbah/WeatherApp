//
//  PathMonitorClientMocks.swift
//  WeatherApp
//
//  Created by Mohamed Mosbah on 28/08/2021.
//

import Foundation
import Combine
import Foundation
import Network

extension PathMonitorClient {
    public static let satisfied = Self(
        networkPathPublisher: Just(NetworkPath(status: .satisfied))
            .eraseToAnyPublisher()
    )

    public static let unsatisfied = Self(
        networkPathPublisher: Just(NetworkPath(status: .unsatisfied))
            .eraseToAnyPublisher()
    )
}
