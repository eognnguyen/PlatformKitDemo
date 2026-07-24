//
//  CryptixDemoStyle.swift
//  PlatformKitDemo
//
//  PermixKit-aligned layout tokens and rounded-card helpers for Cryptix demos.
//

import SwiftUI
import StyleKit
import PermixKit

// MARK: - Layout tokens

enum CryptixDemoLayout {
    static let horizontalPadding: CGFloat = 16
    /// Vertical gap between stacked sections and step cards (Permix card rhythm).
    static let sectionSpacing: CGFloat = 8
    static let blockBottomPadding: CGFloat = 32
    /// Spacing between sibling controls inside a step card.
    static let cardContentSpacing: CGFloat = 8
    static let cardCornerRadius: CGFloat = 12
    static let rowHeight: CGFloat = 40
    static let iconSize: CGFloat = 20
    static let inputHorizontalPadding: CGFloat = 12
    static let buttonCornerRadius: CGFloat = 20
}

/// Where a field sits in the demo hierarchy — drives fill contrast.
enum CryptixDemoFieldSurface {
    /// Field on the page background (outside a step card).
    case page
    /// Field inside a primary step/settings card.
    case card
}

private struct CryptixDemoFieldSurfaceKey: EnvironmentKey {
    static let defaultValue: CryptixDemoFieldSurface = .page
}

extension EnvironmentValues {
    var cryptixDemoFieldSurface: CryptixDemoFieldSurface {
        get { self[CryptixDemoFieldSurfaceKey.self] }
        set { self[CryptixDemoFieldSurfaceKey.self] = newValue }
    }
}

// MARK: - Corner mask

struct CryptixDemoRoundedCornerMask: OptionSet, Sendable {
    let rawValue: UInt8

    static let topLeading = Self(rawValue: 1 << 0)
    static let topTrailing = Self(rawValue: 1 << 1)
    static let bottomLeading = Self(rawValue: 1 << 2)
    static let bottomTrailing = Self(rawValue: 1 << 3)
    static let all: Self = [.topLeading, .topTrailing, .bottomLeading, .bottomTrailing]
}

// MARK: - Rounded background

private struct CryptixDemoRoundedBackgroundModifier: ViewModifier {
    var cornerRadius: CGFloat
    var fill: Color
    var roundedCorners: CryptixDemoRoundedCornerMask?

    func body(content: Content) -> some View {
        let mask = roundedCorners ?? .all
        let radii = RectangleCornerRadii(
            topLeading: mask.contains(.topLeading) ? cornerRadius : 0,
            bottomLeading: mask.contains(.bottomLeading) ? cornerRadius : 0,
            bottomTrailing: mask.contains(.bottomTrailing) ? cornerRadius : 0,
            topTrailing: mask.contains(.topTrailing) ? cornerRadius : 0
        )
        content.background(
            UnevenRoundedRectangle(cornerRadii: radii, style: .continuous)
                .fill(fill)
        )
    }
}

extension View {
    func cryptixDemoRoundedBackground(
        cornerRadius: CGFloat = CryptixDemoLayout.cardCornerRadius,
        fill: Color = Color.eogBackgroundPrimary,
        roundedCorners: CryptixDemoRoundedCornerMask? = nil
    ) -> some View {
        modifier(
            CryptixDemoRoundedBackgroundModifier(
                cornerRadius: cornerRadius,
                fill: fill,
                roundedCorners: roundedCorners
            )
        )
    }

    func cryptixDemoInputSectionLayout() -> some View {
        padding(.top, 16)
    }

    /// Recessed field chrome — soft fill only, no border.
    func cryptixDemoInputChrome(
        surface: CryptixDemoFieldSurface = .page,
        cornerRadius: CGFloat = CryptixDemoLayout.cardCornerRadius
    ) -> some View {
        let fill: Color = switch surface {
        case .page: Color.eogSearchBar.opacity(0.65)
        case .card: Color.eogBackgroundSecondary.opacity(0.45)
        }
        return background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(fill)
        )
    }

    /// Filled primary action — full-width tappable control.
    func cryptixDemoPrimaryButtonChrome(
        cornerRadius: CGFloat = CryptixDemoLayout.buttonCornerRadius,
        isEnabled: Bool = true
    ) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.eogGlobalPrimary.opacity(isEnabled ? 1 : 0.45))
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.black.opacity(isEnabled ? 0.08 : 0), lineWidth: 1)
        )
        .shadow(
            color: Color.eogGlobalPrimary.opacity(isEnabled ? 0.30 : 0),
            radius: 8,
            x: 0,
            y: 3
        )
    }

    /// Nested card inside a step card — matches bulk encrypted list contrast.
    func cryptixDemoBulkEntryCard() -> some View {
        padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cryptixDemoRoundedBackground(fill: Color.eogBackgroundSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: CryptixDemoLayout.cardCornerRadius, style: .continuous)
                    .strokeBorder(Color.eogSeparator.opacity(0.5), lineWidth: 1)
            )
    }

    /// Outlined secondary action — visible affordance without competing with primary CTAs.
    func cryptixDemoSecondaryButtonChrome(
        cornerRadius: CGFloat = CryptixDemoLayout.buttonCornerRadius
    ) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.eogBackgroundPrimary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.eogGlobalPrimary.opacity(0.55), lineWidth: 1.5)
        )
    }
}

