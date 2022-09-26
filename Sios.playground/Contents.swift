import UIKit
import Foundation
import os
import Combine
import SwiftUI

/** { , -> Void and -> () can be used to identify a function with no return value */
func noReturnFunc() -> () {
    return;
}

/** Can return a function as a result */
func getFunc(_ name: String) -> ((Int, Int) -> Int) {
    func sum(_ x: Int, _ y: Int) -> Int { x + y }
    func sub(_ x: Int, _ y: Int) -> Int { x - y }
    func unk(_ x: Int, _ y: Int) -> Int { fatalError() }

    switch name {
    case "sum":
        return sum(_:_:)
    case "sub":
        return sub(_:_:)
    default:
        return unk(_:_:)
    }
}
//print(getFunc("sum")(2, 3))

/** Resolving ambiguous function */
func ambiguous() -> Int { 5 }
func ambiguous() -> String { "Fildo" }
//print((ambiguous as () -> String)())

/**  Variadic parameters */
func simpleVariadic(_ params: String ...) {
    for s in params {
        print(s)
    }
}
//simpleVariadic("one", "two", "three")
//print("one", "two", "three", separator: ",", terminator: ".")
//simpleVariadic(["one", "two"]) <- compiler error
func doubleVariadic(left: String ..., right: String...) {
    print(left)
    print(right)
}
//doubleVariadic(left: "one", "two", right: "three")
func confusingVariadic(_ left: String ..., middle: String, _ right: String ...) {
    print(middle)
}
//confusingVariadic("one", "two", middle: "three", "four", "five")

/** Ignored parameter */
func ignoredParameter(fildo: String, rover: String, notYou _: Bool) { }

/** Modifiable parameter */
func removeAllOccurancesOf(_ char: Character, from str: inout String) -> Int {
    var removed = 0
    while let idx = str.firstIndex(of: char) {
        str.remove(at: idx)
        removed += 1
    }
    return removed
}
//var helloString = "Hello"
//let helloRemoved = removeAllOccurancesOf("l", from: &helloString)
//print(helloString, helloRemoved, separator: ", ", terminator: ".")
func objcRemoveAllOccurances(_ char: Character, from str: UnsafeMutablePointer<String>) -> Int {
    var removed = 0
    while let idx = str.pointee.firstIndex(of: char) {
        str.pointee.remove(at: idx)
        removed += 1
    }
    return removed
}
//let objcHelloRemoved = removeAllOccurancesOf("l", from: &helloString)
//print(helloString, objcHelloRemoved, separator: ", ", terminator: ".")

/** Function typealias */
typealias VoidFunction = () -> ()

/** Anonymous function */
let anonymousFunction = {
    (param: Bool) -> Bool in
    return param
}
/*UIView.animate(withDuration: 0.4) {
} completion: {
    print($0)   // <- refer to param by number
}*/

/** Trailing closure syntax */
/*UIView.animate(withDuration: 0.4) {
} completion: { _ in
}*/
func doThis(_ f: () -> ()) { f() }
doThis {
    //print("done")
}

/** Define-and-Call */
func processThis(str: String) { }
processThis(str: {
    let str = "Hello"
    return str
}())

/** Function is a closure, and it captures a context */
func callThisPlease(_ f : () -> ()) { f() }
class Fox {
    var foxSays = "Ring-ding-ding-ding-dingeringeding"
    func say() {
        //print(foxSays)
    }
}
let fox = Fox()
let foxSays = fox.say
callThisPlease(foxSays)
fox.foxSays = "Gering-ding-ding-ding-dingeringeding"
callThisPlease(foxSays)

/** Function maker */
func makePrintFunc(_ message: String) -> () -> () {
    { print(message) }
}
let printHello = makePrintFunc("Hello")
//printHello()

/** Closures preserving captured environment */
func addCounter(_ f: @escaping () -> ()) -> () -> () {
    var counter = 0
    return {
        counter = counter + 1
        print("count is \(counter)")
        f()
    }
}
let greet = {
    print("howdy")
}
let greetCounted = addCounter(greet)
//greetCounted()
//greetCounted()
//greetCounted()

/** Espacing closures */
func ecLegal1(_ f: () -> ()) {
  f()
}
func ecLegal2(_ f: () -> ()) -> () -> () {
  { }
}
//func ecIllegal(_ f: () -> ()) -> () -> () {
//  f
//}
func ecLegal(_ f: @escaping () -> ()) -> () -> () {
  f
}

/** Capture Lists */
var capturedVarX = 0
let capturingAnonymousFunc: () -> () = {
  print(capturedVarX)
}
//capturingAnonymousFunc()  // 0
capturedVarX = 1
//capturingAnonymousFunc()  // 1
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

/** Function Signatures */
class SigningFox {
  func furr(_ now: Bool) { }
  func furr(loudly: Bool) { }
  func furr(loudly: Int) { }
}
let signingFox = SigningFox()
//let furrFuncIllegal = signingFox.furr <- ambiguous
let furrLegal1 = signingFox.furr(_:)
let furrLegal2 = signingFox.furr as (Int) -> ()

/** Function reference scope */
class FRFox {
  func furr() {
    print("furr")
  }
  func furr(_ loud: Bool) { }
}
class FRWolf {
  func woof() { }
  func interact() {
    let w = woof
    let furr = FRFox.furr(_:)
    //furr <- compiler error
  }
  func testFurr() {
    let f = FRFox.furr as (FRFox) -> () -> Void
    let fox = FRFox()
    f(fox)
  }
}
let frWolf = FRWolf()
frWolf.testFurr()

/** Custom variable name in setter instead of a `newValue` */
class CLWCustomSetter {
  var prop: String {
    set (newProp) {
      print(newProp)
    }
    get {
      "Furr"
    }
  }
}

/** Property wrapper */
@propertyWrapper struct IntRangeWrap {
  private var val: Int = 0
  var wrappedValue: Int {
    get { val }
    set {
      val = max(min(newValue, 0), 5)
    }
  }
}
class CLSUsesPropWrapper {
  @IntRangeWrap var val
  func setWV() {
    val = 8
  }
}

/** Setter observers */
class CLSWSetrObzrv {
  var setObser = "rover" {
    willSet (newDogName) { }
    didSet (oldDogName) { }
  }
}

/** Lazy properties: global, static, instance, local (new for Swift 5.5) */
class SClsWLazLocVar {
  func setAndPrint(_ val: String) -> String {
    print("In setAndPrint: \(val)")
    return val
  }
  func funcWLazVar() {
    print("Before Lazy")
    //lazy var dog = setAndPrint("Rover")
    print("After Lazy")
    //print(dog)
  }
}
//SClsWLazLocVar().funcWLazVar()
class LZPRPTTrick {
  let first = "Patrick"
  let last = "Chase"
  //var full = first + last // Illegal
  lazy var full = first + last  // Legal
}

/** Double literal using a scientific notation */
let threeHundred = 3e2  // means 3*10^2 = 300
let sixtyFour = 0x10p2  // means 64: 0x10 - is 16, p2 = 2^2

