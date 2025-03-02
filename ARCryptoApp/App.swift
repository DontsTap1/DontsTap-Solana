//
//  AppDelegate.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 11.01.2025.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseAppCheck

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Use Firebase library to configure APIs
        AppCheck.setAppCheckProviderFactory(AppCheckService())
        FirebaseApp.configure()

        return true
    }
}

@main
struct ARCryptoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .topToolbar()
            }
        }
    }
}
