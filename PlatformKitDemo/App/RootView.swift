//
//  RootView.swift
//  PlatformKitDemo
//
//  Auth gate: shows the DocusKit browse screen when signed in, otherwise the
//  placeholder that sits behind EOGKit's login UI.
//

import SwiftUI
import DocusKit

struct RootView: View {
    @EnvironmentObject private var initializer: AppInitializer

    var body: some View {
        Group {
            if initializer.isAuthenticated {
                DocusBrowseFlowView(title: "Docus") {
                    Button("Log Out", role: .destructive) {
                        initializer.logout()
                    }
                }
            } else {
                UnauthenticatedView()
            }
        }
    }
}
