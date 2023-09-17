//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Gaultier Moraillon on 15/09/2023.
//

import SwiftUI

@main
struct WeatherAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
