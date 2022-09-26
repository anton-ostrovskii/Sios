# About

This repository contains some different cool new things I've recently learned about Swift, Cocoa and iOS. Please note that all this information provided "as is" and was initially intended only for my own reference. Please double-check any statements you might see here or in the playgrond.

# General Swift Stuff

- **Swift** is a _compiled_ language.
- There are no _scalars_ in Swift. Everything is an **object**.
- There **4 object types** in Swift: `class`, `struct`, `enum`, `actor` (new in Swift 5.5).
- Starting from Swift 5.5 types `Double` and `CGFloat` are the same thing.

# Functions

## Function which doesn't return anything

This function could be also declared as:
```swift
func nonReturningFunc() -> () { ... } // though `()` is not necessary.
```

## Resolving between 2 functions with the same signature

Let's say we have:
```swift
func ambiguous() -> Int { 5 }
func ambiguous() -> String { "Fildo" }
```
Then we could specify what exactly we'd like to call as:
```swift
print((ambiguous as () -> String)())
```

## Function which changing the input parameter

Functions are not changing its input arguments by default. However, if we want to do it, we could use `inout` keyword like so:
```swift
func removeAllOccurancesOf(_ char: Character, from str: inout String) -> Int {
    var removed = 0
    while let idx = str.firstIndex(of: char) {
        str.remove(at: idx)
        removed += 1
    }
    return removed
}
```
If we're dealing with Objective-C stuff, we could use `UnsafeMutablePointer` which is eventually the same as `inout`:
```swift
func objcRemoveAllOccurances(_ char: Character, from str: UnsafeMutablePointer<String>) -> Int {
    var removed = 0
    while let idx = str.pointee.firstIndex(of: char) {
        str.pointee.remove(at: idx)
        removed += 1
    }
    return removed
}
```
Here `.pointee` is being used to refer to the actual value which `UnsafeMutablePointer` is pointing to.

## Curried Function

Curried function is a function, which returns another function which accepts an incoming argument. Something like:
```swift
/** Curried function */
func createCurriedFunc() -> (String) -> () {
  {
    param in
    print(param)
  }
}
let producedCurriedFunc = createCurriedFunc()
//producedCurriedFunc("fildo")
//createCurriedFunc()("rover")
```

# Closures

## Escaping Closure

This is a closure which captures and preserves its environment over time.

## Capturing anonymous function

```swift
/** Capture Lists */
var capturedVarX = 0
let capturingAnonymousFunc: () -> () = {
  print(capturedVarX)
}
//capturingAnonymousFunc()  // 0
capturedVarX = 1
//capturingAnonymousFunc()  // 1
```

## Non-capturing anonymous function

```swift
var nonCapturedVarX = 0
let nonCapturingAnonymousFunc: () -> () = { [nonCapturedVarX] in
  print(nonCapturedVarX)
}
//nonCapturingAnonymousFunc() // 0
nonCapturedVarX = 1
//nonCapturingAnonymousFunc() // 0
let nonCapturingAnonymousFuncWithAlias: () -> () = { [rover = nonCapturedVarX] in
  print(rover)
}
```

# Properties

## Property wrapper

Sometimes it is very convenient to define some type of a property, hence it could be applied to other properties. For example - a **Clamped Property** which checks and "trims" the input. For example:
```swift
@propertyWrapper struct PWMClamped<T: Comparable> {
  private var val: T
  private let min: T
  private let max: T
  init(wrappedValue:T, min: T, max: T) {
    self.val = wrappedValue
    self.min = min
    self.max = max
  }
  var wrappedValue:T {
    get { val }
    set {
      if newValue < min {
        val = min
      } else if newValue > max {
        val = max
      } else {
        val = newValue
      }
    }
  }
}
```
Now we could define as many custom properties as we want:
```swift
@PWMClamped(wrappedValue: 5, min: 1, max: 7) var pwmc1
@PWMClamped(min: 1, max: 7) var pwmc2 = 5
```

## Difference between `static` property and computed property

_Static property_ could be stored. But _class property_ - only computed. It is possible to override superclass' class property to a static property, but then in cannot store the data and must still be computed.

## Key paths

It is possible to access a property using a keypath:
```swift
/** Key paths */
struct KPPerson {
  let firstName: String
  let lastName: String
}
let kppPath = \KPPerson.firstName
let kppPerson = KPPerson(firstName: "Fox", lastName: "Mulder")
let kppFname = kppPerson[keyPath: kppPath]
let kppPersons = [KPPerson(firstName: "Fox", lastName: "Mulder"), KPPerson(firstName: "Dana", lastName: "Scully")]
let kppFirstNames = kppPersons.map (\.firstName)
let kppFunc: (KPPerson) -> String = \KPPerson.firstName
```

# Variables

## Lazy Initialization