/** Dividing */
let doubleRemainder = 12.8.remainder(dividingBy: 3) // 0.8 - remainder
let quotientAndReminderInt = 13.quotientAndRemainder(dividingBy: 3) // tuple: 4, 1
let isMultiplier = 12.isMultiple(of: 3) // true

/** Int overflow and underflow */
let almostMaxInt = Int.max - 1
let safelyAdd = almostMaxInt.addingReportingOverflow(100) // overflow = true, result is tuple (int, bool)

/** Generate a random number using Numerics */
let randInt = Int.random(in: 0...10)

/** Comparing two Double values properly */
let zeroPointOne = 0.1
var tenTimeSum = 0.0
for _ in 0..<10 { tenTimeSum += zeroPointOne }
var multipliedSum = 0.1 * 10
let dblEqualFalse = tenTimeSum == multipliedSum // false
let dblEqualTrue = tenTimeSum >= multipliedSum.nextDown && tenTimeSum <= multipliedSum.nextUp // true

/** Raw string with a special character */
let rswspc = #"Hello\#nthere"#

/** Custom representative of number as a string in custom numbering */
let stringifiedCustomNum = String(31, radix: 16)  // 1f
let integeredFromCustNumStr = Int(stringifiedCustomNum, radix: 16)  // Optional(31)

/** Ranges */
let rngtHelloStr = "Hello"
let rngyarrHS = Array(rngtHelloStr)
let rngtSubstr = String(rngyarrHS[1...3])
let rngtModIdx1 = rngtHelloStr.index(rngtHelloStr.startIndex, offsetBy: 1)
let rngtModIdx2 = rngtHelloStr.index(rngtModIdx1, offsetBy: 2)
let rngtModSubstr = rngtHelloStr[rngtModIdx1...rngtModIdx2]
let rngtPartialRange = rngtHelloStr[..<rngtModIdx2]

/** Tuples */
let tplInt: Int
let tplStr: String
(tplInt, tplStr) = (1, "Two") // Assign multiple values
var tplTstStr1 = "Hello"
var tplTstStr2 = "World"
(tplTstStr1, tplTstStr2) = (tplTstStr2, tplTstStr1) // Swap
typealias TupledPoint = (x: Int, y: Int)  // Tuple as alias

/** Optionals */
var opttst = Optional("Dog")
let optchk: Void? = opttst = "Rover"  // If `optchk` is not nil - then assignment worked

/** Use instance method as a static one */
class SecretLifeOfInstanceMethod {
  var val = 0
  func store(_ v: Int) {
    val = v
  }
}
let sloimInstance = SecretLifeOfInstanceMethod()
let storeFunc = SecretLifeOfInstanceMethod.store(sloimInstance)
storeFunc(5)
//print(sloimInstance.val)  // will assign "5" as a "val" to "sloimInstance"

/** Subscripts */
class SubscriptedDigit {
  let digit: Int
  init(_ d: Int) {
    digit = d
  }
  subscript(idx: Int) -> Int {  // Simple read-only subscript
    get {
      let str = String(digit)
      return Int(String(str[str.index(str.startIndex, offsetBy: idx)]))!
    }
  }
  subscript(idx idx: Int = 0) -> Int {  // Subscript with named parameter and default parameter
    self[idx]
  }
}

/** Enums */
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
let sewavInt: SimpleEnumWithAssociatedValue = .code(5)
let sewavFatal = SimpleEnumWithAssociatedValue.fatal
switch sewavInt {
case .code(let c):
  if c == 5 {
    //print("c is five")
  }
default:
  fatalError()
}

/** Structs **/
struct StructWithMutatingGet {
  var number = 42
  var nextNumber: Int {
    mutating get {  // Since it changes the struct's member
      number += 1
      return number
    }
  }
}
struct StructWithLazyProperty {
  private lazy var name = "Rover"
  mutating func getName () { name } // Since it could alter the struct
}
struct StructWhichSetsSelf {
  var num = 42
  mutating func setNewNum(_ n: Int) {
    self = StructWhichSetsSelf(num: n)
  }
}
func structsTestSettingFieldSetsInstance() {
  var structInstance: StructWhichSetsSelf = StructWhichSetsSelf(num: 42) {
    didSet {
      print("Did Set structInstance")
    }
  }
  structInstance.num = 123
}
//structsTestSettingFieldSetsInstance() // prints "Did Set structInstance"

/** Inheritance: override tricks */
class InhStandardPet {
  func walk() { print("walk walk walk") }
}
class InhCat: InhStandardPet {
  func meow() {
    print("meow")
  }
}
class InhDog: InhStandardPet {
  func barkAt(pet: InhCat) {
    print("bark")
  }
}
class InhDogBarkingAtOptional: InhDog {
  override func barkAt(pet: InhCat?) { }
}
class InhDogBarkingAtAnyone: InhDog {
  override func barkAt(pet: InhStandardPet) { }
}

/** Designated and convenience initializers */
class DesConvDog {
  let name: String
  let license: Int
  
  init(name: String, license: Int){
    self.name = name
    self.license = license
  }
  
  convenience init(license: Int) {
    self.init(name: "Rover", license: license)
  }
  
  convenience init() {
    self.init(license: 1)
  }
}

/** Overriding properties */
class OvPropClassBase {
  var storedProp: String = "foo"
  var storedWritableProp: String {
    set { storedProp = newValue }
    get { storedProp }
  }
  var storedReadableProp: String {
    storedProp
  }
}
class OvPropClassSubclass: OvPropClassBase {
  override var storedProp: String {
    didSet {  // added a property observer
      print("didSet storedProp")
    }
  }
  override var storedWritableProp: String {
    set { storedProp = newValue + "howdy" } // overriden both setter and getter
    get { storedProp }
  }
  override var storedReadableProp: String {
    set { storedProp = newValue } // added a setter
    get { storedProp }
  }
}

/** Factory method and polymorphism */
class FactPolDog {
  let name: String
  required init(name: String) {
    self.name = name
  }
  class func makeAndName() -> Self {  // Will return the actual type (of subclass for example)
    Self(name: "Fildo")
  }
}
class FactPolNoisyDog: FactPolDog { }

/** Global factory with passing a type */
func gfptMakeDog(dt: FactPolDog.Type) -> FactPolDog {
  dt.init(name: "Rover")
}
let gfptDog = gfptMakeDog(dt: FactPolDog.self)
let gfptNoisyDog = gfptMakeDog(dt: FactPolNoisyDog.self)
let gfptOneMoreNoisyDog = gfptMakeDog(dt: type(of: gfptNoisyDog))
func gfptDogExpecter(whoIsIt: FactPolDog.Type) {
  let equally = whoIsIt == FactPolDog.self
  let typology = whoIsIt is FactPolDog.Type
}

/** Class protocol */
protocol clspDogieid1: FactPolDog { }  // Only `FactPolDog` and its subclasses can implement it.
protocol clspDogieid2 where Self:FactPolDog { }  // Only `FactPolDog` and its subclasses can implement it.
protocol onlyClassesProtocol1: AnyObject { } // Only classes (not structs, not enums) can implement it.
protocol onlyClassesProtocol2 where Self:AnyObject { } // Only classes (not structs, not enums) can implement it.

