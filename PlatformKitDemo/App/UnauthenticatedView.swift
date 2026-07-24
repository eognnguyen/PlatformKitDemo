//
//  UnauthenticatedView.swift
//  PlatformKitDemo
//
//  Shown behind EOGKit's login UI while the user is signing in.
//

import SwiftUI

struct UnauthenticatedView: View {
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 52))
                    .foregroundStyle(.secondary)
                Text("Signing in…")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                ProgressView()
            }
        }
    }
}

#Preview {
    UnauthenticatedView()
}
