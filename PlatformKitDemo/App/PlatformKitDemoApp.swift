//
//  PlatformKitDemoApp.swift
//  PlatformKitDemo
//
//  Created by Nhut Nguyen on 24/6/26.
//

import SwiftUI

@main
struct PlatformKitDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var initializer = AppInitializer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(initializer)
        }
    }
}