Golden rules of **lazy initialization**:
- All global variables are _lazy_ by default
- All `static` properties are _lazy_ by default
- All instance properties marked with a `lazy` keyword
- Starting with Swift 5.5 even local variables could be _lazy_

## Scientific Notation

This is something which could be used for some variable types like `Double`. For example:
```
3e2 = 300 //3 * 10^2
0x10p2 = 64 // 0x10 - is 16, p2 is 2^2
```

## Clamping initializer

Some types has a clamping initializer which trims incoming values to match property types. For example:
```swift
let x = Int8(180) // x will be equal to 127
```

## How to safely compare 2 Double values

The only safe way is:
```swift
if val1 >= val2.nextDown && val1 <= val2.nextUp
```

# Enums

## General enums info

- **Enums** don't have any stored instance properties.

## Use itself enum type as an associated type

Could be achieved by using a keyword `indirect`:
```swift
enum SimpleEnumWithAssociatedValue {
  // Now we have .allCases enum
  case code(Int)
  case message(String)
  case fatal
  case labeled(string: String, number: Int)
  mutating func setFatal() {  // need to mark as `mutating` since we're changing `self`
    self = .fatal
  }
  indirect case next(Int, SimpleEnumWithAssociatedValue)
}
```

# Classes

## General classes info

- Only _classes_ could be **bridged** from Swift to Objective-C.
- Classes are _reference_ types, they're _mutable_, might have _multiple references_ to the same class object
- Classes supports _inheritance_

## Inheritance

- When using `override` keyword, we could change parameters in function to `optional`, or change them to the base class type. It's OK.
- Function could be marked as `final` to prevent `override`.

## Initializers

### Designated initializer

A designated initializer must be called to create an object. A designated initializer cannot call another `init`.

### Convenience initializer

A facade which must call some designated initializer internally. It cannot set any constant properties in the class.

### Inheritance and `init`

1. If subclass doesn't have any initializers - it inherits all initializers from its superclass.
2. You can add convenience initializers into a subclass, but they must call some designated initializer from a superclass using `self.`.
3. If subclass defining its own designated initializer, then no any initializer from superclass are being inherited. This designated initializer must call another designated initializer from the superclass using `super.`.
4. You can override a convenience initializer in a subclass without using a keyword `override`.
5. It is possible to override a designated initializer from a superclass using a keyword `override`.
6. If a subclass overrides **all** designated initializers from a superclass, then a subclass inherits all convenient initializers from a superclass.

### Required initializer

A keyword `required` means that if subclass adds some designated initializer, then it must override all `required` initializers from a superclass. In this case there is no need to use a keyword `override`, but it is required to use a keyword `required`.

### Deinit

`deinit` could be used only in classes. First - the current `deinit` is being called. Then - a `deinit` from its superclass and so on. Property observers are not being called from `deinit`.

### Difference between `static` method and `class` method

The difference is - `class` method could be overriden. A `static` method - cannot.

# Types

## General information about types

1. `type(of: ...)` is being used on an object to learn its type.
2. `Self` is the type of the current object (taking a polymorphism into a consideration).
3. `.Type` to get a type as a data type (input parameter).
4. `.self` - get a metatype to pass it later where `Type` is expected.

## Umbrella types

1. `Any` - maps to `id` in Objective-C. Can be anything at all, even a function.
2. `AnyObject` the exact `id` from Objective-C. Cannot be a struct or an enum. You can send messages to this object. If you send a message which it doesn't support - that's OK, and will be treated as an optional call. Better not to use it since it is dynamic and slow.
3. `AnyClass` - similar to a class from Objective-C. Similar to `AnyObject`.

# Protocols

## Mutating keyword

Protocol must have a word `mutating` in functions which are chaging the data of implementer. And the actual implementations might omit the use of `mutating` keyword.

## Class Protocol

Means that only certain classes might implement it. For example:
```swift
protocol ViewComposable: UIView { ... }
// or
protocol ViewComposable where Self: UIView { ... }
```

If we just need to specify that **only classes could implement a protocol** (and no structs), then we could use this:
```swift
protocol ViewComposable: AnyObject { ... }
```

Class-constraint on protocols allows to use it as a weak reference. For example:
```swift
class MyClass {
  weak var delegate: ViewComposable? // it has to be a class protocol
}
```

## Optional members in a protocol

Could be used if protocol marked with `@objc` attribute.

# Optimizations

1. It is important to use `final` keyword and mark methods/properties with `private`. Since polymorphism is slow and requires a dynamic dispatch. That's why it is important to use these keywords. And if possible - use `struct` instead which doesn't need a dynamic dispatch.
2. It is important to use `AnyObject` in only class-designated protocols since it brings in more optimizations.
3. `AnyObject` is too slow and dynamic. Better don't use it.
