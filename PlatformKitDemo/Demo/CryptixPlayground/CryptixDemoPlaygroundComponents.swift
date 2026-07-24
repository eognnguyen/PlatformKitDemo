//
//  CryptixDemoPlaygroundComponents.swift
//  PlatformKitDemo
//
//  Reusable SwiftUI components for CryptixKit playground demos.
//  Styled to match PermixKit (StyleKit colors, card layout, spacing).
//

import SwiftUI
import CryptixKit
import StyleKit
import PermixKit
import UniformTypeIdentifiers
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Clipboard

enum CryptixDemoClipboard {
    static func copy(_ text: String) {
#if canImport(UIKit)
        UIPasteboard.general.string = text
#endif
    }
}

// MARK: - Copy

struct CryptixDemoCopyButton: View {
    let text: String
    var label: String = "Copy"

    var body: some View {
        Button {
            CryptixDemoClipboard.copy(text)
        } label: {
            Text(label)
                .eogStyle(.text03)
                .foregroundColor(Color.eogGlobalPrimary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sections

struct CryptixDemoInputSection<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: CryptixDemoLayout.cardContentSpacing) {
            content()
        }
        .environment(\.cryptixDemoFieldSurface, .card)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cryptixDemoRoundedBackground()
        .cryptixDemoInputSectionLayout()
    }
}

struct CryptixDemoLabeledSection<Content: View>: View {
    let title: String
    var subtitle: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        CryptixDemoInputSection {
            CryptixDemoBlockHeader(title: title, subtitle: subtitle, isSectionHeader: true)
            content()
        }
    }
}

struct CryptixDemoStepCard<Content: View>: View {
    let step: String
    let title: String
    var subtitle: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: CryptixDemoLayout.cardContentSpacing) {
            HStack(spacing: 8) {
                Text(step)
                    .eogStyle(.text03, .emphasis)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Color.eogGlobalPrimary, in: Circle())
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
            }
            .padding(.bottom, 2)

            content()
        }
        .environment(\.cryptixDemoFieldSurface, .card)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cryptixDemoRoundedBackground()
        .padding(.top, CryptixDemoLayout.sectionSpacing)
    }
}

struct CryptixDemoSettingsSection<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        CryptixDemoInputSection {
            CryptixDemoBlockHeader(title: "Settings", isSectionHeader: true)
            VStack(spacing: CryptixDemoLayout.cardContentSpacing) {
                content()
            }
        }
    }
}

// MARK: - Inputs

struct CryptixDemoInputField: View {
    let label: String
    @Binding var text: String
    var prompt: String?
    var axis: Axis = .horizontal
    var lineLimit: ClosedRange<Int>?
    var surface: CryptixDemoFieldSurface?
    @Environment(\.cryptixDemoFieldSurface) private var inheritedSurface

    private var resolvedSurface: CryptixDemoFieldSurface {
        surface ?? inheritedSurface
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .eogStyle(.text01, .emphasis)
                .foregroundColor(Color.eogLabelPrimary)
                .padding(.top, resolvedSurface == .page ? 10 : 0)
                .padding(.horizontal, resolvedSurface == .page ? CryptixDemoLayout.horizontalPadding : 0)

            Group {
                if axis == .vertical {
                    TextField(
                        "",
                        text: $text,
                        prompt: fieldPrompt,
                        axis: .vertical
                    )
                    .lineLimit(lineLimit ?? 2...4)
                } else {
                    TextField("", text: $text, prompt: fieldPrompt)
                }
            }
            .font(TextStyle.text01.font)
            .foregroundColor(Color.eogLabelPrimary)
            .tint(Color.eogGlobalPrimary)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.horizontal, CryptixDemoLayout.inputHorizontalPadding)
            .padding(.vertical, axis == .vertical ? 8 : 0)
            .frame(minHeight: CryptixDemoLayout.rowHeight, alignment: .leading)
            .cryptixDemoInputChrome(surface: resolvedSurface)
        }
    }

    private var fieldPrompt: Text {
        Text(prompt ?? label)
            .font(TextStyle.text01.font)
            .foregroundColor(Color.eogLabelTertiary)
    }
}

