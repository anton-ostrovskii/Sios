# About

This repository contains some different cool new things I've recently learned about Swift, Cocoa and iOS. Please note that all this information provided "as is" and was initially intended only for my own reference. Please double-check any statements you might see here or in the playgrond.

# General Swift Stuff

- **Swift** is a _compiled_ language.
- There are no _scalars_ in Swift. Everything is an **object**.
- There **4 object types** in Swift: `class`, `struct`, `enum`, `actor` (new in Swift 5.5).
- Starting from Swift 5.5 types `Double` and `CGFloat` are the same thing.
- `defer` statements are being executed in a reverse order as they were registered.
- `assert` and `assertFailure` are crashing in Debug configuration but do nothing in production code.
- `precondition`, `preconditionFailure` and `fatalError` are always crashing the app irrespective of a configuration.

# Access Mofidiers

## Types of access modifiers

- `internal` - a default one, accessible within its module
- `fileprivate` - everything is accessible within its file
- `private` - accessible only within the object
- `public` - everything is accessible to other modules as well. But cannot be inherited from the outside
- `open` - everything is accessible and inheritable everywhere

## Access modifiers rules

1. A subclass cannot see parent's `private` objects.
2. An analogue of `protected` access modifier is to declare subclasses in the same file and use `fileprivate`.
3. An **extension** can see `private` objects as long as its declared in the same file.

## Structs and an implicit initializer

If struct has only an implicit (default) initializer and marked as `public`, then it won't be accessible to an _external module_.

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

## Projected values

Property wrappers could have so called _projected values_. For example:
```swift
/** Property wrapper and projected value */
@propertyWrapper struct PWReversing {
  let orig: String
  let reversed: String
  var wrappedValue: String { orig }
  var projectedValue: String { reversed }
  init(wrappedValue: String){
    self.orig = wrappedValue
    self.reversed = String(wrappedValue.reversed())
  }
  init(projectedValue: String) {
    self.reversed = projectedValue
    self.orig = String(projectedValue.reversed())
  }
}
struct PWTest {
  func check(@PWReversing str: String) {
  }
  
  func test() {
    check(str: "Hello")
    check($str: "olleH")
  }
}
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

## Comparable and Enums

`enum` without a `RawValue` could automatically implement a `Comparable`. If it has associated values in its cases - then these should be also `Comparable`.

# Dynamic

This a dangerous and slow way to dynamically work with objects

## @dynamicMemberLookup

Adds a _subscript_ which allows dynamically access members. It is possible to re-route messages from object to its property using a `@dynamicMemberLookup`.

## @dynamiCallable

Allows to dynamically access functions on some object.

## Example of using dynamic members and dynamic members lookup

```swift
/** Dynamic Membership - dangerous way */
@dynamicMemberLookup
@dynamicCallable
class DMFlock {
  private var d = [String: String]()
  subscript(dynamicMember s: String) -> String? {
    get { d[s] }
    set { d[s] = newValue }
  }
  func dynamicallyCall(withKeywordArguments kvs:KeyValuePairs<String, String>) {
    if kvs.count == 1 {
      if let (key, val) = kvs.first {
        if key == "remove" {
          d[val] = nil
        }
      }
    }
  }
}
let dmFlock = DMFlock()
dmFlock.dog = "bark"
dmFlock.cat = "meow"
dmFlock(remove: "dog")

/** Dynamic Membership - safer way with a key path */
@dynamicMemberLookup
struct DMSFlock {
  let dog: HashableDog
  subscript(dynamicMember s: KeyPath<HashableDog, String>) -> String {
    dog[keyPath: s]
  }
}
let dmsFlock = DMSFlock(dog: HashableDog(name: "Rover", license: 1, color: .blue))
_ = dmsFlock.name   // Forward messages from "DMSFlock" to "Dog"
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

## Array

This instruction creates 100 references to the same object:
```swift
let dogs = Array(repeating: Dog(), count: 100)
```
But this instruction creates 100 different objects:
```swift
let dogs = (0..<100).map { _ in Dog() }
```

