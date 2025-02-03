//
//  mvvmApp.swift
//  mvvm
//
//  Created by Landon Hollis on 2/1/25.
//

import SwiftUI

@main
struct mvvmApp: App {
    init() {
        NotificationsManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