struct CryptixDemoToggleField: View {
    let title: String
    @Binding var isOn: Bool
    var surface: CryptixDemoFieldSurface?
    @Environment(\.cryptixDemoFieldSurface) private var inheritedSurface

    private var resolvedSurface: CryptixDemoFieldSurface {
        surface ?? inheritedSurface
    }

    var body: some View {
        HStack {
            Text(title)
                .eogStyle(.text01)
                .foregroundColor(Color.eogLabelPrimary)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.eogGlobalPrimary)
        }
        .padding(.horizontal, resolvedSurface == .page ? CryptixDemoLayout.horizontalPadding : 0)
        .frame(height: CryptixDemoLayout.rowHeight)
        .cryptixDemoInputChrome(surface: resolvedSurface)
    }
}

struct CryptixDemoBulkInputField: View {
    let title: String
    @Binding var text: String
    var surface: CryptixDemoFieldSurface?
    @Environment(\.cryptixDemoFieldSurface) private var inheritedSurface

    private var resolvedSurface: CryptixDemoFieldSurface {
        surface ?? inheritedSurface
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .eogStyle(.text01, .emphasis)
                .foregroundColor(Color.eogLabelPrimary)
                .padding(.top, resolvedSurface == .page ? 10 : 0)
                .padding(.horizontal, resolvedSurface == .page ? CryptixDemoLayout.horizontalPadding : 0)

            TextEditor(text: $text)
                .font(TextStyle.text03.font.monospaced())
                .foregroundColor(Color.eogLabelPrimary)
                .tint(Color.eogGlobalPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 96)
                .padding(.horizontal, CryptixDemoLayout.inputHorizontalPadding)
                .padding(.vertical, 8)
                .cryptixDemoInputChrome(surface: resolvedSurface)
        }
    }
}

struct CryptixDemoStageButton: View {
    let title: String
    let icon: String
    let loading: Bool
    var disabled: Bool = false
    let action: () async -> Void

    var body: some View {
        Button {
            Task { await action() }
        } label: {
            HStack(spacing: 10) {
                if loading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(.white)
                    Text(title)
                        .eogStyle(.text01, .emphasis)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: CryptixDemoLayout.rowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
        .cryptixDemoPrimaryButtonChrome(isEnabled: !(loading || disabled))
        .disabled(loading || disabled)
    }
}

struct CryptixDemoDataTypePicker: View {
    @Binding var selection: PlayDataType

    var body: some View {
        CryptixDemoOptionPicker(
            selection: $selection,
            options: PlayDataType.noStoreEncryptCases.map { type in
                CryptixDemoOption(
                    id: type,
                    title: type.rawValue,
                    subtitle: type.subtitle,
                    icon: Image(systemName: type.iconName)
                )
            }
        )
    }
}

struct CryptixDemoEncryptInputFields: View {
    let type: PlayDataType
    @Binding var plaintext: String
    @Binding var json: String
    @Binding var fileName: String
    @Binding var fileType: String
    @Binding var fileData: Data?

    var body: some View {
        switch type {
        case .string, .rawData:
            CryptixDemoInputField(
                label: "Plaintext",
                text: $plaintext,
                prompt: "Enter plaintext",
                axis: .vertical,
                lineLimit: 2...4
            )
        case .dict:
            CryptixDemoInputField(
                label: "JSON Object",
                text: $json,
                prompt: "{\"key\":\"value\"}",
                axis: .vertical,
                lineLimit: 2...4
            )
        case .file:
            CryptixDemoFileUploadField(
                fileData: $fileData,
                fileName: $fileName,
                fileType: $fileType
            )
        }
    }
}

struct CryptixDemoFileUploadField: View {
    @Binding var fileData: Data?
    @Binding var fileName: String
    @Binding var fileType: String
    @Environment(\.cryptixDemoFieldSurface) private var surface
    @State private var showImporter = false
    @State private var importError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let fileData, !fileName.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "doc.fill")
                        .foregroundStyle(Color.eogGlobalPrimary)
                    Text(fileName)
                        .eogStyle(.text01)
                        .foregroundColor(Color.eogLabelPrimary)
                        .lineLimit(1)
                    Spacer()
                    Text("\(fileData.count) bytes")
                        .eogStyle(.text03)
                        .foregroundColor(Color.eogLabelSecondary)
                    Button("Change") { showImporter = true }
                        .buttonStyle(.plain)
                        .foregroundColor(Color.eogGlobalPrimary)
                }
                .padding(.horizontal, CryptixDemoLayout.inputHorizontalPadding)
                .frame(height: CryptixDemoLayout.rowHeight)
                .cryptixDemoInputChrome(surface: surface)

