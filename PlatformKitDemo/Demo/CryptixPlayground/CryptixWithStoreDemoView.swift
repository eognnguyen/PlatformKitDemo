//
//  CryptixWithStoreDemoView.swift
//  PlatformKitDemo
//

import SwiftUI
import CryptixKit
import StyleKit
import PermixKit

// ─────────────────────────────────────────────────────────
// MARK: - Page 2 · With Store
// ─────────────────────────────────────────────────────────

struct CryptixWithStoreDemoView: View {
    enum Sub: String, CaseIterable { case single = "Single"; case bulk = "Bulk" }
    @State private var sub: Sub = .single

    var body: some View {
        VStack(spacing: 0) {
            CryptixDemoSubModePicker(selection: $sub, title: { $0.rawValue })
            switch sub {
            case .single: WithStoreSingleView()
            case .bulk:   WithStoreBulkView()
            }
        }
    }
}

// MARK: · Page 2 Single
// createPermixResource → encryptAndStore(string/dict/file/data) → DEK info → decrypt(data/base64 + dataId)

private struct WithStoreSingleView: View {

    @State private var dataId         = "ws-single"
    @State private var permixTemplate = DemoConfig.Cryptix.permixTemplate
    @State private var permixApp      = DemoConfig.Cryptix.permixApp
    @State private var isRotate       = false
    @State private var dataType: PlayDataType = .string
    @State private var plaintext      = "Hello CryptixKit!"
    @State private var jsonText       = "{\"name\":\"Demo\",\"value\":42}"
    @State private var fileName       = ""
    @State private var fileType       = ""
    @State private var fileData: Data?

    @State private var isCreatingPermix = false
    @State private var permixResult: String?
    @State private var permixError: String?

    @State private var encryptedData: Data?
    @State private var isEncrypting  = false
    @State private var encryptError: String?

    @State private var retrievedDEK: CryptixDEKInfo?

    @State private var decryptEntries: [WithStoreDecryptEntry] = [WithStoreDecryptEntry()]
    @State private var decryptedText: String?
    @State private var isDecrypting  = false
    @State private var decryptError: String?

    private let cryptix = Cryptix.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CryptixDemoSettingsSection {
                CryptixDemoInputField(label: "DataId", text: $dataId)
                CryptixDemoInputField(label: "Permix Template", text: $permixTemplate)
                CryptixDemoInputField(label: "Permix App", text: $permixApp)
                CryptixDemoToggleField(title: "Rotate DEK", isOn: $isRotate)
            }

            CryptixDemoStepCard(step: "0", title: "createPermixResource(dataId:)") {
                CryptixDemoStageButton(
                    title: "Create Permix Resource",
                    icon: "network.badge.shield.half.filled",
                    loading: isCreatingPermix
                ) { await runCreatePermixResource() }
                if let err = permixError { CryptixDemoErrorLabel(message: err) }
                if let r = permixResult { CryptixDemoResultBox(label: "Result", value: r) }
            }

            if permixResult != nil {
                CryptixDemoStepCard(step: "1", title: encryptTitle) {
                    CryptixDemoBlockHeader(title: "Data Type")
                    CryptixDemoDataTypePicker(selection: $dataType)

                    CryptixDemoEncryptInputFields(
                        type: dataType,
                        plaintext: $plaintext,
                        json: $jsonText,
                        fileName: $fileName,
                        fileType: $fileType,
                        fileData: $fileData
                    )

                    Text(encryptFuncName)
                        .eogStyle(.text03)
                        .foregroundColor(Color.eogLabelSecondary)
                        .padding(.vertical, 8)

                    CryptixDemoStageButton(
                        title: isRotate ? "Encrypt & Rotate" : "Encrypt & Store",
                        icon: "icloud.and.arrow.up",
                        loading: isEncrypting
                    ) { await runEncryptAndStore() }
                    if let err = encryptError { CryptixDemoErrorLabel(message: err) }
                    if let enc = encryptedData {
                        CryptixDemoEncryptedDataView(base64: enc.base64EncodedString()) {
                            CryptixDemoCopyButton(text: enc.base64EncodedString())
                        }
                    }
                }
            }