/** Protocol with optional members */
@objc protocol ProtocolWithOptionals {  // Have to have `objc` to inlude `optional` members
  func requiredFunc()
  @objc optional func optionalFunc()  // Not too "Swifty", but required for Objective-C compatibility
}

/** Expressible - when we can express some custom type with another one */
class IntExpressibleNest: ExpressibleByIntegerLiteral {
  var eggsCount: Int = 0

  required init(integerLiteral value: IntegerLiteralType) {
    self.eggsCount = value
  }
}
func funcExpectingNest(_ nest: IntExpressibleNest) { }
funcExpectingNest(5)  // We can pass a number now

/** Better factory with generics */
func genFactDogMaker<T:FactPolDog>(_ : T.Type) -> T {
  T.makeAndName()
}
let inferredAsNoisyDog = genFactDogMaker(FactPolNoisyDog.self) // Result inferred to `FactPolNoisyDog`

/** Generic protocol with Self */
protocol GenProtWithSelfFlier {
  func flyWith(_ S: Self)
}
struct ImplProtSelfBee: GenProtWithSelfFlier {
  func flyWith(_ S: ImplProtSelfBee) {}
}

/** Protocol with associated type */
protocol GenProtWithAssociatedTypeFlier {
  associatedtype T
  func flyWith(_ mate: T)
  func mateWith(_ mate: T)
}
struct ImplProtAssocBee: GenProtWithAssociatedTypeFlier {
  func flyWith(_ mate: ImplProtAssocBee) { }  // Has to be the same
  func mateWith(_ mate: ImplProtAssocBee) { } // Has to be the same
}

/** Generics as a type constraint */
protocol TCFlier {
  func fly()
}
protocol TCFlocker {
  associatedtype T: TCFlier
  func flockWith(_ t: T)
}
struct TCBee: TCFlier {
  func fly() { }
}
struct TCBird: TCFlocker {
  func flockWith(_ t: TCBee) { }
}

/** Generic function with a type constraint */
func gftcMin<T: Comparable>(_ items: T...) -> T {
  var min = items.first!
  for item in items.dropFirst() { // Returns the sequence without a first element
    if item < min {
      min = item
    }
  }
  return min
}

/** Generics specializaton through type declaration */
protocol GSTTDFlier {
  init()
}
struct CSTTDBird: GSTTDFlier {
  init() { }
}
struct CSTTDMaker<T:GSTTDFlier> {
  static func makeFlier() -> T {
    T()
  }
}

/** Inheritance and type specialization */
class ITSDog<T> {
  func speak(_ what: T) { }
}
class ITSStringDog: ITSDog<String> { }
class ITSChildDog<T>: ITSDog<T> { }

/** Generics and covaraince - illegal */
struct IGCWrappet<T> { }
class IGCCat { }
class IGCCalicoCat: IGCCat { }
//let illegalVar: IGCWrappet<IGCCat> = IGCCalicoCat() -> Won't compile

/** Generics and covaraince - legal */
protocol GCLMeower {
  func meow()
}
struct GCLWrapper<T> {
  let meower: T
}
class GCLCat: GCLMeower {
  func meow() { }
}
class GCLCalicoCat: GCLCat { }
let legalVar: GCLWrapper<GCLMeower> = GCLWrapper(meower: GCLCalicoCat())  // Legal because of protocol constraint

/** Automatic generic resolution */
class AGRNode<T> {
  let val: T
  var left: AGRNode
  var right: AGRNode<T> // same as above
  init(val: T, left: AGRNode, right: AGRNode) {
    self.val = val
    self.left = left
    self.right = right
  }
}

/** Associated types chains */
protocol ATCWeapon { }
struct ATCSword: ATCWeapon { }
struct ATCBow: ATCWeapon { }
protocol ATCFighter {
  associatedtype Enemy: ATCFighter
  associatedtype Weapon: ATCWeapon
  func steal(weapon: Enemy.Weapon, from: Enemy)
}
struct ATCSoldier: ATCFighter {
  typealias Enemy = ATCArcher
  typealias Weapon = ATCSword
  func steal(weapon: ATCBow, from: ATCArcher) { }
}
struct ATCArcher: ATCFighter {
  typealias Enemy = ATCSoldier
  typealias Weapon = ATCBow
  func steal(weapon: ATCSword, from: ATCSoldier) { }
}
struct ATCCamp<T: ATCFighter> {
  var spy: T.Enemy? // If it is a "Soldier", then this could be only "Archer" and vice versa
}

/** Where clauses */
protocol WCFlier {
  associatedtype T
}
struct WCBird: WCFlier {
  typealias T = String
}
struct WCInsect: WCFlier {
  typealias T = WCBird
}
func wcFlockWithEquatable<T>(_ who: T) where T: WCFlier, T.T: Equatable { }  // Can be called with Bird, but not with Insect
func wcFlowWithString<T>(_ who: T) where T: WCFlier, T.T == String { }  // Same as above, but more strict

/** Protocol extension */
protocol PEFlierNoFly { }
extension PEFlierNoFly {
  func fly() {   // Not polymorphic
    print("flop-flop-flop")
  }
}
struct PEBird: PEFlierNoFly { }
struct PEInsect: PEFlierNoFly {
  func fly() {
    print("whirrrrr")
  }
}
let peInsect: PEFlierNoFly = PEInsect()
//peInsect.fly()  // <- will print "flop-flop-flop"
protocol PEFlierWithFly {
  func fly()  // Polymorphic
}
extension PEFlierWithFly {
  func fly() {
    print("flop-flop-flop")
  }
}
struct PEInsect2: PEFlierWithFly {
  func fly() {
    print("whirrrrr")
  }
}
let pe2Insect: PEFlierWithFly = PEInsect2()
//pe2Insect.fly() // <- will print "whirrrrr"

/** Return a generic type through a protocol */
class RGTDogWrapper<T: RGTDog> {
  let wrapped: T
  init(_ dog: T) { wrapped = dog }
  func unwrap() -> T { wrapped }
}
protocol RGTWrappableDog: RGTDog {
  var wrapped: RGTDogWrapper<Self> { get }
}
extension RGTWrappableDog {
  var wrapped: RGTDogWrapper<Self> { RGTDogWrapper(self) }
}
final class RGTDog: RGTWrappableDog { // <- and this is legal, but same thing as below
  //var wrapped: RGTDogWrapper<Self> { RGTDogWrapper(self) } <-- illegal
}

/** Extension constraints */
extension Array where Element: Comparable {
  // all methods here will appear only if Array consisgs of comparable elements
  func isGreaterThanZero() -> Bool where Element: Equatable { true }  // Will appear if Element is both Comparable and Equatable
}

