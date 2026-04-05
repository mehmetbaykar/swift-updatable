import MacroTesting
import Testing

@testable import UpdatableMacro

@Suite
struct UpdatableMacroTests {

  // MARK: - Basic Expansion

  @Test
  func twoStoredProperties() {
    assertMacro(["Updatable": UpdatableMacro.self, "UpdatableIgnored": UpdatableIgnoredMacro.self])
    {
      """
      @Updatable
      struct Point {
        let x: Int
        let y: Int
      }
      """
    } expansion: {
      """
      struct Point {
        let x: Int
        let y: Int

        func updateX(
          _ x: Int
        ) -> Point {
          Point(
            x: x,
            y: self.y
          )
        }

        func updateY(
          _ y: Int
        ) -> Point {
          Point(
            x: self.x,
            y: y
          )
        }
      }
      """
    }
  }

  @Test
  func singleProperty() {
    assertMacro(["Updatable": UpdatableMacro.self, "UpdatableIgnored": UpdatableIgnoredMacro.self])
    {
      """
      @Updatable
      struct Wrapper {
        let value: String
      }
      """
    } expansion: {
      """
      struct Wrapper {
        let value: String

        func updateValue(
          _ value: String
        ) -> Wrapper {
          Wrapper(
            value: value
          )
        }
      }
      """
    }
  }

  @Test
  func optionalArrayAndScalarTypes() {
    assertMacro(["Updatable": UpdatableMacro.self, "UpdatableIgnored": UpdatableIgnoredMacro.self])
    {
      """
      @Updatable
      struct Record {
        let label: String?
        let tags: [String]
        let count: Int
      }
      """
    } expansion: {
      """
      struct Record {
        let label: String?
        let tags: [String]
        let count: Int

        func updateLabel(
          _ label: String?
        ) -> Record {
          Record(
            label: label,
            tags: self.tags,
            count: self.count
          )
        }

        func updateTags(
          _ tags: [String]
        ) -> Record {
          Record(
            label: self.label,
            tags: tags,
            count: self.count
          )
        }

        func updateCount(
          _ count: Int
        ) -> Record {
          Record(
            label: self.label,
            tags: self.tags,
            count: count
          )
        }
      }
      """
    }
  }

  @Test
  func mixedVarAndLet() {
    assertMacro(["Updatable": UpdatableMacro.self, "UpdatableIgnored": UpdatableIgnoredMacro.self])
    {
      """
      @Updatable
      struct Settings {
        let id: String
        var isEnabled: Bool
      }
      """
    } expansion: {
      """
      struct Settings {
        let id: String
        var isEnabled: Bool

        func updateId(
          _ id: String
        ) -> Settings {
          Settings(
            id: id,
            isEnabled: self.isEnabled
          )
        }

        func updateIsEnabled(
          _ isEnabled: Bool
        ) -> Settings {
          Settings(
            id: self.id,
            isEnabled: isEnabled
          )
        }
      }
      """
    }
  }

  // MARK: - Access Control

  @Test
  func publicAccessModifier() {
    assertMacro(["Updatable": UpdatableMacro.self, "UpdatableIgnored": UpdatableIgnoredMacro.self])
    {
      """
      @Updatable
      public struct Coordinate {
        public let latitude: Double
        public let longitude: Double
      }
      """
    } expansion: {
      """
      public struct Coordinate {
        public let latitude: Double
        public let longitude: Double

        public func updateLatitude(
          _ latitude: Double
        ) -> Coordinate {
          Coordinate(
            latitude: latitude,
            longitude: self.longitude
          )
        }

        public func updateLongitude(
          _ longitude: Double
        ) -> Coordinate {
          Coordinate(
            latitude: self.latitude,
            longitude: longitude
          )
        }
      }
      """
    }
  }

