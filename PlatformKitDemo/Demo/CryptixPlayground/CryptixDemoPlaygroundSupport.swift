//
//  CryptixDemoPlaygroundSupport.swift
//  PlatformKitDemo
//
//  Shared models and logic helpers for CryptixKit demos.
//  UI lives in CryptixDemoPlaygroundComponents.swift.
//

import Foundation
import CryptixKit

// MARK: - Shared enums / models

enum PlayDataType: String, CaseIterable {
    case string  = "String"
    case dict    = "JSON Object"
    case file    = "File"
    case rawData = "Raw Data"

    static let noStoreEncryptCases: [PlayDataType] = [.string, .dict, .file]

    var iconName: String {
        switch self {
        case .string:  return "textformat"
        case .dict:    return "curlybraces"
        case .file:    return "doc.fill"
        case .rawData: return "0101.square"
        }
    }

    var subtitle: String? {
        switch self {
        case .string:  return "Plain UTF-8 string payload"
        case .dict:    return "JSON object dictionary"
        case .file:    return "Binary file upload"
        case .rawData: return "Raw Data bytes"
        }
    }

    var cryptixDataType: CryptixDataType {
        switch self {
        case .string, .rawData: return .string
        case .dict:             return .object
        case .file:             return .file
        }
    }
}

struct TextRow: Identifiable {
    let id   = UUID()
    let key: String
    let value: String
    let isError: Bool
} 

// ─────────────────────────────────────────────────────────
// MARK: - Shared logic helpers
// ─────────────────────────────────────────────────────────

func dekInfoFromFields(
    rawDEKB64: String,
    ivB64: String,
    dekVersion: String = "",
    authTagB64: String = "",
    encryptedDEKB64: String = ""
) throws -> CryptixDEKInfo {
    let raw = rawDEKB64.trimmingCharacters(in: .whitespacesAndNewlines)
    let iv = ivB64.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let rawDEK = Data(base64Encoded: raw) else {
        throw CryptixFieldError.invalidBase64("rawDEK")
    }
    guard let ivData = Data(base64Encoded: iv) else {
        throw CryptixFieldError.invalidBase64("IV")
    }
    let authTag = authTagB64.trimmingCharacters(in: .whitespacesAndNewlines)
    let encDEK = encryptedDEKB64.trimmingCharacters(in: .whitespacesAndNewlines)
    let version = dekVersion.trimmingCharacters(in: .whitespacesAndNewlines)
    return CryptixDEKInfo(
        rawDEK: rawDEK,
        iv: ivData,
        authTag: authTag.isEmpty ? nil : Data(base64Encoded: authTag),
        dekVersion: version.isEmpty ? nil : version,
        encryptedDEK: encDEK.isEmpty ? nil : Data(base64Encoded: encDEK)
    )
}

enum CryptixFieldError: LocalizedError {
    case invalidBase64(String)
    case missing(String)

    var errorDescription: String? {
        switch self {
        case .invalidBase64(let field): return "Invalid base64 for \(field)."
        case .missing(let field): return "\(field) is required."
        }
    }
}

func formatDecryptResult(_ r: CryptixDecryptResult) -> String {
    if let s = try? r.asString() { return s }
    if let d = try? r.asDictionary(),
       let data = try? JSONSerialization.data(withJSONObject: d, options: .prettyPrinted),
       let s = String(data: data, encoding: .utf8) { return s }
    return "\(r.data.count) bytes (binary)"
}

struct NoStoreDecryptEntry: Identifiable {
    let id = UUID()
    var dataId = ""
    var encryptedBase64 = ""
    var rawDEKB64 = ""
    var ivB64 = ""
    var dekVersion = ""
    var authTagB64 = ""
    var encryptedDEKB64 = ""
}

/// Decrypt-with-store inputs — server retrieves DEK via dataId; no local DEK fields.
struct WithStoreDecryptEntry: Identifiable {
    let id = UUID()
    var dataId = ""
    var encryptedBase64 = ""
    var permixTemplate = ""
}

func fillWithStoreDecryptEntry(
    _ entry: inout WithStoreDecryptEntry,
    dataId: String,
    permixTemplate: String,
    encrypted: Data?
) {
    entry.dataId = dataId
    entry.permixTemplate = permixTemplate
    if let encrypted {
        entry.encryptedBase64 = encrypted.base64EncodedString()
    }
}

func fillDecryptEntry(
    _ entry: inout NoStoreDecryptEntry,
    dataId: String = "",
    dek: CryptixDEKInfo,
    encrypted: Data?
) {
    entry.dataId = dataId
    entry.rawDEKB64 = dek.rawDEK.base64EncodedString()
    entry.ivB64 = dek.iv.base64EncodedString()
    entry.dekVersion = dek.dekVersion ?? ""
    entry.authTagB64 = dek.authTag?.base64EncodedString() ?? ""
    entry.encryptedDEKB64 = dek.encryptedDEK?.base64EncodedString() ?? ""
    if let encrypted {
        entry.encryptedBase64 = encrypted.base64EncodedString()
    }
}

func parseBulkLines(_ text: String) -> [(dataId: String, text: String)] {
    text.split(separator: "\n").compactMap { line in
        let s = line.trimmingCharacters(in: .whitespaces)
        guard let idx = s.firstIndex(of: "|") else { return nil }
        let id = String(s[..<idx]).trimmingCharacters(in: .whitespaces)
        let tx = String(s[s.index(after: idx)...]).trimmingCharacters(in: .whitespaces)
        return id.isEmpty ? nil : (id, tx)
    }
}

// ─────────────────────────────────────────────────────────
// MARK: - Extensions
// ─────────────────────────────────────────────────────────

extension String {
    func asJSONObject() -> [String: Any]? {
        guard let d = data(using: .utf8),
              let o = try? JSONSerialization.jsonObject(with: d) as? [String: Any] else { return nil }
        return o
    }
    var splitLines: [String] {
        split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
