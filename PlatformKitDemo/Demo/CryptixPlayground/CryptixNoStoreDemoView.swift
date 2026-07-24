//
//  CryptixNoStoreDemoView.swift
//  PlatformKitDemo
//

import SwiftUI
import CryptixKit
import StyleKit
import PermixKit

// ─────────────────────────────────────────────────────────
// MARK: - Page 1 · No Store
// ─────────────────────────────────────────────────────────

struct CryptixNoStoreDemoView: View {
    enum Sub: String, CaseIterable {
        case single = "Single"
        case bulk   = "Bulk"
    }

    @State private var sub: Sub = .single

    var body: some View {
        VStack(spacing: 0) {
            CryptixDemoSubModePicker(selection: $sub, title: { $0.rawValue })
            switch sub {
            case .single: NoStoreSingleView()
            case .bulk:   NoStoreBulkView()
            }
        }
    }
}

// MARK: · Single
// createDEKInfo → encrypt(string/dict/file:dekInfo) → decrypt(encryptedBase64:dekInfo:)

private struct NoStoreSingleView: View {

    @State private var dataId    = "ns-single"
    @State private var dataType: PlayDataType = .string
    @State private var plaintext = "Hello CryptixKit!"
    @State private var jsonText  = "{\"name\":\"Demo\",\"value\":42}"
    @State private var fileName  = ""
    @State private var fileType  = ""
    @State private var fileData: Data?

    @State private var fetchedDEK: CryptixDEKInfo?
    @State private var isFetching   = false
    @State private var fetchError: String?

    @State private var encryptedData: Data?
    @State private var isEncrypting = false
    @State private var encryptError: String?

    @State private var decryptEntries: [NoStoreDecryptEntry] = [NoStoreDecryptEntry()]
    @State private var isDecrypting = false
    @State private var decryptError: String?
    @State private var decryptResult: String?

    private let cryptix = Cryptix.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CryptixDemoInputSection {
                CryptixDemoInputField(label: "DataId", text: $dataId)
            }

            CryptixDemoStepCard(step: "1", title: "createDEKInfo()") {
                CryptixDemoStageButton(
                    title: "Fetch DEK Info",
                    icon: "key",
                    loading: isFetching,
                    disabled: dataId.trimmingCharacters(in: .whitespaces).isEmpty
                ) { await fetchDEK() }
                if let err = fetchError { CryptixDemoErrorLabel(message: err) }
                if let dek = fetchedDEK { CryptixDemoDEKInfoCard(dek: dek) }
            }

