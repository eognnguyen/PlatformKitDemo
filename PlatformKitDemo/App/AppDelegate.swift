//
//  AppDelegate.swift
//  PlatformKitDemo
//
//  Configures the EOGKit credential agent so PermixKit / CryptixKit network
//  calls can attach the signed-in user's token. Mirrors miRIVR's setup.
//

import UIKit
import EOGKit2
import CameoUIApplication

final class AppDelegate: CameoUIApplicationDelegate {

    func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // App identity used in API headers — required before any API call.
        Globals.appId = DemoConfig.App.appId
        Globals.appName = DemoConfig.App.appName

        // Reuse miRIVR's client registration for the demo (see DemoConfig).
        let loginConfiguration = LoginConfiguration(clientName: DemoConfig.Login.clientName, scopes: DemoConfig.Login.scopes)
        SecureUserInfo.configureSession(with: CredentialAgent(configuration: loginConfiguration))
        return true
    }
}