  @Test
  func packageAccessModifier() {
    assertMacro(["Updatable": UpdatableMacro.self, "UpdatableIgnored": UpdatableIgnoredMacro.self])
    {
      """
      @Updatable
      package struct Threshold {
        package let min: Int
        package let max: Int
      }
      """
    } expansion: {
      """
      package struct Threshold {
        package let min: Int
        package let max: Int

        package func updateMin(
          _ min: Int
        ) -> Threshold {
          Threshold(
            min: min,
            max: self.max
          )
        }

        package func updateMax(
          _ max: Int
        ) -> Threshold {
          Threshold(
            min: self.min,
            max: max
          )
        }
      }
      """
    }
  }

  // MARK: - @UpdatableIgnored

  @Test
  func ignoredPropertyPassedThroughInInit() {
    assertMacro(["Updatable": UpdatableMacro.self, "UpdatableIgnored": UpdatableIgnoredMacro.self])
    {
      """
      @Updatable
      struct Document {
        let title: String
        @UpdatableIgnored
        let createdAt: Date
      }
      """
    } expansion: {
      """
      struct Document {
        let title: String
        let createdAt: Date

        func updateTitle(
          _ title: String
        ) -> Document {
          Document(
            title: title,
            createdAt: self.createdAt
          )
        }
      }
      """
    }
  }

  @Test
  func multipleIgnoredProperties() {
    assertMacro(["Updatable": UpdatableMacro.self, "UpdatableIgnored": UpdatableIgnoredMacro.self])
    {
      """
      @Updatable
      struct Entry {
        let content: String
        @UpdatableIgnored
        let id: UUID
        @UpdatableIgnored
        let timestamp: Double
      }
      """
    } expansion: {
      """
      struct Entry {
        let content: String
        let id: UUID
        let timestamp: Double

        func updateContent(
          _ content: String
        ) -> Entry {
          Entry(
            content: content,
            id: self.id,
            timestamp: self.timestamp
          )
        }
      }
      """
    }
  }

  @Test
  func allPropertiesIgnoredEmitsWarning() {
    assertMacro(["Updatable": UpdatableMacro.self, "UpdatableIgnored": UpdatableIgnoredMacro.self])
    {
      """
      @Updatable
      struct Token {
        @UpdatableIgnored
        let value: String
      }
      """
    } diagnostics: {
      """
      @Updatable
      ┬─────────
      ╰─ ⚠️ @Updatable found no stored properties to generate update methods for
      struct Token {
        @UpdatableIgnored
        let value: String
      }
      """
    } expansion: {
      """
      struct Token {
        let value: String
      }
      """
    }
  }

  // MARK: - Skipped Properties

  @Test
  func propertyWrappersSkipped() {
    assertMacro(["Updatable": UpdatableMacro.self, "UpdatableIgnored": UpdatableIgnoredMacro.self])
    {
      """
      @Updatable
      struct FormState {
        let title: String
        @Published var query: String
      }
      """
    } expansion: {
      """
      struct FormState {
        let title: String
        @Published var query: String

        func updateTitle(
          _ title: String
        ) -> FormState {
          FormState(
            title: title
          )
        }
      }
      """
    }
  }

  @Test
  func staticPropertiesSkipped() {
    assertMacro(["Updatable": UpdatableMacro.self, "UpdatableIgnored": UpdatableIgnoredMacro.self])
    {
      """
      @Updatable
      struct Config {
        let value: Int
        static let defaultValue: Int = 0
      }
      """
    } expansion: {
      """
      struct Config {
        let value: Int
        static let defaultValue: Int = 0

        func updateValue(
          _ value: Int
        ) -> Config {
          Config(
            value: value
          )
        }
      }
      """
    }
  }

  @Test
  func computedPropertiesSkipped() {
    assertMacro(["Updatable": UpdatableMacro.self, "UpdatableIgnored": UpdatableIgnoredMacro.self])
    {
      """
      @Updatable
      struct Temperature {
        let celsius: Double
        var fahrenheit: Double { celsius * 9 / 5 + 32 }
      }
      """
    } expansion: {
      """
      struct Temperature {
        let celsius: Double
        var fahrenheit: Double { celsius * 9 / 5 + 32 }

        func updateCelsius(
          _ celsius: Double
        ) -> Temperature {
          Temperature(
            celsius: celsius
          )
        }
      }
      """
    }
  }

