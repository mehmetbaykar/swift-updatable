import SwiftSyntax

extension VariableDeclSyntax {
  var isStoredInstanceProperty: Bool {
    guard !modifiers.contains(where: { $0.name.text == "static" || $0.name.text == "class" }) else {
      return false
    }

    guard let binding = bindings.first else {
      return false
    }

    if binding.accessorBlock != nil {
      return false
    }

    return binding.typeAnnotation != nil
  }

  var hasPropertyWrapper: Bool {
    attributes.contains { attribute in
      guard case .attribute(let attr) = attribute else {
        return false
      }
      let name = attr.attributeName.trimmedDescription
      return name != "UpdatableIgnored"
        && name.first?.isUppercase == true
    }
  }

  func hasAttribute(_ name: String) -> Bool {
    attributes.contains { attribute in
      guard case .attribute(let attr) = attribute else {
        return false
      }
      return attr.attributeName.trimmedDescription == name
    }
  }
}

extension DeclModifierListSyntax {
  var accessModifier: String? {
    let access = ["public", "package", "internal", "fileprivate", "private", "open"]
    for modifier in self {
      let name = modifier.name.text
      if access.contains(name) {
        return name
      }
    }
    return nil
  }
}

extension String {
  var uppercasedFirst: String {
    guard let first = first else { return self }
    return first.uppercased() + dropFirst()
  }
}