            if encryptedData != nil {
                CryptixDemoStepCard(step: "2", title: "DEK Info") {
                    if let dek = retrievedDEK {
                        CryptixDemoDEKInfoCard(dek: dek)
                    } else {
                        Text("DEK info unavailable.")
                            .eogStyle(.text03)
                            .foregroundColor(Color.eogLabelSecondary)
                    }
                }

                CryptixDemoWithStoreDecryptSection(
                    isBulkMode: false,
                    entries: $decryptEntries,
                    isDecrypting: $isDecrypting,
                    decryptError: $decryptError,
                    singleResult: $decryptedText,
                    bulkResults: .constant([]),
                    onDecrypt: { await runDecrypt() },
                    onAutoFill: { autoFillDecrypt() }
                )
            }
        }
    }

    private var encryptTitle: String {
        isRotate ? "encryptAndStore(...isRotate: true)" : "encryptAndStore(...)"
    }

    private var encryptFuncName: String {
        let r = isRotate ? ", isRotate: true" : ""
        switch dataType {
        case .string:  return "encryptAndStore(string:dataId:\(r)...)"
        case .dict:    return "encryptAndStore(dict:dataId:\(r)...)"
        case .file:    return "encryptAndStore(file:dataId:\(r)...)"
        case .rawData: return ""
        }
    }

    private func autoFillDecrypt() {
        if decryptEntries.isEmpty {
            decryptEntries = [WithStoreDecryptEntry()]
        }
        fillWithStoreDecryptEntry(
            &decryptEntries[0],
            dataId: dataId,
            permixTemplate: permixTemplate,
            encrypted: encryptedData
        )
        decryptError = nil
        decryptedText = nil
    }

    private func runCreatePermixResource() async {
        isCreatingPermix = true
        permixError = nil
        permixResult = nil
        encryptedData = nil
        retrievedDEK = nil
        encryptError = nil
        decryptEntries = [WithStoreDecryptEntry()]
        decryptedText = nil
        decryptError = nil
        defer { isCreatingPermix = false }
        do {
            try await cryptix.createPermixResource(dataId: dataId, permixTemplateAccessString: permixTemplate)
            permixResult = "✓ Permix resource created — dataId=\(dataId)"
        } catch { permixError = error.localizedDescription }
    }

    private func runEncryptAndStore() async {
        isEncrypting = true; encryptError = nil; encryptedData = nil
        retrievedDEK = nil; decryptedText = nil; decryptError = nil
        decryptEntries = [WithStoreDecryptEntry()]
        defer { isEncrypting = false }
        do {
            switch dataType {
            case .string:
                let b64 = try await cryptix.encryptAndStore(
                    string: plaintext, dataId: dataId, isRotate: isRotate,
                    permixTemplateAccessString: permixTemplate, permixApp: permixApp)
                encryptedData = Data(base64Encoded: b64)
            case .dict:
                guard let d = jsonText.asJSONObject() else { encryptError = "Invalid JSON"; return }
                let b64 = try await cryptix.encryptAndStore(
                    dict: d, dataId: dataId, isRotate: isRotate,
                    permixTemplateAccessString: permixTemplate, permixApp: permixApp)
                encryptedData = Data(base64Encoded: b64)
            case .file:
                guard let fd = fileData, !fileName.isEmpty else {
                    encryptError = "Choose a file to encrypt."
                    return
                }
                encryptedData = try await cryptix.encryptAndStore(
                    file: fd, dataId: dataId, fileName: fileName, fileSize: fd.count,
                    fileType: fileType.isEmpty ? "application/octet-stream" : fileType,
                    isRotate: isRotate, permixTemplateAccessString: permixTemplate, permixApp: permixApp)
            case .rawData:
                break
            }
            if encryptedData != nil {
                retrievedDEK = try? await cryptix.retrieveDEKInfo(
                    dataId: dataId,
                    permixTemplateAccessString: permixTemplate
                )
            }
        } catch { encryptError = error.localizedDescription }
    }

    private func runDecrypt() async {
        guard let entry = decryptEntries.first else { return }
        let b64 = entry.encryptedBase64.trimmingCharacters(in: .whitespacesAndNewlines)
        let id = entry.dataId.trimmingCharacters(in: .whitespacesAndNewlines)
        let template = entry.permixTemplate.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !b64.isEmpty, !id.isEmpty else { return }
        isDecrypting = true; decryptError = nil; decryptedText = nil
        defer { isDecrypting = false }
        do {
            decryptedText = formatDecryptResult(
                try await cryptix.decrypt(
                    encryptedBase64: b64,
                    dataId: id,
                    permixTemplateAccessString: template.isEmpty ? DemoConfig.Cryptix.permixTemplate : template
                ))
        } catch { decryptError = error.localizedDescription }
    }
}