/** Array slice indexing */
let asiDogs = ["Fido", "Rover", "Daisy"]
let asiSlice = asiDogs[1...2] // "Rover", "Daisy"
let asiRover = asiDogs[1] // "Rover"
let asiStartRover = asiSlice.startIndex // 1 - since a slice of the original array
let asiSliceToArray = Array(asiSlice)
let asiDaisy = asiSliceToArray[1] // "Daisy"

/** Array subscripting */
var asOrigArray = [1, 2, 3]
asOrigArray[1..<2] = [7, 8] // 1, 7, 8, 3
asOrigArray[1..<2] = [] // 1, 8, 3
asOrigArray[1..<1] = [10] // 1, 10, 8, 3
let asAppArray = [20, 21]
asOrigArray[1..<2] = ArraySlice(asAppArray) // 1, 20, 21, 8, 3

/** Array subscripting with a partial rage (takes first or last index) */
var asrArray = [1, 2, 3]
asrArray[1...] = [5, 6] // 1, 5, 6

/** Joining arrays */
let jaArray = [[1, 2], [3, 4], [5, 6]]
let jaJoined = jaArray.joined(separator: [10, 11])  // 1, 2, 10, 11, 3, 4, 10, 11, 5, 6

/** Array reduce */
let arArray = [1, 4, 9, 13, 122]
let arSum1 = arArray.reduce(0) { $0 + $1 }  // 139
let arSum2 = arArray.reduce(0, +) // 139

/** Array reduce into */
let arriArray = [1, 4, 9, 13, 12]
let arriReduced = arriArray.reduce(into: [[],[]]) { $0[$1%2].append($1) } // [[4, 12], [1, 9, 13]]

/** Zip function - combines 2 arrays into tuples */
let zfcArr1 = ["CA", "TX"]
let zfcArr2 = ["California", "Texas"]
let zfcTuples = zip(zfcArr1, zfcArr2)
let zfcDictionary = Dictionary(uniqueKeysWithValues: zfcTuples) // ["CA": "California", "TX": "Texas"]
// uniqueKeysWithValues will crash if there are non-unique keys, but uniqueKeysWith - no

/** Grouping with the dictionary */
let gwdStates = ["California", "Colorado", "New Yourk", "North Carolina"]
let gwdStatesGrouped = Dictionary(grouping: gwdStates) { $0.prefix(1).uppercased() }    // ["N": ["New Yourk", "North Carolina"], "C": ["California", "Colorado"]]

/** Count repeated words */
let crwSentence = "Tesla 3 is not a real Tesla It is a cheap fake which pretends to be a one Text S is a real Tesla"
let crwSplit = crwSentence.split(separator: " ").map { String($0) }
var crwRepeated = [String: Int]()
crwSplit.forEach { crwRepeated[$0, default: 0] += 1 }

/** Switch control flow */
let scfVal1 = 5
switch scfVal1 {
case 0: break //print("Is 0")
case _: break //print("Something else")
}
switch scfVal1 {
case 0: break //print("Is 0")
case let n: break //print(n)
}
switch scfVal1 {
case ..<0: break //print("negative")
case 1...: break //print("from 1 to 3")
case 4...: break //print("4 or greater")
case 0: break //print("zero")
default: break
}
let scfVal2 = Optional(7)
switch scfVal2 {
case 1?: break //print("Optional 1")
case nil: break //print("Is nil")
case let n?: break //print("Something else optional: \(n)")
}

/** Switch with true as a tag */
let swttDog = FactPolDog(name: "Fildo")
let swttNoisyDog = FactPolNoisyDog(name: "Rover")
let swttSomeDog: FactPolDog = swttNoisyDog
switch true {
case swttSomeDog === swttDog: break //print("Its a dog")
case swttSomeDog === swttNoisyDog: break //print("Its a noisy dog")
default: print("Something else")
}

/** Switch with a condigion */
let swacVar = 5
switch swacVar {
case let j where j < 0: break //print("Negative")
default: break //print("Non negative")
}

/** Switch with a type check */
switch swttSomeDog {
case is FactPolNoisyDog, is Int: break //print("Noisy dog")
case _: break //print("Some other dog")
}

/** Swith with a type cast */
switch swttDog {
case let noisyDog as FactPolNoisyDog: break //print(noisyDog.name + " is a noisy dog")
default: break //print("Some other dog")
}

/** Switch with multiple checks */
let swmcDict: [AnyHashable : Any] = ["Size" : "XS", "Length" : 5]
switch (swmcDict["Size"], swmcDict["Length"]) {
case let (size as String, length as Int): break //print("Size is \(size) and length is \(length)")
default: print("Something else")
}

/** Switch with enum unwrapping associated objects */
enum sweEnum {
    case number(Int)
    case literal(String)
    case other
}
let sweEnInt: sweEnum = .number(5)
switch sweEnInt {
case let .literal(s) where s.hasPrefix("Lol"): print("Has prefix \(s)") // if let before - can add a condition
case let .number(k) where k > 10, let .number(k) where k < 20: break //print("bordered k = \(k)")   //<- will be printed
case .number(100...): print("More than 100")
case .number(let k): print("Is Number \(k)")
case .other: fallthrough
default: print("something else")
}

/** If case - check for an enum value with an associated object */
if case let .number(k) = sweEnInt, k > 0 { }

/** While loop which is not crashing at the end of array */
let wlncArr: [sweEnum] = [.number(4), .number(5), .literal("Str"), .other]
var wlncIndex = 0
while case let .number(k) = wlncArr[wlncIndex] {
    //print("Value is \(k)")
    wlncIndex += 1
}

/** For loops are using while loops under the hood through an iterator */
var flwlIterator = [1, 2, 3, 4].makeIterator()
while let k = flwlIterator.next() {
    // do some stuff
}

/** For loop with a condition */
for i in 0...10 where i.isMultiple(of: 2) {
    // only even numbers
}

/** For loop through an array of enums with associated values */
for case let .number(k) in wlncArr {
    // only values with number associated
}

/** Conditional casting in the for loop */
let csitDogs: [FactPolDog] = [swttDog, swttNoisyDog]
for case let csDog in csitDogs where csDog is FactPolNoisyDog {
    // only noisy dogs iterated (can use the same approach to get certain types of views from subviews array)
}

/** Limiting a sequence in the code */
let lseqc = sequence(first: 0) { $0 > 10 ? nil : $0 + 1 }
for _ in lseqc { }

/** Limiting a sequence with a prefix */
let lseqp = sequence(first: 0) { $0 + 1 }
for _ in lseqp.prefix(5) { }

/** Sequence with a state - Fibonacci numbers */
let fibseq = sequence(state: (0, 1)) { (pair: inout (Int, Int)) -> Int in
    let n = pair.0 + pair.1
    pair = (pair.1, n)
    return n
}
for _ in fibseq.prefix(5) { }

/** Use `lazy` for prefix function - do not let it work too hard */
for _ in fibseq.lazy.prefix(100) { break }  // Won't extract 100 members in advance

