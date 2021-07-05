import XCTest
@testable import SwiftAST


final class ImplicitConversionToVoidPointerTests: XCTestCase {

    func testMutableValueToImmutablePointer() {
        func f(ptr: UnsafeRawPointer) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).pointee)
        }
        func f2(v: inout Int) {
            f(ptr: &v)
        }
        var v: Int = 0x1234567890ABCDEF
        f(ptr: &v)
        f2(v: &v)
    }

    func testMutableValueToMutablePointer() {
        func f(ptr: UnsafeMutableRawPointer) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).pointee)
        }
        func f2(v: inout Int) {
            f(ptr: &v)
        }
        var v: Int = 0x1234567890ABCDEF
        f(ptr: &v)
        f2(v: &v)
    }

    func testMutableValueArrayToImmutablePointer() {
        func f(ptr: UnsafeRawPointer) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).pointee)
            XCTAssertEqual(0x2234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).advanced(by: 1).pointee)
            XCTAssertEqual(0x3234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).advanced(by: 2).pointee)
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
        func f(ptr: UnsafeMutableRawPointer) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).pointee)
            XCTAssertEqual(0x2234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).advanced(by: 1).pointee)
            XCTAssertEqual(0x3234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).advanced(by: 2).pointee)
        }
        func f2(v: inout [Int]) {
            f(ptr: &v)
        }
        var v: [Int] = [0x1234567890ABCDEF, 0x2234567890ABCDEF, 0x3234567890ABCDEF, ]
        f(ptr: &v)
        f2(v: &v)
    }

    func testImmutableValueArrayToImmutablePointer() {
        func f(ptr: UnsafeRawPointer) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).pointee)
            XCTAssertEqual(0x2234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).advanced(by: 1).pointee)
            XCTAssertEqual(0x3234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).advanced(by: 2).pointee)
        }
        func f2(v: [Int]) {
            f(ptr: v)
        }
        let v: [Int] = [0x1234567890ABCDEF, 0x2234567890ABCDEF, 0x3234567890ABCDEF, ]
        f(ptr: v)
        f2(v: v)
    }

    func testImmutableStringToImmutablePointer() {
        func f(ptr: UnsafeRawPointer){
            XCTAssertEqual("0x1234567890ABCDEF", String(cString: ptr.assumingMemoryBound(to: CChar.self)))
        }
        func f2(v: String) {
            f(ptr: v)
        }
        let v: String = "0x1234567890ABCDEF"
        f(ptr: v)
        f2(v: v)
    }
}

extension ImplicitConversionToVoidPointerTests {

    func testPassMutablePointerToImmutablePointer() {
        func f2(ptr: UnsafeRawPointer) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).pointee)
        }
        func f(ptr: UnsafeMutableRawPointer){
            f2(ptr: ptr)
        }
        var v: Int = 0x1234567890ABCDEF
        f(ptr: &v)
    }

}