Array is a **value type** like a `struct`.

### ArraySlice

`ArraySlice` is being indexed like an original array (and **not** just from `0`). It's better to use a `startIndex` instead.

## Result builder

`@resultBuilder` is being used as a template for functions, consists of its results. Being used heavilt in SwiftUI.
```swift
@resultBuilder
struct SimpleStringBuilder {
  static func buildArray(_ components: [String]) -> String {
    components.joined(separator: " ")
  }
  static func buildBlock(_ components: String...) -> String {
    components.joined(separator: " ")
  }
}
@SimpleStringBuilder func rbCountdown() -> String {
  for i in stride(from: 10, to: 0, by: -1) {
    "\(i)"
  }
  "Lift Off!"
}
//print(rbCountdown())
```

# Loops

## Only special types of objects iterated in `for` loop

```swift
for case let b as UIButton in self.subviews { ... }
```

## Iterate an async sequence

`for await` could be used to iterate through an async sequence. The loop is waiting for the next element to be awailable.

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

## Equatable and Hashable auto synthesis

`Equatable` protocol might be synthesized automatically if:
1. It is a `struct` or `enum`
2. `Equatable` conformance declared **not** in an _extension_
3. We didn't redefine `==` operator
4. All struct's properties (or enum's associated types) are also `Equatable`

## Some

`some` is a keyword which is being used to define some object which implements some `protocol`. The difference from just declare something as a `protocol type` is - compiler will resolve it automatically. And also it can be used with generic protocols.

# Actors

`actor` is an object type. It helps to "isolate" some code for a safe multi-threading programming. access to `actor` is always synchronous.

`MainActor.run { ... }` is the way to run someting asynchronously on a main thread.

# Operators overloading

Samples of overloading an operator.
```swift
/** Operators Overload */
struct OOVial {
  var healthPoints: Int
  static func +(lhs: OOVial, rhs: OOVial) -> OOVial {
    OOVial(healthPoints: lhs.healthPoints + rhs.healthPoints)
  }
  static func +=(lhs: inout OOVial, rhs: OOVial) {
    lhs.healthPoints += rhs.healthPoints
  }
}
let ooVial1 = OOVial(healthPoints: 500)
let ooVial2 = OOVial(healthPoints: 1300)
let ooVial3 = ooVial1 + ooVial2

/** Declaring a new operator */
infix operator ^^
extension Int {
  static func ^^(lhs: Int, rhs: Int) -> Int {
    var result = 1
    for _ in 0..<rhs {
      result *= lhs
    }
    return result
  }
}
//print(2^^3) <- 8

/** Declare a reverse range custom operator */
infix operator >>> : RangeFormationPrecedence
func >>><Bound>(maximum: Bound, minimum: Bound) -> ReversedCollection<Range<Bound>> where Bound: Strideable {
  (minimum..<maximum).reversed()
}
```

# Memory Management

## unowned

`unowned` is being used when one object cannot exist without another one. Benefits: we can use `let` and don't use an optional type. Cons: there is a chance to crash an app if the object will be destroyed.

## Retain cycles in functions

Only **stored anonymous functions** could cause a retain cycle. There is no need to use `[weak self]` everywhere like in `UIView.animate {...}`.

## autoreleasepool

`autoreleasepool { ... }` could be used when there are many temporarily local veriables are being created behind the scenes and we need to "drain" the memory not to pile it up. For example:
```swift
func arpTest() {
    let path = Bundle.main.path(forResource: "BigImage", ofType: "png")!
    for j in 0..<50 {
        autoreleasepool {
            for i in 0..<100 {
                let im = UIImage(contentsOfFile: path)
            }
        }
    }
}
```

## Between Swift and Objective-C memory management