  // MARK: - Diagnostics

  @Test
  func errorOnClass() {
    assertMacro(["Updatable": UpdatableMacro.self, "UpdatableIgnored": UpdatableIgnoredMacro.self])
    {
      """
      @Updatable
      class Node {
        var value: Int = 0
      }
      """
    } diagnostics: {
      """
      @Updatable
      ┬─────────
      ╰─ 🛑 @Updatable can only be applied to structs
      class Node {
        var value: Int = 0
      }
      """
    }
  }

  @Test
  func errorOnEnum() {
    assertMacro(["Updatable": UpdatableMacro.self, "UpdatableIgnored": UpdatableIgnoredMacro.self])
    {
      """
      @Updatable
      enum Direction {
        case north, south
      }
      """
    } diagnostics: {
      """
      @Updatable
      ┬─────────
      ╰─ 🛑 @Updatable can only be applied to structs
      enum Direction {
        case north, south
      }
      """
    }
  }

  @Test
  func warningOnEmptyStruct() {
    assertMacro(["Updatable": UpdatableMacro.self, "UpdatableIgnored": UpdatableIgnoredMacro.self])
    {
      """
      @Updatable
      struct Empty {}
      """
    } diagnostics: {
      """
      @Updatable
      ┬─────────
      ╰─ ⚠️ @Updatable found no stored properties to generate update methods for
      struct Empty {}
      """
    } expansion: {
      """
      struct Empty {}
      """
    }
  }

  @Test
  func warningWhenOnlyStaticProperties() {
    assertMacro(["Updatable": UpdatableMacro.self, "UpdatableIgnored": UpdatableIgnoredMacro.self])
    {
      """
      @Updatable
      struct Constants {
        static let pi: Double = 3.14
        static let e: Double = 2.72
      }
      """
    } diagnostics: {
      """
      @Updatable
      ┬─────────
      ╰─ ⚠️ @Updatable found no stored properties to generate update methods for
      struct Constants {
        static let pi: Double = 3.14
        static let e: Double = 2.72
      }
      """
    } expansion: {
      """
      struct Constants {
        static let pi: Double = 3.14
        static let e: Double = 2.72
      }
      """
    }
  }

  // MARK: - Complex Types

  @Test
  func dictionaryAndClosureTypes() {
    assertMacro(["Updatable": UpdatableMacro.self, "UpdatableIgnored": UpdatableIgnoredMacro.self])
    {
      """
      @Updatable
      struct Route {
        let metadata: [String: Any]
        let handler: (Int) -> Void
      }
      """
    } expansion: {
      """
      struct Route {
        let metadata: [String: Any]
        let handler: (Int) -> Void

        func updateMetadata(
          _ metadata: [String: Any]
        ) -> Route {
          Route(
            metadata: metadata,
            handler: self.handler
          )
        }

        func updateHandler(
          _ handler: (Int) -> Void
        ) -> Route {
          Route(
            metadata: self.metadata,
            handler: handler
          )
        }
      }
      """
    }
  }

  @Test
  func tupleType() {
    assertMacro(["Updatable": UpdatableMacro.self, "UpdatableIgnored": UpdatableIgnoredMacro.self])
    {
      """
      @Updatable
      struct Pair {
        let origin: (Double, Double)
        let label: String
      }
      """
    } expansion: {
      """
      struct Pair {
        let origin: (Double, Double)
        let label: String

        func updateOrigin(
          _ origin: (Double, Double)
        ) -> Pair {
          Pair(
            origin: origin,
            label: self.label
          )
        }

        func updateLabel(
          _ label: String
        ) -> Pair {
          Pair(
            origin: self.origin,
            label: label
          )
        }
      }
      """
    }
  }
}