                Button(role: .destructive) {
                    self.fileData = nil
                    fileName = ""
                    fileType = ""
                } label: {
                    Text("Clear file")
                        .eogStyle(.text03)
                        .foregroundColor(Color.eogAddRemove)
                }
                .buttonStyle(.plain)
            } else {
                Button { showImporter = true } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "folder.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Color.eogGlobalPrimary)
                        Text("Choose File")
                            .eogStyle(.text01, .emphasis)
                            .foregroundColor(Color.eogGlobalPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: CryptixDemoLayout.rowHeight)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .cryptixDemoSecondaryButtonChrome()
            }
            if let importError {
                CryptixDemoErrorLabel(message: importError)
            }
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            importError = nil
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                guard url.startAccessingSecurityScopedResource() else {
                    importError = "Cannot access selected file."
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }
                do {
                    let data = try Data(contentsOf: url)
                    fileData = data
                    fileName = url.lastPathComponent
                    let ext = url.pathExtension
                    fileType = UTType(filenameExtension: ext)?.preferredMIMEType ?? "application/octet-stream"
                } catch {
                    importError = error.localizedDescription
                }
            case .failure(let error):
                importError = error.localizedDescription
            }
        }
    }
}

// MARK: - Display

struct CryptixDemoInfoRow: View {
    let key: String
    let value: String
    var maxLines: Int = 2
    var copyable: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(key)
                    .eogStyle(.text03)
                    .foregroundColor(Color.eogLabelSecondary)
                Spacer(minLength: 8)
                if copyable {
                    CryptixDemoCopyButton(text: value)
                }
            }
            Text(value)
                .font(TextStyle.text03.font.monospaced())
                .foregroundColor(Color.eogLabelPrimary)
                .lineLimit(maxLines)
                .textSelection(.enabled)
        }
    }
}

struct CryptixDemoDEKInfoCard: View {
    let dek: CryptixDEKInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(Color.permixSuccessText)
                Text("DEK Info")
                    .eogStyle(.text01, .emphasis)
                    .foregroundColor(Color.permixSuccessText)
            }
            CryptixDemoInfoRow(key: "dekVersion", value: dek.dekVersion ?? "—", copyable: true)
            CryptixDemoInfoRow(key: "rawDEK (b64)", value: dek.rawDEK.base64EncodedString(), copyable: true)
            CryptixDemoInfoRow(key: "IV (b64)", value: dek.iv.base64EncodedString(), copyable: true)
            if let tag = dek.authTag {
                CryptixDemoInfoRow(key: "authTag (b64)", value: tag.base64EncodedString(), copyable: true)
            }
            if let enc = dek.encryptedDEK {
                CryptixDemoInfoRow(key: "encryptedDEK (b64)", value: enc.base64EncodedString(), maxLines: 3, copyable: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cryptixDemoRoundedBackground(fill: Color.permixSuccessBackground)
    }
}

struct CryptixDemoMonospacedScrollText: View {
    let text: String
    var maxHeight: CGFloat = 120

    var body: some View {
        ScrollView {
            Text(text)
                .font(TextStyle.text03.font.monospaced())
                .foregroundColor(Color.eogLabelPrimary)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: maxHeight)
    }
}

struct CryptixDemoResultBox: View {
    let label: String
    let value: String
    var isError: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .eogStyle(.text01, .emphasis)
                .foregroundColor(isError ? Color.eogAddRemove : Color.permixSuccessText)
            CryptixDemoMonospacedScrollText(text: value)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cryptixDemoRoundedBackground(fill: isError ? Color.eogAddRemove.opacity(0.08) : Color.permixSuccessBackground)
    }
}

struct CryptixDemoErrorLabel: View {
    let message: String

    var body: some View {
        CryptixDemoResultBox(label: "Error", value: message, isError: true)
    }
}

