//
//  CryptixDemoPlaygroundView.swift
//  PlatformKitDemo
//
//  CryptixKit demo list — pick a flow, then drill into its playground:
//    "No Store"   – encrypt/decrypt with caller-supplied DEK (no server storage)
//    "With Store" – encryptAndStore/decrypt via server DEK
//

import SwiftUI
import StyleKit

struct CryptixDemoPlaygroundView: View {

    var body: some View {
        List {
            Section("Encryption Flows") {
                NavigationLink {
                    CryptixDemoPlaygroundPage(title: "No Store") { CryptixNoStoreDemoView() }
                } label: {
                    DemoRow(
                        title: "No Store",
                        subtitle: "Encrypt/decrypt with caller-supplied DEK (no server storage)",
                        systemImage: "key",
                        tint: .teal
                    )
                }

                NavigationLink {
                    CryptixDemoPlaygroundPage(title: "With Store") { CryptixWithStoreDemoView() }
                } label: {
                    DemoRow(
                        title: "With Store",
                        subtitle: "encryptAndStore / decrypt via server-stored DEK",
                        systemImage: "externaldrive.fill.badge.icloud",
                        tint: .orange
                    )
                }
            }
        }
        .navigationTitle("CryptixKit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CryptixDemoPlaygroundPage<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        ScrollView {
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, CryptixDemoLayout.horizontalPadding)
                .padding(.bottom, CryptixDemoLayout.blockBottomPadding)
        }
        .background(Color.eogBackgroundSecondary.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
struct CryptixDemoPlaygroundView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { CryptixDemoPlaygroundView() }
    }
}
#endif