/** do-catch samples */
enum DCSFirstError: Error {
    case lightError
    case midError
    case fatal
}
enum DCSSecondError: Error {
    case withIntCode(code: Int)
    case withStringCode(code: String)
    case fatal
}
do {
    // do something which throws errors
} catch DCSFirstError.lightError, DCSFirstError.midError {
    // No "error" object here. We know the type of error
} catch let error as DCSFirstError {
    // We have "error" object here. Any type of DCSFirstError might fall here
} catch DCSSecondError.withIntCode(let code) where code < 0 {
    // No "error" object. But we have the code which is negative
} catch {
    // catch anything else
}

/** Throwing getter (only for read-only computed properties */
struct SWTPDog {
    private var _name: String?
    mutating func setName(_ name: String){
        self._name = name
    }
    var name: String {
        get throws {
            enum AnonymousError: Error {
                case noName
            }
            guard let name = _name else { throw AnonymousError.noName }
            return name
        }
    }
}

/** Rethrows. When you can pass a functnio which doesn't throw in function accepting something which could throw */
struct RTHSample {
    func receiveThrower(_ f:(String) throws -> ()) rethrows {
        try f("Rover")
    }
    func callReceiveThrower() {
        receiveThrower { s in
            print("OK")
        }
    }
}

/** Throwable initializer */
struct ThrowingInitDog {
    let name: String
    init(name: String) throws {
        enum DogError: Error {
            case noRoversHere
        }
        if name == "Rover" { throw DogError.noRoversHere }
        self.name = name
    }
}

/** Artificial scoping to clean up the resources */
func astcfr() {
    var arr = ["Rover", "Rover", "Fildo", "Fildo", "Fildo", "Sparky"]
customLabel: do {   // label is not necessary
        var temp = Set<String>()
        arr = arr.filter { temp.insert($0).inserted }
    }
    // Here the temporary set will be destroyed
}

/** Defer statement which changes the value after its returned */
struct DFCountown: Sequence, IteratorProtocol {
    var count: Int
    mutating func next() -> Int? {
        if count == 0 {
            return 0
        } else {
            defer { count -= 1 }
            return count
        }
    }
}

/** Trick guard with non-optional */
func tgGetTen() -> Int { 10 }
func trickedGuard() {
    guard case let ten = tgGetTen(), ten == 10 else { return }
}

/** Mirrors */
struct MirroredDog: CustomStringConvertible {
    let name: String
    let license: Int

    var description: String {
        var desc = "Dog is: ("
        let mirror = Mirror(reflecting: self)
        mirror.children.forEach { desc += "\($0.label!) : \($0.value), " }
        return desc.dropLast(2) + ")"
    }
}
struct CustomMirroredDog: CustomReflectable {
    let name: String
    let license: Int

    var customMirror: Mirror {
        let children: [Mirror.Child] = [("Dog Name", name), ("License Number", license)]
        return Mirror(self, children: children)
    }
}

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

/** Stored function without a retain cycle */
class SFRCFunctionStorer {
  var f: (() -> ())?
}
class CFRCRetainerCreator {
  func test() {
    let fh = SFRCFunctionStorer()
    fh.f = {  [weak fh] in  // without it - it will be a retain cycle
      print(fh)
    }
  }
}
protocol CanBeUsedAsWeakType: AnyObject { }
class SFRCSomethingWithWeakProt {
  weak var delegate: CanBeUsedAsWeakType?
}

/** Hashable implementation */
struct HashableDog: Hashable { // No need to supply `Equatable` - it is there automatically
  let name: String
  let license: Int
  let color: UIColor
  
  static func ==(lhs: HashableDog, rhs: HashableDog) -> Bool {
    lhs.name == rhs.name && lhs.license == rhs.license // we don't want to compare the color
  }
  
  func hash(into hasher: inout Hasher) {
    name.hash(into: &hasher)
    license.hash(into: &hasher)
    // we are hashing only values which we're comparing in `==`
  }
}

/** Comparable enum automatically synthesized (new for Swift 5.3) */
enum CEPlanets: Comparable {
  case Sun
  case Mercury
  case Venus
  case Earth
  case asteroid(String)
}
//print(CEPlanets.Sun > CEPlanets.Earth)   // <- true
//print(CEPlanets.Earth > CEPlanets.asteroid("Ceres"))   // <- true
//print(CEPlanets.asteroid("Ceres") < CEPlanets.asteroid("Vesta"))   // <- true

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

/** Instance as a function - when some object could act like a function */
struct IAFAdder {
  let base: Int
  
  func callAsFunction(_ addend: Int) -> Int {
    base + addend
  }
}
let iafAdder = IAFAdder(base: 5)
let iafAdded = iafAdder(4)  // 9

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

/** Property wrapper with multiple params */
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
struct tstPWMC {
  func test() {
    //@PWMClamped(wrappedValue: 5, min: 1, max: 7) var pwmc1
    //@PWMClamped(min: 1, max: 7) var pwmc2 = 5
  }
}

/** Property wrapper as a function parameter */
@propertyWrapper struct PWNonEmptyString1 {
  // Won't crash in function call
  private var val: String
  var wrappedValue: String {
    get { val }
    set {
      if newValue.isEmpty {
        fatalError()
      } else {
        val = newValue
      }
    }
  }
}
@propertyWrapper struct PWNonEmptyString2 {
  // Will crash in function call
  private var val: String
  var wrappedValue: String {
    get { val }
    set {
      if newValue.isEmpty {
        fatalError()
      } else {
        val = newValue
      }
    }
  }
  init(wrappedValue: String) {
    self.val = wrappedValue
    if wrappedValue.isEmpty {
      fatalError()
    }
  }
}
struct PWFPTest {
  //func say1(@PWNonEmptyString1 _ what: String) {
    // won't crash if we call say1("")
 // }
  
  func say2(@PWNonEmptyString2 _ what: String) {
    // will crash if we call say2("")
  }
}

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

/** Custom String Interpolation - the way to make things be represented as literals */
extension DefaultStringInterpolation {
  mutating func appendInterpolation(_ i: Int, roman: Bool) {
    if roman {
      let romanRepresentation = "MVL" // should be dynamic
      appendInterpolation(romanRepresentation)
    } else {
      appendInterpolation(i)
    }
  }
}
func testCustomStrI() {
  let str = "Hello. MVL in roman is: \(1055, roman: true) in arabic"
}

/** Keyword `some` */
protocol KSNamed {
  var name: String { get set }
}
struct KSPerson: KSNamed {
  var name: String
}
func ksNamedMaker(_ name: String) -> some KSNamed {
  KSPerson(name: name)
}
func ksCompare<T>(_ n1: T, _ n2: T) -> Bool where T: KSNamed {
  n1.name == n2.name
}
let ksJNamed1: KSNamed = KSPerson(name: "John")
let ksJNamed2: KSNamed = KSPerson(name: "Jack")
//ksCompare(ksJNamed1, ksJNamed2) // illegal
let ksPNamed1 = ksNamedMaker("John")
let ksPNamed2 = ksNamedMaker("Jack")
_ = ksCompare(ksPNamed1, ksPNamed2) // OK, because compiler knows that it will be `KSPerson`

/** Result builder */
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

/** Structured concurency (iOS 15+, Swift 5.5+) */
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

