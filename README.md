# swift-updatable

A Swift macro that generates immutable update methods for struct properties. Instead of manually copying structs with one field changed, `@Updatable` generates a `updatePropertyName(_:)` method for each stored property that returns a new instance with that single value replaced.

## Installation

Add `swift-updatable` to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/mehmetbaykar/swift-updatable.git", from: "1.0.0")
]
```

Then add `"Updatable"` to your target's dependencies:

```swift
.target(
  name: "MyApp",
  dependencies: ["Updatable"]
)
```

## Usage

Annotate any struct with `@Updatable`:

```swift
import Updatable

@Updatable
struct Point {
  let x: Int
  let y: Int
}

let origin = Point(x: 0, y: 0)
let moved = origin.updateX(10) // Point(x: 10, y: 0)
```

Each generated method takes the new value and returns a fresh instance with all other properties preserved.

<details>
<summary>See generated code</summary>

```swift
struct Point {
  let x: Int
  let y: Int

  func updateX(_ x: Int) -> Point {
    Point(x: x, y: self.y)
  }

  func updateY(_ y: Int) -> Point {
    Point(x: self.x, y: y)
  }
}
```

</details>

### Chaining updates

Since each method returns a new instance, you can chain calls:

```swift
let result = origin
  .updateX(5)
  .updateY(10)
// Point(x: 5, y: 10)
```

### Access control

The generated methods match the struct's access level:

```swift
@Updatable
public struct Coordinate {
  public let latitude: Double
  public let longitude: Double
}
// Generates: public func updateLatitude(...) -> Coordinate
```

### Excluding properties with `@UpdatableIgnored`

Use `@UpdatableIgnored` to prevent generating an update method for a specific property. The property's value is still preserved via `self` in all other update methods:

```swift
@Updatable
struct Document {
  let title: String
  @UpdatableIgnored
  let createdAt: Date
}

let doc = Document(title: "Draft", createdAt: .now)
let renamed = doc.updateTitle("Final") // createdAt is preserved
// No updateCreatedAt method is generated
```

<details>
<summary>See generated code</summary>

```swift
struct Document {
  let title: String
  let createdAt: Date

  func updateTitle(_ title: String) -> Document {
    Document(title: title, createdAt: self.createdAt)
  }
}
```

</details>

## What gets skipped

The macro only generates update methods for **stored instance properties**. The following are automatically excluded:

| Property kind | Example | Reason |
|---|---|---|
| Static / class properties | `static let shared = ...` | Not part of instance state |
| Computed properties | `var fullName: String { ... }` | No backing storage |
| Property wrappers | `@Published var query: String` | Wrappers synthesize backing storage that changes the memberwise init signature |

## Known limitations

**Relies on the Swift memberwise initializer.** The generated methods call the struct's memberwise init with all stored properties (excluding wrapped ones) in declaration order. If you define a custom `init` that changes the parameter names, order, or labels, the generated code will not compile. To work around this, ensure your struct either:

- Uses the default memberwise initializer (no custom `init`), or
- Provides a custom `init` whose parameters match the stored property names and order exactly.

**Property wrappers are fully excluded from init calls.** Since property wrappers change the memberwise init signature (the backing `_property` storage replaces the original parameter), wrapped properties are not passed through in the generated initializer.

## Diagnostics

The macro provides helpful diagnostics:

- **Error**: `@Updatable can only be applied to structs` — applying it to a class, enum, or other type.
- **Warning**: `@Updatable found no stored properties to generate update methods for` — the struct has no eligible properties (empty, all static, all wrapped, or all ignored).

## License

MIT License. See [LICENSE](LICENSE) for details.
