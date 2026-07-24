//
//  DemoCatalog.swift
//  PlatformKitDemo
//
//  Describes the Kits available to demo. Choosing a Kit leads to its list of
//  demo-able views.
//

import SwiftUI

enum DemoKit: String, CaseIterable, Identifiable {
    case permix = "PermixKit"
    case cryptix = "CryptixKit"
    case docus = "DocusKit"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .permix:  return "Access control: security roles & group creation"
        case .cryptix: return "Client-side encryption playground (DEK)"
        case .docus:   return "Document browsing: cubes & facets"
        }
    }

    var systemImage: String {
        switch self {
        case .permix:  return "lock.shield.fill"
        case .cryptix: return "lock.rotation"
        case .docus:   return "square.stack.3d.up.fill"
        }
    }

    var tint: Color {
        switch self {
        case .permix:  return .blue
        case .cryptix: return .orange
        case .docus:   return .teal
        }
    }
}