- `weak` - not retaining a reference count for an object. The object can become `nil`
- `unowned` - not doing anything with ARC. Dangeroud to use and should be used only if you're 100% confident that object will exist
- `assign` from Objective-C is being transformed to `unowned(unsafe)` in Swift
- `strong`, `retain` - these are default in Objective-C. Assigning and retaining the counter
- `copy` - same as above, but assigns a copy (the relevant type should implement `@NSCopying` (if in Swift)

# Structured Concurency

Structured concurency - is a new way of multi-threading programming which was added in Swift 5.5. Mostly consists of `async` and `await`.
`await` is not blocking a current thread. It can be called even on a main thread.
To call an async function, we need to use a `Task`:
```swift
func scSimpleDownload(from url: URL) async throws -> Data {
  let urlRequest = URLRequest(url: url)
  let result = try await URLSession.shared.data(for: urlRequest)
  return result.0 // data
}
struct SCTestTask {
  func testTask() {
    Task {
      do {
        let url = URL(string: "www.google.com")!
        let data = try await scSimpleDownload(from: url)
        print(data.count)
      } catch {
        print("Error")
      }
    }
  }
}
```

There is also a "detached task" which is being launched in a separete thread separately from the surrounding context. Usage: `Task.detached { ... }`.

`withUnsafeContinuation` is being used to call an old-fashioned async method from new structured concurency methods:
```swift
func ofDownloaderOld(from url: URL, completion: @escaping (Result<Data, Error>) -> ()) {
    URLSession.shared.dataTask(with: url) { data, _, error in
        if let data = data {
            completion(.success(data))
        }
        completion(.failure(error!))
    }
}
func scDownloaderNew(from url: URL) async -> Result<Data, Error> {
    await withUnsafeContinuation({ continuation in
        ofDownloaderOld(from: url) { result in
            continuation.resume(returning: result)
        }
    })
}
```
There is also a "checked continuation" which will crash an app if something will go wrong (for example, we called `resume` more than once).

`async let` lets launch a subtask asynchronously and won't wait for a result. Actual waiting as well as an exception will take it's place on a first accessing the variable.

`awaitTaskGroup` and `for try await` could be used for random number of parralel tasks.

# Combine

## Combine Subjects

Combine was introduced in iOS13 and Swift 5.1. There are 2 types of subjects in Combine:
1. `PassthroughSubject` - creates a value and sends it in `send`
2. `CurrentValueSubject` - has some initial value which is being transferred to all new subscribers

## Combine keywords

1. `sink` - call on a subscriber when a new value arrives.
2. `assign` - accepts a Swift keypath and a value. Then assigns a value by this keypath.

## Foundation / Cocoa types supporting Combine from the box

1. NotificationCenter
2. KVO compliant properties
3. Timer
4. Computed properties marked with `@Published`
5. URLSession

## Simple Combine sample

```swift
final class SCombineUseCase {
    let pass = PassthroughSubject<String, Never>()  // No initial value to send to subscribers
    var storage = Set<AnyCancellable>() // We need to store references to subscribers, so they could receive messages from a publisher
    init() {
        let sink = pass.sink {
            print("Received: \($0)")
        }
        sink.store(in: &storage)
        Task.detached {
            sleep(1)
            self.pass.send("howdy")
        }
    }
}
```

# Optimizations

1. It is important to use `final` keyword and mark methods/properties with `private`. Since polymorphism is slow and requires a dynamic dispatch. That's why it is important to use these keywords. And if possible - use `struct` instead which doesn't need a dynamic dispatch.
2. It is important to use `AnyObject` in only class-designated protocols since it brings in more optimizations.
3. `AnyObject` is too slow and dynamic. Better don't use it.
4. `IBOutlet` and `IBAction` should be `private` for effective performance and memory management.

# Communication with Objective-C

- There are only classes in Objective-C. Hence all Objective-C protocols are being constrainted to classes only in Swift.
- **Informal Protocols** - took its place before optional protocol members were introduced. They were created as categories on `NSObject`.
- `NSNull` is being used when an array with Optionals is being transferred from Swift to Objetive-C. You can have `nil` in Swift's array, but not in Objective-C. Hence all Swift `nil` are being transformed to `NSNull`.
- `@unknown default` is being used in Swift `switch` statements when a source enum from `C` language might have a new members to be added later. If they were added, then `@unknown default` will produce a _waning_.
