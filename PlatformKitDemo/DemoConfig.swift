//
//  DemoConfig.swift
//  PlatformKitDemo
//
//  Single place for values "borrowed" from miRIVR for demo purposes.
//  Replace these when the demo gets its own client / resources.
//

import Foundation
import EOGKit2

enum DemoConfig {

    /// App identity sent to EOG backends (X-AppId / X-AppName headers).
    /// Using the demo app's own identity (login only needs a valid OIDC client).
    enum App {
        static let appId = 9999
        static let appName = "PlatformKitDemo"
    }

    /// Login client reused from miRIVR. The OAuth client is registered
    /// server-side against the app's URL scheme.
    ///
    /// Note: the OAuth callback URL scheme is NOT configured here — it lives in
    /// the `APP_URL_SCHEME` build setting and `CFBundleURLSchemes` in Info.plist,
    /// which is what actually registers the scheme with iOS / EOGKit.
    enum Login {
        /// Client name passed to `LoginConfiguration`.
        /// `OIDCClientName` is `ExpressibleByStringLiteral`, so the literal is
        /// converted automatically.
        static let clientName: OIDCClientName = "platform-all-kit"

        /// OIDC scopes requested at login. Mirrors miRIVR's `.xTokenScopes`.
        static let scopes: [OIDCScope] = .xTokenScopes
    }

    /// Demo resource used by `PermixSecurityView`, copied from miRIVR.
    enum Permix {
        static let demoResourceId = "_a6wrtzdgf8qartne3hsvr0rj"
        static let demoResourceTemplateId = "rt_h8ol9vrpxui1p5mdixuvr76e"
    }

    /// Defaults used by the Cryptix playground demo (Permix scope for stored DEKs).
    enum Cryptix {
        static let permixTemplate = "CRYPTIX_DATA"
        static let permixApp = "CRYPTIX"
    }
}
