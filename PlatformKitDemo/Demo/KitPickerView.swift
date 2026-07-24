//
//  KitPickerView.swift
//  PlatformKitDemo
//
//  Step 1 of the demo flow: pick a Kit, then drill into its views.
//

import SwiftUI

struct KitPickerView: View {
    @EnvironmentObject private var initializer: AppInitializer

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(DemoKit.allCases) { kit in
                        NavigationLink {
                            destination(for: kit)
                        } label: {
                            KitRow(kit: kit)
                        }
                    }
                } header: {
                    Text("Choose a Kit")
                } footer: {
                    Text("Each Kit exposes one or more views to demo. APIs use the signed-in user's token.")
                }
            }
            .navigationTitle("EOG Kit Demo")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Log Out", role: .destructive) {
                        initializer.logout()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func destination(for kit: DemoKit) -> some View {
        switch kit {
        case .permix:  PermixDemoListView()
        case .cryptix: CryptixDemoPlaygroundView()
        case .docus:   DocusDemoListView()
        }
    }
}

private struct KitRow: View {
    let kit: DemoKit

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: kit.systemImage)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(kit.tint, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(kit.rawValue).font(.headline)
                Text(kit.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