            if fetchedDEK != nil {
                CryptixDemoStepCard(step: "2", title: "Encrypt — caller-supplied DEK") {
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

                    CryptixDemoStageButton(title: "Encrypt", icon: "lock", loading: isEncrypting) {
                        await runEncrypt()
                    }
                    if let err = encryptError { CryptixDemoErrorLabel(message: err) }
                    if let enc = encryptedData {
                        CryptixDemoEncryptedDataView(base64: enc.base64EncodedString()) {
                            CryptixDemoCopyButton(text: enc.base64EncodedString())
                        }
                    }
                }

                if encryptedData != nil {
                    CryptixDemoNoStoreDecryptSection(
                        isBulkMode: false,
                        entries: $decryptEntries,
                        isDecrypting: $isDecrypting,
                        decryptError: $decryptError,
                        singleResult: $decryptResult,
                        bulkResults: .constant([]),
                        onDecrypt: { await runDecrypt() },
                        onAutoFill: { autoFillDecrypt() },
                        autoFillTitle: "Auto Input"
                    )
                }
            }
        }
    }

    private var encryptFuncName: String {
        switch dataType {
        case .string:  return "encrypt(string:dataId:metadata:dekInfo:)"
        case .dict:    return "encrypt(dict:dataId:metadata:dekInfo:)"
        case .file:    return "encrypt(file:dataId:metadata:...:dekInfo:)"
        case .rawData: return "encrypt(data:dataId:metadata:dataType:dekInfo:)"
        }
    }

    private func fetchDEK() async {
        isFetching = true
        fetchError = nil
        fetchedDEK = nil
        encryptedData = nil
        decryptResult = nil
        decryptError = nil
        defer { isFetching = false }
        do { fetchedDEK = try await cryptix.createDEKInfo() }
        catch { fetchError = error.localizedDescription }
    }

    private func runEncrypt() async {
        guard let dek = fetchedDEK else { return }
        isEncrypting = true
        encryptError = nil
        encryptedData = nil
        decryptResult = nil
        defer { isEncrypting = false }
        do {
            switch dataType {
            case .string:
                let b64 = try cryptix.encrypt(string: plaintext, dataId: dataId, dekInfo: dek)
                encryptedData = Data(base64Encoded: b64)
            case .dict:
                guard let d = jsonText.asJSONObject() else { encryptError = "Invalid JSON"; return }
                let b64 = try cryptix.encrypt(dict: d, dataId: dataId, dekInfo: dek)
                encryptedData = Data(base64Encoded: b64)
            case .file:
                guard let fd = fileData, !fileName.isEmpty else {
                    encryptError = "Choose a file to encrypt."
                    return
                }
                encryptedData = try cryptix.encrypt(
                    file: fd,
                    dataId: dataId,
                    fileName: fileName,
                    fileSize: fd.count,
                    fileType: fileType.isEmpty ? "application/octet-stream" : fileType,
                    dekInfo: dek
                )
            case .rawData:
                break
            }
        } catch { encryptError = error.localizedDescription }
    }

    private func autoFillDecrypt() {
        guard let dek = fetchedDEK else { return }
        if decryptEntries.isEmpty {
            decryptEntries = [NoStoreDecryptEntry()]
        }
        fillDecryptEntry(&decryptEntries[0], dataId: dataId, dek: dek, encrypted: encryptedData)
        decryptError = nil
        decryptResult = nil
    }

    private func runDecrypt() async {
        guard let entry = decryptEntries.first else { return }
        isDecrypting = true
        decryptError = nil
        decryptResult = nil
        defer { isDecrypting = false }
        do {
            let dek = try dekInfoFromFields(
                rawDEKB64: entry.rawDEKB64,
                ivB64: entry.ivB64,
                dekVersion: entry.dekVersion,
                authTagB64: entry.authTagB64,
                encryptedDEKB64: entry.encryptedDEKB64
            )
            let b64 = entry.encryptedBase64.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !b64.isEmpty else {
                decryptError = CryptixFieldError.missing("Encrypted base64").localizedDescription
                return
            }
            let result = try await cryptix.decrypt(encryptedBase64: b64, dekInfo: dek)
            decryptResult = formatDecryptResult(result)
        } catch {
            decryptError = error.localizedDescription
        }
    }
}

// MARK: · Bulk
// createDEKInfoBulk → encryptBulk(items:) → decrypt per item

private struct NoStoreBulkView: View {

    @State private var bulkInput = "ns-bulk-1|Hello item one\nns-bulk-2|Hello item two"

    @State private var callerDEKMap: [String: CryptixDEKInfo] = [:]
    @State private var isCreating   = false
    @State private var createError: String?

    @State private var encItems: [(dataId: String, data: Data)] = []
    @State private var isEncrypting = false
    @State private var encryptError: String?

    @State private var decryptEntries: [NoStoreDecryptEntry] = [NoStoreDecryptEntry()]
    @State private var isDecrypting = false
    @State private var decryptError: String?
    @State private var decryptResults: [TextRow] = []

    private let cryptix = Cryptix.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CryptixDemoLabeledSection(title: "Input", subtitle: "One line per item: dataId|plaintext") {
                CryptixDemoBulkInputField(title: "Bulk Items", text: $bulkInput)
            }

