//
//  AppInitializer.swift
//  PlatformKitDemo
//
//  Owns the EOGKit `LoginController` and exposes the authentication state that
//  gates the demo UI. Trimmed-down version of miRIVR's AppInitializer (no DB).
//

import Foundation
import Combine
import EOGKit2

@MainActor
final class AppInitializer: NSObject, ObservableObject, LoginControllerDelegate {

    @Published var isAuthenticated: Bool = false

    private var loginController: LoginController!
    private var cancellables: Set<AnyCancellable> = []

    @preconcurrency @MainActor
    override init() {
        super.init()

        // The AppDelegate defined the credential agent; the LoginController is
        // what actually asks the user for credentials and presents login UI.
        loginController = LoginController(delegate: self)
        subscribe()
    }

    private func subscribe() {
        // Detect when we suddenly become unauthenticated (e.g. token cleared).
        loginController.credentialAgent.credentialPublisher
            .sink { [weak self] credential in
                if credential?.hasActiveToken() != true {
                    self?.isAuthenticated = false
                }
            }
            .store(in: &cancellables)

        // The login controller releases the UI by posting this notification.
        // That's our signal that the user has satisfied login.
        NotificationCenter.default.publisher(for: .loginControllerWillDismiss)
            .compactMap { [unowned self] notif in
                (notif.object as? LoginController) ?? self.loginController
            }
            .sink { [unowned self] controller in
                if controller.authenticated == true {
                    self.isAuthenticated = true
                }
            }
            .store(in: &cancellables)
    }

    func logout() {
        loginController.logout()
    }
}