/** Transform old-fashioned completion handler to structured concurency */
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

/** Multiple (known number) concurent subtasks within one concurent task with structured concurency */
func mcswotwstDownloader(_ url1: URL, _ url2: URL) async throws -> (Data, Data) {
    //async let data1 = URLSession.shared.data(from: url1, delegate: nil)
    //async let data2 = URLSession.shared.data(from: url2, delegate: nil)
    //return try await (data1.0, data2.0)
    fatalError()    // code above is fine, but this playground complains
}

/** Multiple (unknown number) concurent subtasks */
func munknMultipleDownloader(_ urls: URL...) async throws -> [URL:Data] {
    try await withThrowingTaskGroup(of: [URL:Data].self) { group in
        var result = [URL:Data]()
        for url in urls {   // this runs on a main queue
            group.addTask { // Also can use `addTaskUnlessCancelled` which is preferrable
                [url: try await URLSession.shared.data(from: url, delegate: nil).0] // this awaits on a background
            }
        }
        for try await d in group {
            result.merge(d) { curr, _ in curr }
        }
        return result
    }
}

/** Async sequence on Combine sample */
struct ASonCombS {
    func test() {
        let timerpub = Timer.publish(every: 1, tolerance: nil, on: .main, in: .default, options: nil)
        Task {
            for await value in timerpub.values {
                print(value)    // Prints every 1 second
            }
        }
        Task {
            var asyncIterator = timerpub.values.makeAsyncIterator()
            while let value = await asyncIterator.next() {
                print(value)        // Alternative with a while loop. Same, prints every 1 second
            }
        }
    }
}

/** Custom async sequence */
struct casCount {
    var values: AsyncStream<Int>
    var continuation: AsyncStream<Int>.Continuation?
    init() {
        var myContinuation: AsyncStream<Int>.Continuation?
        values = AsyncStream { continuation in
            myContinuation = continuation
        }
        self.continuation = myContinuation
    }
    func count(from: Int, to: Int) {
        for i in from...to {
            continuation?.yield(i)
        }
    }
    func test() async {
        count(from: 0, to: 10)
        for await value in values {
            print(value)
        }
    }
}

/** Simple actor isolation */
actor SActorIsoluation {
    let syncAccessibleProperty = "Howdy"
    var asyncAccessibleProperty: String
    init(_ str: String) {
        asyncAccessibleProperty = str
    }
    func changeStringTo(_ str: String) {
        asyncAccessibleProperty = str
    }
}
func testSActorIsoluation() async {
    let act = SActorIsoluation("Rower")
    let sp = act.syncAccessibleProperty
    let ap = await act.asyncAccessibleProperty
    await act.changeStringTo("Fido")
    // act.asyncAccessibleProperty = "Fido" // illegal
}

/** @MainActor - the way to tell that some code / properties has to be accessed on a main thread only (like UI) */
actor MainIsolatedActor {
    let syncAccessibleProperty = "Howdy"
    @MainActor var asyncAccessibleProperty: String
    init(_ str: String) {
        asyncAccessibleProperty = str
    }
    @MainActor func changeStringTo(_ str: String) {
        asyncAccessibleProperty = str
    }
}
@MainActor func testMainIsolatedActor() {  // don't have to be async
    let act = MainIsolatedActor("Rower")
    let sp = act.syncAccessibleProperty
    act.asyncAccessibleProperty = "Sharky"  // can access since it's on a main thread
}

/** Implicit context switching - move code to a background thread with an actor wrapper */
class ImplCntxSwitch {
    actor DownloaderActor {
        func download(_ urls: URL...) async throws -> [URL:Data] {
            try await munknMultipleDownloader(urls[0])
        }
    }
    func downloadsWhichIsPartiallyOnMainQueue() {
        Task {
            try await munknMultipleDownloader(URL(string: "google.com")!)
        }
    }
    func downloadWhichIsCompletelyOnBackgroundQueue1() {
        let actor = DownloaderActor()
        Task {
            try await actor.download(URL(string: "google.com")!)
        }
    }
    func downloadWhichIsCompletelyOnBackgroundQueue2() {
        Task.detached {
            try await munknMultipleDownloader(URL(string: "google.com")!)
        }
    }
}

/** Call a main queue from a background queue in structured concurency */
func cmqfbq() {
    Task.detached {
        await MainActor.run { /* code for main queue */ }
    }
}

/** Sleep function - pause the execution to a give amount of time */
actor SleepActorTest {
    var randSec: UInt64 { UInt64.random(in: 1...3) }
    func wait(_ id: String) async {
        print("Wait start", id)
        await Task.sleep(randSec)
        print("Wait end", id)
    }
    func waitThrowing(_ id: String) async throws {
        print("Wait throwing start", id)
        try await Task.sleep(nanoseconds: randSec)  // Throws if the task was cancelled before sleep is over
        print("Wait throwing end", id)
    }
}

/** Task yielding - allowing other tasks to run (adding a small pause) */
func tyTaskYielding() {
    Task {
        for i in 0..<Int.max {
            await Task.yield()    // wait a bit at the beginning of a next iteration to let other tasks run
            print(i)
        }
    }
}

/** Cancelling a task. It is a good idea to check in the task if it was cancelled to react accordingly */
func cancellingTaskFSD() {
    let cancellingTask = Task {
        for i in 0..<Int.max where !Task.isCancelled {
            await Task.sleep(1)
            print(i)
        }
    }
    Task {
        await Task.sleep(10)
        cancellingTask.cancel()
    }
}

/** Tasks could have a cancellation handler */
func cancellationHandlerTest() {
    class URLSessionDataTaskHolder: @unchecked Sendable {   // it means that is could be passed between threads
        var task: URLSessionDataTask?
        func cancel() { task?.cancel() }
    }
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let dataTaskHolder = URLSessionDataTaskHolder()
        return try await withTaskCancellationHandler(
            handler: {
                dataTaskHolder.cancel() // should never throw
            },
            operation: {
                try await withCheckedThrowingContinuation { continuation in
                    let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, let response = response else {
                            let error = error ?? URLError(.badServerResponse)
                            return continuation.resume(throwing: error)
                        }
                        continuation.resume(returning: (data, response))
                    }
                    dataTask.resume()
                    dataTaskHolder.task = dataTask
                }
            }
        )
    }
}

/** Actors are reentrant. What means - their property could be accessed while it `awaits` for somethign */
actor aarActor {
    var counter = 0
    func download(url: URL) async throws -> Data {
        counter += 1
        let num = counter
        let result = try await URLSession.shared.data(for: URLRequest(url: url), delegate: nil)
        print(num == counter)   // might be `false` if someone else called another `download` in parallel
        return result.0
    }
}

/** Nonisolated - the way to tell compiler that some function might be called without await (if it doesn't access any internal var properties */
actor niwActor {
    nonisolated func sayHi() -> String { "Hi" } // can be called without await
}

/** Isolated keyword - used as a parameter specification. Adds the execution to "Actor's thread", hence no need in await */
actor ActwniActor {
    func sayHi() -> String { "Hi!" }
}
func actwniCallHi(_ actor: isolated ActwniActor) {
    actor.sayHi()   // no need to use `async`
}