// MARK: - Section header

struct CryptixDemoBlockHeader: View {
    let title: String
    var subtitle: String?
    /// When true, omits extra top inset — use for the first header inside a card section.
    var isSectionHeader: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .eogStyle(.text01, .emphasis)
                .foregroundColor(Color.eogLabelPrimary)
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .eogStyle(.text03)
                    .foregroundColor(Color.eogLabelSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, isSectionHeader ? 0 : 16)
        .padding(.bottom, 10)
    }
}

// MARK: - Option row (PermixOptionRow-style)

struct CryptixDemoOptionRow<Leading: View, Trailing: View>: View {
    let leading: Leading
    let title: String
    let subtitle: String?
    let trailing: Trailing
    var showBottomDivider: Bool
    var onTap: (() -> Void)?
    @Environment(\.cryptixDemoFieldSurface) private var surface

    private var rowInset: CGFloat {
        surface == .page ? CryptixDemoLayout.horizontalPadding : 0
    }

    init(
        showBottomDivider: Bool = false,
        onTap: (() -> Void)? = nil,
        @ViewBuilder leading: () -> Leading,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.showBottomDivider = showBottomDivider
        self.onTap = onTap
        self.leading = leading()
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                if let onTap {
                    Button(action: onTap) { rowContent }
                        .buttonStyle(.plain)
                } else {
                    rowContent
                }
            }
            if showBottomDivider {
                Divider()
                    .background(Color.eogSeparator.opacity(0.5))
                    .padding(.leading, rowInset)
            }
        }
    }

    private var rowContent: some View {
        HStack(spacing: 0) {
            leading
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .eogStyle(.text01)
                    .foregroundColor(Color.eogLabelPrimary)
                    .lineLimit(2)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .eogStyle(.text03)
                        .foregroundColor(Color.eogLabelSecondary)
                        .lineLimit(2)
                }
            }
            .padding(.leading, 10)
            Spacer(minLength: 8)
            trailing
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

// MARK: - Option picker

struct CryptixDemoOptionPicker<Selection: Hashable>: View {
    @Binding var selection: Selection
    let options: [CryptixDemoOption<Selection>]
    @Environment(\.cryptixDemoFieldSurface) private var surface

    private var optionLeadingInset: CGFloat {
        surface == .page ? CryptixDemoLayout.horizontalPadding : 0
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                CryptixDemoOptionRow(
                    showBottomDivider: index < options.count - 1,
                    onTap: { selection = option.id },
                    leading: {
                        option.icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: CryptixDemoLayout.iconSize, height: CryptixDemoLayout.iconSize)
                            .symbolRenderingMode(.monochrome)
                            .foregroundStyle(Color.eogLabelTertiary)
                            .padding(.leading, optionLeadingInset)
                    },
                    title: option.title,
                    subtitle: option.subtitle,
                    trailing: {
                        Group {
                            if selection == option.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: CryptixDemoLayout.iconSize, height: CryptixDemoLayout.iconSize)
                                    .symbolRenderingMode(.monochrome)
                                    .foregroundStyle(Color.eogGlobalPrimary)
                            } else {
                                Color.clear.frame(width: CryptixDemoLayout.iconSize, height: CryptixDemoLayout.iconSize)
                            }
                        }
                        .padding(.trailing, optionLeadingInset)
                    }
                )
                .cryptixDemoRoundedBackground(
                    fill: .eogBackgroundPrimary,
                    roundedCorners: roundedCorners(index: index, count: options.count)
                )
                .padding(.bottom, index < options.count - 1 ? 8 : 0)
            }
        }
    }

    private func roundedCorners(index: Int, count: Int) -> CryptixDemoRoundedCornerMask? {
        if count == 1 { return nil }
        if index == 0 { return [.topLeading, .topTrailing] }
        if index == count - 1 { return [.bottomLeading, .bottomTrailing] }
        return CryptixDemoRoundedCornerMask(rawValue: 0)
    }
}

struct CryptixDemoOption<ID: Hashable>: Identifiable {
    let id: ID
    let title: String
    let subtitle: String?
    let icon: Image

    init(id: ID, title: String, subtitle: String? = nil, icon: Image) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }
}

// MARK: - Sub-mode picker (Single / Bulk)

struct CryptixDemoSubModePicker<Selection: Hashable & CaseIterable>: View where Selection.AllCases: RandomAccessCollection {
    @Binding var selection: Selection
    let title: (Selection) -> String

    var body: some View {
        Picker("", selection: $selection) {
            ForEach(Array(Selection.allCases), id: \.self) { mode in
                Text(title(mode)).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}
