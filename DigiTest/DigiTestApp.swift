//
//  DigiTestApp.swift
//  DigiTest
//
//  Created by Anton Lyfar on 16.10.2023.
//

import SwiftUI

@main
struct DigiTestApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                UKCatalogView()
                    .tabItem {
                        Label("UIKit", systemImage: "square.3.layers.3d.down.right")

                    }

                CatalogView()
                    .tabItem {
                        Label("SwiftUI+Combine", systemImage: "swift")
                    }
            }
        }
    }
}