struct CryptixDemoEncryptedDataView<Trailing: View>: View {
    let base64: String
    @ViewBuilder let trailing: () -> Trailing

    init(
        base64: String,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.base64 = base64
        self.trailing = trailing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(Color.eogGlobalPrimary)
                    Text("Encrypted (Format V1, base64)")
                        .eogStyle(.text01, .emphasis)
                        .foregroundColor(Color.eogLabelPrimary)
                }
                Spacer()
                trailing()
            }
            TextEditor(text: .constant(base64))
                .font(TextStyle.text03.font.monospaced())
                .foregroundColor(Color.eogLabelPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 100, maxHeight: 200)
                .padding(.horizontal, CryptixDemoLayout.inputHorizontalPadding)
                .padding(.vertical, 8)
                .cryptixDemoInputChrome(surface: .card)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CryptixDemoBulkEncryptedItem: Identifiable {
    let dataId: String
    let base64: String
    var id: String { dataId }
}

struct CryptixDemoBulkEncryptedList: View {
    let items: [CryptixDemoBulkEncryptedItem]
    var dekByDataId: [String: CryptixDEKInfo] = [:]

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(item.dataId)
                                .eogStyle(.text01, .emphasis)
                                .foregroundColor(Color.eogLabelPrimary)
                            Spacer()
                            CryptixDemoCopyButton(text: item.base64, label: "Copy")
                        }
                        CryptixDemoMonospacedScrollText(text: item.base64, maxHeight: 160)
                        if let dek = dekByDataId[item.dataId] {
                            CryptixDemoDEKInfoCard(dek: dek)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cryptixDemoRoundedBackground(fill: Color.eogBackgroundSecondary)
                }
            }
        }
    }
}

// MARK: - With Store Decrypt

struct CryptixDemoWithStoreDecryptSection: View {
    let isBulkMode: Bool
    @Binding var entries: [WithStoreDecryptEntry]
    @Binding var isDecrypting: Bool
    @Binding var decryptError: String?
    @Binding var singleResult: String?
    @Binding var bulkResults: [TextRow]
    let onDecrypt: () async -> Void
    let onAutoFill: () -> Void
    var step: String = "3"
    var autoFillTitle: String = "Auto Input"

    var body: some View {
        CryptixDemoStepCard(step: step, title: decryptTitle, subtitle: decryptSubtitle) {
            HStack(spacing: 8) {
                CryptixDemoInlineActionButton(title: autoFillTitle, icon: "arrow.down.doc", action: onAutoFill)
                if isBulkMode {
                    Spacer()
                    CryptixDemoInlineActionButton(title: "Add Entry", icon: "plus.circle") {
                        entries.append(WithStoreDecryptEntry())
                    }
                }
            }
            .padding(.bottom, 8)

            VStack(alignment: .leading, spacing: 12) {
                ForEach($entries) { $entry in
                    CryptixDemoWithStoreDecryptEntryCard(
                        entry: $entry,
                        index: (entries.firstIndex { $0.id == entry.id } ?? 0) + 1,
                        isBulkMode: isBulkMode,
                        canRemove: isBulkMode && entries.count > 1
                    ) {
                        entries.removeAll { $0.id == entry.id }
                    }
                }
            }

            Text(decryptFuncName)
                .eogStyle(.text03)
                .foregroundColor(Color.eogLabelSecondary)
                .padding(.vertical, 8)

            CryptixDemoStageButton(
                title: isBulkMode ? "Decrypt Bulk (via retrieve)" : "Decrypt",
                icon: "lock.open.icloud",
                loading: isDecrypting,
                disabled: !isBulkMode && decryptDisabled
            ) { await onDecrypt() }

            if let err = decryptError { CryptixDemoErrorLabel(message: err) }

            if let result = singleResult {
                CryptixDemoResultBox(label: "Result", value: result)
            }
            if !bulkResults.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(bulkResults) { row in
                        CryptixDemoResultBox(label: row.key, value: row.value, isError: row.isError)
                    }
                }
            }
        }
    }

    private var decryptDisabled: Bool {
        guard let entry = entries.first else { return true }
        return entry.dataId.trimmingCharacters(in: .whitespaces).isEmpty
            || entry.encryptedBase64.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var decryptTitle: String {
        isBulkMode
            ? "decryptBulk(items:) — server DEK (retrieve)"
            : "decrypt — server DEK (retrieve)"
    }

    private var decryptSubtitle: String {
        isBulkMode
            ? "Each entry needs dataId, permix template, and encrypted payload. DEK is fetched online — no manual DEK fields."
            : "Enter dataId and encrypted payload. DEK is fetched from the server — no manual DEK fields."
    }

    private var decryptFuncName: String {
        isBulkMode
            ? "decryptBulk(items:permixTemplateAccessString:)"
            : "decrypt(encryptedBase64:dataId:permixTemplateAccessString:)"
    }
}

