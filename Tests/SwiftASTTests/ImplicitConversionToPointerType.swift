import XCTest
@testable import SwiftAST

/**
 In a function call expression, if the argument and parameter have a different type,
 the compiler tries to make their types match by applying one of the implicit conversions in the following list:

 - inout SomeType can become UnsafePointer<SomeType> or UnsafeMutablePointer<SomeType>
 - inout Array<SomeType> can become UnsafePointer<SomeType> or UnsafeMutablePointer<SomeType>
 - Array<SomeType> can become UnsafePointer<SomeType>
 - String can become UnsafePointer<CChar>

 The following two function calls are equivalent:

     func unsafeFunction(pointer: UnsafePointer<Int>) {
     // ...
     }
     var myNumber = 0x1234567890ABCDEF4

     unsafeFunction(pointer: &myNumber)
     withUnsafePointer(to: myNumber) { unsafeFunction(pointer: $0) }

 A pointer that’s created by these implicit conversions is valid only for the duration of the function call.
 To avoid undefined behavior, ensure that your code never persists the pointer after the function call ends.

 # NOTE
 When implicitly converting an array to an unsafe pointer, Swift ensures that the array’s storage is contiguous by converting or copying the array as needed.
 For example, you can use this syntax with an array that was bridged to Array from an NSArray subclass that makes no API contract about its storage.
 If you need to guarantee that the array’s storage is already contiguous, so the implicit conversion never needs to do this work, use ContiguousArray instead of Array.

 Using & instead of an explicit function like withUnsafePointer(to:) can help make calls to low-level C functions more readable,
 especially when the function takes several pointer arguments.
 However, when calling functions from other Swift code, avoid using & instead of using the unsafe APIs explicitly.

 https://docs.swift.org/swift-book/ReferenceManual/Expressions.html
 */
final class ImplicitConversionToPointerTests: XCTestCase {

    func testMutableValueToImmutablePointer() {
        func f(ptr: UnsafePointer<Int>) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.pointee)
        }
        func f2(v: inout Int) {
            f(ptr: &v)
        }
        var v: Int = 0x1234567890ABCDEF
        f(ptr: &v)
        f2(v: &v)
    }

    func testMutableValueToMutablePointer() {
        func f(ptr: UnsafeMutablePointer<Int>) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.pointee)
        }
        func f2(v: inout Int) {
            f(ptr: &v)
        }
        var v: Int = 0x1234567890ABCDEF
        f(ptr: &v)
        f2(v: &v)
    }

    func testMutableValueArrayToImmutablePointer() {
        func f(ptr: UnsafePointer<Int>) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.pointee)
            XCTAssertEqual(0x2234567890ABCDEF, ptr.advanced(by: 1).pointee)
            XCTAssertEqual(0x3234567890ABCDEF, ptr.advanced(by: 2).pointee)
        }
        func f2(v: inout [Int]) {
            f(ptr: v)
            f(ptr: &v)
        }
        var v: [Int] = [0x1234567890ABCDEF, 0x2234567890ABCDEF, 0x3234567890ABCDEF, ]
        f(ptr: v)
        f(ptr: &v)
        f2(v: &v)
    }

    func testMutableValueArrayToMutablePointer() {
        func f(ptr: UnsafeMutablePointer<Int>) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.pointee)
            XCTAssertEqual(0x2234567890ABCDEF, ptr.advanced(by: 1).pointee)
            XCTAssertEqual(0x3234567890ABCDEF, ptr.advanced(by: 2).pointee)
        }
        func f2(v: inout [Int]) {
            f(ptr: &v)
        }
        var v: [Int] = [0x1234567890ABCDEF, 0x2234567890ABCDEF, 0x3234567890ABCDEF, ]
        f(ptr: &v)
        f2(v: &v)
    }

    func testImmutableValueArrayToImmutablePointer() {
        func f(ptr: UnsafePointer<Int>) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.pointee)
            XCTAssertEqual(0x2234567890ABCDEF, ptr.advanced(by: 1).pointee)
            XCTAssertEqual(0x3234567890ABCDEF, ptr.advanced(by: 2).pointee)
        }
        func f2(v: [Int]) {
            f(ptr: v)
        }
        let v: [Int] = [0x1234567890ABCDEF, 0x2234567890ABCDEF, 0x3234567890ABCDEF, ]
        f(ptr: v)
        f2(v: v)
    }

    func testImmutableStringToImmutablePointer() {
        func f(ptr: UnsafePointer<CChar>){
            XCTAssertEqual("0x1234567890ABCDEF", String(cString: ptr))
        }
        func f2(v: String) {
            f(ptr: v)
        }
        let v: String = "0x1234567890ABCDEF"
        f(ptr: v)
        f2(v: v)
    }
}

extension ImplicitConversionToPointerTests {

    func testPassMutablePointerToImmutablePointer() {
        func f2(ptr: UnsafePointer<Int>) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.pointee)
        }
        func f(ptr: UnsafeMutablePointer<Int>){
            f2(ptr: ptr)
        }
        var v: Int = 0x1234567890ABCDEF
        f(ptr: &v)
    }

}