// MARK: · Page 2 Bulk
// createPermixResource(bulk) → encryptBulkAndStore → decryptBulk

private struct WithStoreBulkView: View {

    @State private var bulkInput      = "ws-bulk-1|First item\nws-bulk-2|Second item"
    @State private var permixTemplate = DemoConfig.Cryptix.permixTemplate
    @State private var permixApp      = DemoConfig.Cryptix.permixApp
    @State private var isRotate       = false

    @State private var permixCreatedIds: Set<String> = []
    @State private var isCreatingPermix = false
    @State private var permixBulkResult: String?
    @State private var permixBulkError: String?

    @State private var encItems: [(dataId: String, data: Data)] = []
    @State private var dekMap: [String: CryptixDEKInfo] = [:]
    @State private var isEncrypting  = false
    @State private var encryptError: String?

    @State private var decryptEntries: [WithStoreDecryptEntry] = [WithStoreDecryptEntry()]
    @State private var decRows: [TextRow] = []
    @State private var isDecrypting  = false
    @State private var decryptError: String?

    private let cryptix = Cryptix.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CryptixDemoSettingsSection {
                CryptixDemoInputField(label: "Permix Template", text: $permixTemplate)
                CryptixDemoInputField(label: "Permix App", text: $permixApp)
                CryptixDemoToggleField(title: "Rotate DEK", isOn: $isRotate)
            }

            CryptixDemoLabeledSection(title: "Input", subtitle: "One line per item: dataId|plaintext") {
                CryptixDemoBulkInputField(title: "Bulk Items", text: $bulkInput)
            }

            CryptixDemoStepCard(step: "0", title: "createPermixResource(dataId:) — bulk") {
                CryptixDemoStageButton(
                    title: "Create Permix Resources",
                    icon: "network.badge.shield.half.filled",
                    loading: isCreatingPermix
                ) { await runCreatePermixBulk() }
                if let err = permixBulkError { CryptixDemoErrorLabel(message: err) }
                if let result = permixBulkResult {
                    CryptixDemoResultBox(label: "Result", value: result)
                }
            }