struct CryptixDemoWithStoreDecryptEntryCard: View {
    @Binding var entry: WithStoreDecryptEntry
    let index: Int
    let isBulkMode: Bool
    let canRemove: Bool
    let onRemove: () -> Void

    var body: some View {
        if isBulkMode {
            cardContent.cryptixDemoBulkEntryCard()
        } else {
            cardContent
                .padding(.bottom, 8)
        }
    }

    private var entryTitle: String {
        let id = entry.dataId.trimmingCharacters(in: .whitespaces)
        if isBulkMode, !id.isEmpty { return id }
        return canRemove ? "Entry \(index)" : "Decrypt Input"
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entryTitle)
                        .eogStyle(.text01, .emphasis)
                        .foregroundColor(Color.eogLabelPrimary)
                    if isBulkMode {
                        Text("Entry \(index)")
                            .eogStyle(.text03)
                            .foregroundColor(Color.eogLabelSecondary)
                    }
                }
                Spacer()
                if canRemove {
                    Button(role: .destructive, action: onRemove) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(Color.eogAddRemove)
                    }
                    .buttonStyle(.plain)
                }
            }

            if isBulkMode {
                Divider()
                    .background(Color.eogSeparator.opacity(0.5))
                    .padding(.bottom, 4)
            }

            CryptixDemoInputField(label: "DataId", text: $entry.dataId, surface: .card)
            CryptixDemoInputField(label: "Permix Template", text: $entry.permixTemplate, surface: .card)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Encrypted (base64)")
                        .eogStyle(.text03)
                        .foregroundColor(Color.eogLabelSecondary)
                    Spacer()
                    if !entry.encryptedBase64.isEmpty {
                        CryptixDemoCopyButton(text: entry.encryptedBase64)
                    }
                }
                TextEditor(text: $entry.encryptedBase64)
                    .font(TextStyle.text03.font.monospaced())
                    .foregroundColor(Color.eogLabelPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 72, maxHeight: 120)
                    .padding(.horizontal, CryptixDemoLayout.inputHorizontalPadding)
                    .padding(.vertical, 8)
                    .cryptixDemoInputChrome(surface: .card)
            }
        }
    }
}

// MARK: - No Store Decrypt

struct CryptixDemoNoStoreDecryptSection: View {
    let isBulkMode: Bool
    @Binding var entries: [NoStoreDecryptEntry]
    @Binding var isDecrypting: Bool
    @Binding var decryptError: String?
    @Binding var singleResult: String?
    @Binding var bulkResults: [TextRow]
    let onDecrypt: () async -> Void
    let onAutoFill: () -> Void
    var autoFillTitle: String = "Auto Fill"

