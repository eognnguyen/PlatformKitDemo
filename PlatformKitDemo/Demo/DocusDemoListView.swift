//
//  DocusDemoListView.swift
//  PlatformKitDemo
//
//  Step 2 (DocusKit): list of demo-able DocusKit views.
//

import SwiftUI
import DocusKit

struct DocusDemoListView: View {
    var body: some View {
        List {
            Section("Browse") {
                NavigationLink {
                    DocusBrowseDemoView()
                } label: {
                    DemoRow(
                        title: "Cubes & Facets",
                        subtitle: "Fetch accessible cubes and facets",
                        systemImage: "square.stack.3d.up.fill",
                        tint: .teal
                    )
                }
            }
        }
        .navigationTitle("DocusKit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Fetches cubes (`/api/cubes/mine`) and facets (`/api/facets/mine`) in parallel and renders them.
private struct DocusBrowseDemoView: View {
    @State private var cubes: [DocusCube] = []
    @State private var facets: [DocusFacet] = []
    @State private var phase: Phase = .loading

    private enum Phase: Equatable {
        case loading
        case loaded
        case failed(String)
    }

    var body: some View {
        Group {
            switch phase {
            case .loading:
                ProgressView("Loading…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .failed(let message):
                ContentUnavailableView {
                    Label("Couldn't load", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Retry") { Task { await load() } }
                }

            case .loaded:
                content
            }
        }
        .navigationTitle("Cubes & Facets")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private var content: some View {
        List {
            Section {
                if cubes.isEmpty {
                    Text("No cubes").foregroundStyle(.secondary)
                } else {
                    ForEach(cubes) { cube in
                        row(
                            title: cube.name,
                            subtitle: cube.description,
                            trailing: "\(cube.documentCount) docs",
                            systemImage: cube.isPersonal ? "person.crop.square" : "square.stack.3d.up",
                            tint: .teal
                        )
                    }
                }
            } header: {
                Text("Cubes (\(cubes.count))")
            }

            Section {
                if facets.isEmpty {
                    Text("No facets").foregroundStyle(.secondary)
                } else {
                    ForEach(facets) { facet in
                        row(
                            title: facet.name,
                            subtitle: facet.description,
                            trailing: "\(facet.fileCount) files",
                            systemImage: "line.3.horizontal.decrease.circle",
                            tint: .purple
                        )
                    }
                }
            } header: {
                Text("Facets (\(facets.count))")
            }
        }
        .refreshable { await load() }
    }

    private func row(
        title: String,
        subtitle: String?,
        trailing: String,
        systemImage: String,
        tint: Color
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(tint, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            Text(trailing)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private func load() async {
        phase = .loading
        do {
            async let cubesResult = DocusKit.shared.fetchCubes().cubes
            async let facetsResult = DocusKit.shared.fetchFacets().facets
            cubes = try await cubesResult
            facets = try await facetsResult
            phase = .loaded
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}