/** Global Actor - they way to create an actor on the same level as @MainActor */
@globalActor struct MyTestGlobalActor {
    actor InternalActor { }
    static let shared = InternalActor()
}
@MyTestGlobalActor func testFuncRunsOnMyGlobalActor() {
    print("Rover")
}

/** Sendable. The way to tell compiler that some object is safe to pass between threads */
final class SPUser: Sendable {
    let name: String    // String is already `Sendable`. But `NSString` cannot be used
    init(_ name: String) {
        self.name = name
    }
}
final class SPMutableUser: @unchecked Sendable {
    private(set) var name = ""
    func updateName(_ name: String) {
        DispatchQueue(label: "SPMutableUser.lock.queue").sync { // Safe because only 1 thread at a time will update it
            self.name = name
        }
    }
}
actor SPUserActor {
    func filterUser(_ isIncluded: @Sendable (SPUser) -> Bool) async -> [SPUser] {    // no need to synchronize users since this callback items are thread safe
        fatalError()
    }
}

/** Adding warnings to code, hence it will appear in the issue navigator */
#warning("Fix this later")
//#error("Won't compile unless fixed")

/** Modenr way to log messages */
func loggerTest() {
    let logger = Logger(subsystem: "com.ssios", category: "testing")
    logger.log(level: .info, "Test")
}

/** Visual quick look for an object in Xcode debugger */
final class DebgugQLookObject {
    var x = 0
    var y = 0
    var width = 0
    var height = 0
    @objc func debugQuickLookObject() -> Any {
        return UIView() // allows to create a custom object to preview the parent object in debug mode graphically
    }
}

/** Optional protocol members */
final class OPMClass: NSObject { }
@objc protocol OPMProtocol {
    func woohoo()
}
let opmInstance = OPMClass()
if opmInstance.responds(to: #selector(OPMProtocol.woohoo)) {
    (opmInstance as AnyObject).woohoo()
}
(opmInstance as AnyObject).woohoo?()    // Same as above. Will check for `respondsTo` under the hood

/** Date intervals intersecting */
let gregCalendar = Calendar(identifier: .gregorian)
let diiDate1 = DateComponents(calendar: gregCalendar, year: 2021, month: 1, day: 1, hour: 0).date!
let diiDate2 = DateComponents(calendar: gregCalendar, year: 2025, month: 8, day: 10, hour: 15).date!
let diiInterval = DateInterval(start: diiDate1, end: diiDate2)
let diiContaint = diiInterval.contains(Date.now)

/** New dates formatting introduced in iOS 15 */
let ndf15 = Date.now.formatted(date: .numeric, time: .omitted)  // 7/6/2021
let ndsf15_1 = Date.now.formatted(.dateTime.day().month())  // Jul 6

/** Verbatim formatting to take a full control of date time formatting */

/** Now we should use ParseStrategy ratger than NSDateFormatter */
let pstst = try?(Date("7/14/2021", strategy: Date.ParseStrategy(
    format: """
    \(month: .defaultDigits)/\(day: .defaultDigits)/\(year: .defaultDigits)
    """, timeZone: .autoupdatingCurrent, isLenient: false)))

/** New numbers formatting introduced in iOS 15 */
let stringRepresentingPiWith2DecimalPlaces = Double.pi.formatted(.number.precision(.fractionLength(2))) // 3.14

/** Measurment - being used to represent a measurement (like distance) */
let msmr1 = Measurement(value: 5, unit: UnitLength.miles)
let msmr2 = Measurement(value: 6, unit: UnitLength.kilometers)
let msrmSum = msmr1 + msmr2
let msrmTotalFeet = msrmSum.converted(to: .feet).value  // 46084.97
let msrmModernConvetsion = msrmSum.formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(1...3))))
print(msrmModernConvetsion)

/** Equatable and Hashable for ObjC bridget classes */
final class ObjCQHDog: NSObject {
    var name: String
    var license: Int
    init(name: String, license: Int) {
        self.name = name
        self.license = license
    }

    override func isEqual(_ object: Any?) -> Bool { // If you don't override, it will work like "===" compare if objects are the same chunk of memory
        if let otherDog = object as? ObjCQHDog {
            return self.name == otherDog.name && self.license == otherDog.license
        }
        return false
    }

    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(name)
        hasher.combine(license)
        return hasher.finalize()
    }
}
let ocqhDog1 = ObjCQHDog(name: "Fido", license: 1)
let ocqhDog2 = ObjCQHDog(name: "Fido", license: 1)
let ocqhDEqual = ocqhDog1 == ocqhDog2   // true
var ochqhDogsSet = Set<ObjCQHDog>()
ochqhDogsSet.insert(ocqhDog1)
ochqhDogsSet.insert(ocqhDog2)
let ochqhDogsSetCount = ochqhDogsSet.count  // 1

/** Comparint NSNumbers */
let compnsn1 = 1 as NSNumber
let compnsn2 = 2 as NSNumber
let comparRezrTrue = compnsn1.compare(compnsn2) == .orderedAscending    // returns true .orderedAscending - means that receiver less than argument

/** Sort descriptor - the way to sort some objects by multiple criteria. Here we sort first by last name, then (if last names are equal) - by a first name */
final class SPPerson: NSObject {    // Has to conform to `NSObject` in order to use sort descriptors
    let firstName: String
    let lastName: String
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
}
let kpPersonsArray: [SPPerson] = [
    SPPerson(firstName: "Harpo", lastName: "Marx"),
    SPPerson(firstName: "Moe", lastName: "Pep"),
    SPPerson(firstName: "Groucho", lastName: "Marx"),
    SPPerson(firstName: "Manny", lastName: "Pep")
]
let kppSD1 = SortDescriptor(\SPPerson.lastName)
let kppSD2 = SortDescriptor(\SPPerson.firstName, order: .reverse)
let kppSortResult = kpPersonsArray.sorted(using: [kppSD1, kppSD2])  // [Harpo Marx, Groucho Marx, Moe Pep, Manny Pep]

/** Additional types to consider: NSCountedSet, NSOrderedSet, NSOrderedDictionary */

/** IndexSet - helps to operate multiple indexes at the same time. For example: */
let istArray = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]
var istIndexSet = IndexSet()
istIndexSet.insert(integersIn: 1...4)
istIndexSet.insert(integersIn: 8...10)
let istArrayIndexed = (istArray as NSArray).objects(at: istIndexSet)    // ["one", "two", "three", "four", "eight", "nine", "ten"]

/** Changing the name of property setter/getter when bridging from Swift to Obj-C */
final class PropOverrideOC {
    @objc(hue) var color: UIColor?  // in ObjC it will be translated to "setHue" and "hue"
}

/** Key-Value Coding sample */
final class KVCDog: NSObject {
    @objc var name: String?
}
let kvcDog = KVCDog()
kvcDog.setValue("Fildo", forKey: "name")
let kvcDogName = kvcDog.name    // "Fildo"