            CryptixDemoStepCard(step: "1", title: "createDEKInfoBulk(dataIds:)") {
                CryptixDemoStageButton(
                    title: "Create DEK Info Bulk",
                    icon: "key.fill",
                    loading: isCreating
                ) { await runCreateDEKsBulk() }
                if let err = createError { CryptixDemoErrorLabel(message: err) }
                if !callerDEKMap.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(callerDEKMap.count) DEK(s) created:")
                            .eogStyle(.text01, .emphasis)
                            .foregroundColor(Color.eogLabelPrimary)
                        ForEach(callerDEKMap.keys.sorted(), id: \.self) { id in
                            if let dek = callerDEKMap[id] {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("dataId: \(id)")
                                        .eogStyle(.text03, .emphasis)
                                        .foregroundColor(Color.permixSuccessText)
                                    CryptixDemoDEKInfoCard(dek: dek)
                                }
                            }
                        }
                    }
                }
            }

            if !callerDEKMap.isEmpty {
                CryptixDemoStepCard(step: "2", title: "encryptBulk(items:)") {
                    CryptixDemoStageButton(
                        title: "Encrypt Bulk",
                        icon: "lock.rectangle.stack",
                        loading: isEncrypting
                    ) { await runEncryptBulk() }
                    if let err = encryptError { CryptixDemoErrorLabel(message: err) }
                    CryptixDemoBulkEncryptedList(
                        items: encItems.map {
                            CryptixDemoBulkEncryptedItem(dataId: $0.dataId, base64: $0.data.base64EncodedString())
                        }
                    )
                }

                if !encItems.isEmpty {
                    CryptixDemoNoStoreDecryptSection(
                        isBulkMode: true,
                        entries: $decryptEntries,
                        isDecrypting: $isDecrypting,
                        decryptError: $decryptError,
                        singleResult: .constant(nil),
                        bulkResults: $decryptResults,
                        onDecrypt: { await runDecryptBulk() },
                        onAutoFill: { autoFillDecryptBulk() },
                        autoFillTitle: "Auto Fill"
                    )
                }
            }
        }
    }

    private func runCreateDEKsBulk() async {
        let ids = Array(Set(parseBulkLines(bulkInput).map(\.dataId)))
        guard !ids.isEmpty else { createError = "Enter at least one dataId|text line."; return }
        isCreating = true
        createError = nil
        callerDEKMap = [:]
        encItems = []
        decryptEntries = [NoStoreDecryptEntry()]
        decryptResults = []
        defer { isCreating = false }
        do { callerDEKMap = try await cryptix.createDEKInfoBulk(dataIds: ids) }
        catch { createError = error.localizedDescription }
    }

    private func runEncryptBulk() async {
        isEncrypting = true
        encryptError = nil
        encItems = []
        decryptResults = []
        defer { isEncrypting = false }
        let pairs = parseBulkLines(bulkInput)
        do {
            let items: [CryptixEncryptBulkItem] = pairs.compactMap { p in
                guard let dek = callerDEKMap[p.dataId] else { return nil }
                return CryptixEncryptBulkItem(
                    dataId: p.dataId,
                    data: Data(p.text.utf8),
                    metadata: nil,
                    dataType: .string,
                    dekInfo: dek
                )
            }
            let results = try cryptix.encryptBulk(items: items)
            encItems = zip(pairs, results).compactMap { p, r in
                guard case .success(let d) = r else { return nil }
                return (p.dataId, d)
            }
        } catch { encryptError = error.localizedDescription }
    }

    private func autoFillDecryptBulk() {
        guard !encItems.isEmpty else {
            decryptError = "Encrypt bulk first, then auto fill decrypt fields."
            return
        }
        decryptEntries = encItems.map { item in
            var entry = NoStoreDecryptEntry()
            if let dek = callerDEKMap[item.dataId] {
                fillDecryptEntry(&entry, dataId: item.dataId, dek: dek, encrypted: item.data)
            } else {
                entry.dataId = item.dataId
                entry.encryptedBase64 = item.data.base64EncodedString()
            }
            return entry
        }
        decryptError = nil
        decryptResults = []
    }

    private func runDecryptBulk() async {
        isDecrypting = true
        decryptError = nil
        decryptResults = []
        defer { isDecrypting = false }

        var rows: [TextRow] = []
        for entry in decryptEntries {
            let label = entry.dataId.trimmingCharacters(in: .whitespaces).isEmpty
                ? "Entry"
                : entry.dataId
            do {
                let dek = try dekInfoFromFields(
                    rawDEKB64: entry.rawDEKB64,
                    ivB64: entry.ivB64,
                    dekVersion: entry.dekVersion,
                    authTagB64: entry.authTagB64,
                    encryptedDEKB64: entry.encryptedDEKB64
                )
                let b64 = entry.encryptedBase64.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !b64.isEmpty else {
                    rows.append(TextRow(key: label, value: "Encrypted base64 is required.", isError: true))
                    continue
                }
                let result = try await cryptix.decrypt(encryptedBase64: b64, dekInfo: dek)
                rows.append(TextRow(key: label, value: formatDecryptResult(result), isError: false))
            } catch {
                rows.append(TextRow(key: label, value: error.localizedDescription, isError: true))
            }
        }
        decryptResults = rows
    }
}
