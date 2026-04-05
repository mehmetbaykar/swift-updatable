import SwiftDiagnostics

enum UpdatableDiagnostic: String, DiagnosticMessage {
  case notAStruct
  case noStoredProperties

  var severity: DiagnosticSeverity {
    switch self {
    case .notAStruct:
      .error
    case .noStoredProperties:
      .warning
    }
  }

  var message: String {
    switch self {
    case .notAStruct:
      "@Updatable can only be applied to structs"
    case .noStoredProperties:
      "@Updatable found no stored properties to generate update methods for"
    }
  }

  var diagnosticID: MessageID {
    MessageID(domain: "UpdatableMacro", id: rawValue)
  }
}