            if !permixCreatedIds.isEmpty {
                CryptixDemoStepCard(
                    step: "1",
                    title: isRotate ? "encryptBulkAndStore(isRotate: true)" : "encryptBulkAndStore(...)"
                ) {
                    CryptixDemoStageButton(
                        title: isRotate ? "Encrypt Bulk & Rotate" : "Encrypt Bulk & Store",
                        icon: "rectangle.stack.badge.plus",
                        loading: isEncrypting
                    ) { await runEncryptBulkAndStore() }
                    if let err = encryptError { CryptixDemoErrorLabel(message: err) }
                    CryptixDemoBulkEncryptedList(
                        items: encItems.map {
                            CryptixDemoBulkEncryptedItem(dataId: $0.dataId, base64: $0.data.base64EncodedString())
                        },
                        dekByDataId: dekMap
                    )
                }

                if !encItems.isEmpty {
                    CryptixDemoWithStoreDecryptSection(
                        isBulkMode: true,
                        entries: $decryptEntries,
                        isDecrypting: $isDecrypting,
                        decryptError: $decryptError,
                        singleResult: .constant(nil),
                        bulkResults: $decRows,
                        onDecrypt: { await runDecryptBulk() },
                        onAutoFill: { autoFillDecryptBulk() },
                        step: "2",
                        autoFillTitle: "Auto Fill"
                    )
                }
            }
        }
    }

    private func runCreatePermixBulk() async {
        isCreatingPermix = true
        permixBulkError = nil
        permixBulkResult = nil
        permixCreatedIds = []
        encItems = []
        dekMap = [:]
        encryptError = nil
        decryptEntries = [WithStoreDecryptEntry()]
        decRows = []
        decryptError = nil
        defer { isCreatingPermix = false }

        let ids = Array(Set(parseBulkLines(bulkInput).map(\.dataId)))
        guard !ids.isEmpty else {
            permixBulkError = "Enter at least one dataId|text line."
            return
        }

        var created: [String] = []
        var errors: [String] = []
        for id in ids.sorted() {
            do {
                try await cryptix.createPermixResource(
                    dataId: id,
                    permixTemplateAccessString: permixTemplate
                )
                created.append(id)
            } catch {
                errors.append("\(id): \(error.localizedDescription)")
            }
        }

        permixCreatedIds = Set(created)
        if created.isEmpty {
            permixBulkError = errors.joined(separator: "\n")
        } else {
            permixBulkResult = "✓ \(created.count) permix resource(s) created — \(created.joined(separator: ", "))"
            if !errors.isEmpty {
                permixBulkError = "Partial failure:\n\(errors.joined(separator: "\n"))"
            }
        }
    }

    private func runEncryptBulkAndStore() async {
        isEncrypting = true
        encryptError = nil
        encItems = []
        dekMap = [:]
        decRows = []
        decryptError = nil
        defer { isEncrypting = false }

        let pairs = parseBulkLines(bulkInput)
        guard !pairs.isEmpty else { encryptError = "Enter at least one line."; return }
        do {
            let items = pairs.map {
                CryptixEncryptAndStoreBulkItem(
                    dataId: $0.dataId,
                    data: Data($0.text.utf8),
                    metadata: nil,
                    dataType: .string
                )
            }
            let results = try await cryptix.encryptBulkAndStore(
                items: items,
                isRotate: isRotate,
                permixTemplateAccessString: permixTemplate,
                permixApp: permixApp
            )
            encItems = zip(pairs, results).compactMap { p, r in
                guard case .success(let d) = r else { return nil }
                return (p.dataId, d)
            }

            var fetched: [String: CryptixDEKInfo] = [:]
            for item in encItems {
                if let dek = try? await cryptix.retrieveDEKInfo(
                    dataId: item.dataId,
                    permixTemplateAccessString: permixTemplate
                ) {
                    fetched[item.dataId] = dek
                }
            }
            dekMap = fetched
        } catch { encryptError = error.localizedDescription }
    }

    private func autoFillDecryptBulk() {
        guard !encItems.isEmpty else {
            decryptError = "Encrypt bulk first, then auto fill decrypt fields."
            return
        }
        decryptEntries = encItems.map { item in
            var entry = WithStoreDecryptEntry()
            fillWithStoreDecryptEntry(
                &entry,
                dataId: item.dataId,
                permixTemplate: permixTemplate,
                encrypted: item.data
            )
            return entry
        }
        decryptError = nil
        decRows = []
    }

    private func runDecryptBulk() async {
        isDecrypting = true
        decryptError = nil
        decRows = []
        defer { isDecrypting = false }

        var rows: [TextRow] = []
        for entry in decryptEntries {
            let label = entry.dataId.trimmingCharacters(in: .whitespaces).isEmpty
                ? "Entry"
                : entry.dataId
            let b64 = entry.encryptedBase64.trimmingCharacters(in: .whitespacesAndNewlines)
            let id = entry.dataId.trimmingCharacters(in: .whitespacesAndNewlines)
            let template = entry.permixTemplate.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !b64.isEmpty, !id.isEmpty else {
                rows.append(TextRow(key: label, value: "DataId and encrypted base64 are required.", isError: true))
                continue
            }
            do {
                let result = try await cryptix.decrypt(
                    encryptedBase64: b64,
                    dataId: id,
                    permixTemplateAccessString: template.isEmpty ? DemoConfig.Cryptix.permixTemplate : template
                )
                rows.append(TextRow(key: label, value: formatDecryptResult(result), isError: false))
            } catch {
                rows.append(TextRow(key: label, value: error.localizedDescription, isError: true))
            }
        }
        decRows = rows
    }
}
