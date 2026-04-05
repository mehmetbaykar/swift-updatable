import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct UpdatableMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard let structDecl = declaration.as(StructDeclSyntax.self) else {
      context.diagnose(
        Diagnostic(
          node: node,
          message: UpdatableDiagnostic.notAStruct
        )
      )
      return []
    }

    let structName = structDecl.name.trimmed.text
    let accessModifier = structDecl.modifiers.accessModifier

    // All stored properties that participate in the memberwise init (excludes wrappers)
    let initProperties = structDecl.memberBlock.members
      .compactMap { $0.decl.as(VariableDeclSyntax.self) }
      .filter { $0.isStoredInstanceProperty }
      .filter { !$0.hasPropertyWrapper }

    // Only non-ignored properties get update methods
    let updatableProperties =
      initProperties
      .filter { !$0.hasAttribute("UpdatableIgnored") }

    if updatableProperties.isEmpty {
      context.diagnose(
        Diagnostic(
          node: node,
          message: UpdatableDiagnostic.noStoredProperties
        )
      )
      return []
    }

    var methods: [DeclSyntax] = []

    for property in updatableProperties {
      guard
        let binding = property.bindings.first,
        let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
        let typeAnnotation = binding.typeAnnotation
      else {
        continue
      }

      let propertyName = pattern.identifier.trimmed.text
      let propertyType = typeAnnotation.type.trimmed

      let methodName = "update\(propertyName.uppercasedFirst)"

      let initArgs = initProperties.map { prop -> String in
        guard
          let b = prop.bindings.first,
          let p = b.pattern.as(IdentifierPatternSyntax.self)
        else {
          return ""
        }
        let name = p.identifier.trimmed.text
        if name == propertyName {
          return "    \(name): \(name)"
        } else {
          return "    \(name): self.\(name)"
        }
      }
      .joined(separator: ",\n")

      let accessPrefix = accessModifier.map { "\($0) " } ?? ""

      let method: DeclSyntax = """
        \(raw: accessPrefix)func \(raw: methodName)(
          _ \(raw: propertyName): \(raw: propertyType)
        ) -> \(raw: structName) {
          \(raw: structName)(
        \(raw: initArgs)
          )
        }
        """

      methods.append(method)
    }

    return methods
  }
}

public struct UpdatableIgnoredMacro: PeerMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    []
  }
}

@main
struct UpdatablePlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    UpdatableMacro.self,
    UpdatableIgnoredMacro.self,
  ]
}
