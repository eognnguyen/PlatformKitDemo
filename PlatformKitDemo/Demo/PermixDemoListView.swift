//
//  PermixDemoListView.swift
//  PlatformKitDemo
//
//  Step 2 (PermixKit): list of demo-able PermixKit views.
//

import SwiftUI
import PermixKit

struct PermixDemoListView: View {
    var body: some View {
        List {
            Section("Permission Control") {
                NavigationLink {
                    PermixSecurityDemoView()
                } label: {
                    DemoRow(
                        title: "Security View",
                        subtitle: "Roles & access rules for a resource",
                        systemImage: "lock.shield.fill",
                        tint: .blue
                    )
                }
            }

            Section("Group Creation") {
                NavigationLink {
                    PermixGroupsListView()
                } label: {
                    DemoRow(
                        title: "View Groups",
                        subtitle: "Browse shadow groups and create new ones",
                        systemImage: "person.3.fill",
                        tint: .indigo
                    )
                }
            }
        }
        .navigationTitle("PermixKit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Lets you tweak the resource before opening ``PermixSecurityView``.
/// Defaults mirror miRIVR's demo resource.
private struct PermixSecurityDemoView: View {
    @State private var resourceId = DemoConfig.Permix.demoResourceId
    @State private var resourceTemplateId = DemoConfig.Permix.demoResourceTemplateId

    var body: some View {
        Form {
            Section {
                LabeledField(label: "Resource ID", text: $resourceId)
                LabeledField(label: "Resource Template ID", text: $resourceTemplateId)
            } header: {
                Text("Configuration")
            } footer: {
                Text("Pre-filled with the miRIVR demo resource. Edit to point at another resource.")
            }

            Section {
                NavigationLink {
                    PermixSecurityView(
                        resourceId: resourceId,
                        resourceTemplate: PermixResourceTemplateIdentifier(id: resourceTemplateId)
                    )
                } label: {
                    Label("Open Security View", systemImage: "arrow.right.circle.fill")
                }
                .disabled(resourceId.isEmpty || resourceTemplateId.isEmpty)
            }
        }
        .navigationTitle("Security View")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LabeledField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            TextField(label, text: $text)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .font(.callout.monospaced())
        }
    }
}