    var body: some View {
        CryptixDemoStepCard(step: "3", title: decryptTitle, subtitle: decryptSubtitle) {
            HStack(spacing: 8) {
                CryptixDemoInlineActionButton(title: autoFillTitle, icon: "arrow.down.doc", action: onAutoFill)
                if isBulkMode {
                    Spacer()
                    CryptixDemoInlineActionButton(title: "Add Entry", icon: "plus.circle") {
                        entries.append(NoStoreDecryptEntry())
                    }
                }
            }
            .padding(.bottom, 8)

            VStack(alignment: .leading, spacing: 12) {
                ForEach($entries) { $entry in
                    CryptixDemoNoStoreDecryptEntryCard(
                        entry: $entry,
                        index: (entries.firstIndex { $0.id == entry.id } ?? 0) + 1,
                        isBulkMode: isBulkMode,
                        canRemove: isBulkMode && entries.count > 1
                    ) {
                        entries.removeAll { $0.id == entry.id }
                    }
                }
            }

            CryptixDemoStageButton(
                title: isBulkMode ? "Decrypt Bulk (local)" : "Decrypt",
                icon: "lock.open",
                loading: isDecrypting
            ) { await onDecrypt() }

            if let err = decryptError { CryptixDemoErrorLabel(message: err) }

            if let result = singleResult {
                CryptixDemoResultBox(label: "Result", value: result)
            }
            if !bulkResults.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(bulkResults) { row in
                        CryptixDemoResultBox(label: row.key, value: row.value, isError: row.isError)
                    }
                }
            }
        }
    }

    private var decryptTitle: String {
        isBulkMode
            ? "decrypt — per item (local DEK)"
            : "decrypt(encryptedBase64:dekInfo:)"
    }

    private var decryptSubtitle: String {
        isBulkMode
            ? "Each entry is decrypted independently with its own DEK info."
            : "Paste encrypted base64 and DEK fields, or use Auto Fill from the steps above."
    }
}

struct CryptixDemoNoStoreDecryptEntryCard: View {
    @Binding var entry: NoStoreDecryptEntry
    let index: Int
    let isBulkMode: Bool
    let canRemove: Bool
    let onRemove: () -> Void

    var body: some View {
        if isBulkMode {
            cardContent.cryptixDemoBulkEntryCard()
        } else {
            cardContent
                .padding(.bottom, 8)
        }
    }

    private var entryTitle: String {
        let id = entry.dataId.trimmingCharacters(in: .whitespaces)
        if isBulkMode, !id.isEmpty { return id }
        return "Entry \(index)"
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entryTitle)
                        .eogStyle(.text01, .emphasis)
                        .foregroundColor(Color.eogLabelPrimary)
                    if isBulkMode {
                        Text("Entry \(index)")
                            .eogStyle(.text03)
                            .foregroundColor(Color.eogLabelSecondary)
                    }
                }
                Spacer()
                if canRemove {
                    Button(role: .destructive, action: onRemove) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(Color.eogAddRemove)
                    }
                    .buttonStyle(.plain)
                }
            }

            if isBulkMode {
                Divider()
                    .background(Color.eogSeparator.opacity(0.5))
                    .padding(.bottom, 4)
            }

            if !isBulkMode, !entry.dataId.isEmpty {
                CryptixDemoInputField(label: "DataId (label)", text: $entry.dataId, surface: .card)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Encrypted (base64)")
                        .eogStyle(.text03)
                        .foregroundColor(Color.eogLabelSecondary)
                    Spacer()
                    if !entry.encryptedBase64.isEmpty {
                        CryptixDemoCopyButton(text: entry.encryptedBase64)
                    }
                }
                TextEditor(text: $entry.encryptedBase64)
                    .font(TextStyle.text03.font.monospaced())
                    .foregroundColor(Color.eogLabelPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 72, maxHeight: 120)
                    .padding(.horizontal, CryptixDemoLayout.inputHorizontalPadding)
                    .padding(.vertical, 8)
                    .cryptixDemoInputChrome(surface: .card)
            }

            CryptixDemoInputField(label: "rawDEK (b64)", text: $entry.rawDEKB64, surface: .card)
            CryptixDemoInputField(label: "IV (b64)", text: $entry.ivB64, surface: .card)
            CryptixDemoInputField(label: "dekVersion (optional)", text: $entry.dekVersion, surface: .card)
            CryptixDemoInputField(label: "authTag (b64, optional)", text: $entry.authTagB64, surface: .card)
            CryptixDemoInputField(label: "encryptedDEK (b64, optional)", text: $entry.encryptedDEKB64, surface: .card)
        }
    }
}

// MARK: - Inline actions

struct CryptixDemoInlineActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                Text(title)
                    .eogStyle(.text03, .emphasis)
            }
            .foregroundColor(Color.eogGlobalPrimary)
            .padding(.horizontal, 14)
            .frame(height: CryptixDemoLayout.rowHeight - 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .cryptixDemoSecondaryButtonChrome()
    }
}