/** Use Combine to subscribe to notifications */
final class CombineAndSubscritingToNotification {
    var pipeline: AnyCancellable?
    init() {
        self.pipeline = NotificationCenter.default.publisher(for: .NSWillBecomeMultiThreaded, object: nil).sink { _ in
            print("Listened")
        }
    }
}

/** Use a structured concurency to process notifications as async streams */
final class StructuredConcurencyAndNotifications {
    var task: Task<(), Never>?
    init() {
        let stream = NotificationCenter.default.notifications(named: .NSMetadataQueryDidUpdate, object: nil)
        let task = Task {
            for await _ in stream {
                print("Happened")
            }
        }
        self.task = task
    }
    deinit {
        task?.cancel()
    }
}

/** Timer and Combine */
final class TimerAndCombine {
    var pipeline: AnyCancellable?
    init() {
        self.pipeline = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()  // needs to connect, or autoconnect, otherwise timer won't start publising events
            .sink { print("Timer fired at \($0)") }
    }
}

/** Timer and Structured Concurency */
final class TimerAndStructuredConcurency {
    var task: Task<(), Never>?
    init() {
        let timerPub = Timer.publish(every: 1, on: .main, in: .default)
        let task = Task {
            for await value in timerPub.values {
                print("Timer fired at \(value)")
            }
        }
        self.task = task
    }
    deinit {
        self.task?.cancel()
        self.task = nil
    }
}

/** New in iOS 14: Add an action handler as anonymous function */
func aahaafTest() {
    let button = UIButton()
    button.addAction(UIAction { _ in
        print("Tapped!")
    }, for: .touchUpInside)
}

/** A custom KVO implementation */
final class KVOObserved: NSObject { // Has to be `NSObject`
    @objc dynamic var value: Bool = false   // Has to be both `objc` and `dynamic` since swizzling will be used
}
final class KVOObserver {
    var obs = Set<NSKeyValueObservation>()
    func register(with observed: KVOObserved) {
        let options: NSKeyValueObservingOptions = [.old, .new]  // what to observe for
        let ob = observed.observe(\.value, options: options) { obj, change in
            print("Old value is \(change.oldValue), new value is \(change.newValue)")
        }
        obs.insert(ob)  // Need to save it. If it goes out of existance - observing will be stopped
    }
}

/** Autorelease pool - good to use when there are a lot of temporarily object piling up the memory usage */
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

/** Correct memory management for notification observers */
final class CorrMMNO {
    private var observers = Set<NSObject>()
    init() {
        let ob = NotificationCenter.default.addObserver(forName: .NSMetadataQueryDidUpdate, object: nil, queue: nil) { [unowned self] _ in  // if you use just `self` - it will leak
            // do something with self
        }
        observers.insert(ob as! NSObject)
    }
    deinit {
        for ob in observers {
            NotificationCenter.default.removeObserver(ob)   // If don't remove observers - then observers will leak
        }
    }
}

/** Use @NSCopying to enforce Swift's policy to copy the incoming value */
final class SCPropSample {
    @NSCopying var attrString: NSAttributedString!
}

/** How to silently corrupt Swift memory without a crash */
func corruptMemory() {
    let b = UnsafeMutablePointer<CGFloat>.allocate(capacity: 3)
    b.initialize(from: [0.1, 0.2, 0.3], count: 3)
    b[4] = 0.4  // write to a memory which we don't own. This could be spotted by using an Address Sanitizer.
}

/** Simple Combine user case */
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

/** Create a published property */
final class CombineSwitch: UISwitch {
    @Published var isOnPublisher = false
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isOnPublisher = isOn
        let action = UIAction { [unowned self] _ in
            self.isOnPublisher = self.isOn
        }
        self.addAction(action, for: .valueChanged)
    }
}
final class CombineSwitchOwner {
    var storage = Set<AnyCancellable>()
    let combineSwitch = CombineSwitch(coder: NSCoder())!
    init() {
        let sink = combineSwitch.$isOnPublisher.sink {
            print("Switch toggled to \($0)")
        }
        sink.store(in: &storage)
    }
}

/** Combine multiple publishers to create a customized events funnel */
final class CombineMultiplePublishers {
    let combineSwitch = CombineSwitch(coder: NSCoder())!
    let notifPublisher = NotificationCenter.default.publisher(for: .NSCalendarDayChanged, object: nil).compactMap { $0.name }   // publisher which maps a notification message
    lazy var combination = Publishers.CombineLatest(self.combineSwitch.$isOnPublisher, self.notifPublisher)
        //.scan((false, ""), { ($0.0, $1.1) })      // used to narrow down the notifications, for example, publish only on "even" days
        .filter { $0.0 }    // if Switch is "On"
        .map { $0.1 }   // publish a notification name
}

/** State property with a Swift UI */
struct StatePropView: View {
    @State var isHello = true   // Any changes to this property will automatically update everyone who uses it
    var greeting: String { self.isHello ? "Hello" : "Goodbye" }
    var body: some View {
        HStack {
            Text(self.greeting + " World")  // Text will be changed automatically if user clicks the button
            Spacer()
            Button("Toggle Greeting") {
                self.isHello.toggle()       // Updates the @State property which is enough to notify everyone concerned
            }
        }.frame(width: 200)
         .padding(20)
         .background(Color.yellow)
    }
}

/** Binding with SwiftUI */
struct BindingWithSwiftUI {
    @State var isHello = true   // Any changes to this property will automatically update everyone who uses it
    var greeting: String { self.isHello ? "Hello" : "Goodbye" }
    var body: some View {
        VStack {
            Text(self.greeting + " World")  // Text will be changed automatically if `isHello` changed
            Spacer()
            Toggle("Friendly", isOn: $isHello)  // `isOn` value is automatically binded to the state property `isHello`
        }
    }
}

/** SwiftUI: Present one view from another one and pass some data along */
struct SWPPPresentingView: View {
    @State var isHello = true
    var greeting: String { self.isHello ? "Hello" : "Goodbye" }
    @State var showSheet = false
    var body: some View {
        VStack {
            Button("Show message") {
                self.showSheet.toggle()
            }.sheet(isPresented: $showSheet) { [greeting] in
                SWPPPresentedView(greeting: greeting)
            }
            Spacer()
            Toggle("Friendly", isOn: $isHello)
        }.frame(width: 150, height: 100)
            .padding(20)
            .background(Color.yellow)
    }
}
struct SWPPPresentedView: View {
    let greeting: String
    var body: some View {
        Text(greeting + " World")
    }
}

/** Bindable variables, passing data back and forth */
struct SWPPPParentViewWihtBindingVar: View {
    @State var showSheet = false
    @Binding var userName: String
    var body: some View {
        Button("Show Message") {
            self.showSheet.toggle()
        }.sheet(isPresented: $showSheet) {
            
        }
    }
}
struct SWPPPChildViewWhichEntersValue: View {
    @State var userName: String
    var body: some View {
        TextField("Your Name", text: $userName) // any changes here will automatically update the `userName` in a parent view
            .frame(width: 200)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}


