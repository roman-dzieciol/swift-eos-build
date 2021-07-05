
import XCTest
@testable import SwiftAST

final class ExplicitConversionToVoidPointerTests: XCTestCase {

    func testMutableValueToImmutablePointer() {
        func f(ptr: UnsafeRawPointer) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.load(as: Int.self))
        }
        var v: Int = 0x1234567890ABCDEF
        withUnsafePointer(to: v) { vPtr in
            f(ptr: vPtr)
        }
        withUnsafePointer(to: &v) { vPtr in
            f(ptr: vPtr)
        }
    }

    func testMutableValueToMutablePointer() {
        func f(ptr: UnsafeMutableRawPointer) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.load(as: Int.self))
        }
        var v: Int = 0x1234567890ABCDEF
        withUnsafeMutablePointer(to: &v) { vPtr in
            f(ptr: vPtr)
        }
    }

    func testMutableValueArrayToImmutablePointer() {
        func f(ptr: UnsafeRawPointer) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).pointee)
            XCTAssertEqual(0x2234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).advanced(by: 1).pointee)
            XCTAssertEqual(0x3234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).advanced(by: 2).pointee)
        }
        var v: [Int] = [0x1234567890ABCDEF, 0x2234567890ABCDEF, 0x3234567890ABCDEF, ]
        v.withUnsafeBufferPointer { vPtr in
            f(ptr: vPtr.baseAddress!)
        }
        v.withUnsafeMutableBufferPointer { vPtr in
            f(ptr: vPtr.baseAddress!)
        }
        v.withContiguousStorageIfAvailable { vPtr in
            f(ptr: vPtr.baseAddress!)
        }
        v.withContiguousMutableStorageIfAvailable { vPtr in
            f(ptr: vPtr.baseAddress!)
        }
    }

    func testMutableValueArrayToMutablePointer() {
        func f(ptr: UnsafeMutableRawPointer) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).pointee)
            XCTAssertEqual(0x2234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).advanced(by: 1).pointee)
            XCTAssertEqual(0x3234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).advanced(by: 2).pointee)
        }
        var v: [Int] = [0x1234567890ABCDEF, 0x2234567890ABCDEF, 0x3234567890ABCDEF, ]
        v.withUnsafeMutableBufferPointer { vPtr in
            f(ptr: vPtr.baseAddress!)
        }
        v.withContiguousMutableStorageIfAvailable { vPtr in
            f(ptr: vPtr.baseAddress!)
        }
    }

    func testImmutableValueArrayToImmutablePointer() {
        func f(ptr: UnsafeRawPointer) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).pointee)
            XCTAssertEqual(0x2234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).advanced(by: 1).pointee)
            XCTAssertEqual(0x3234567890ABCDEF, ptr.assumingMemoryBound(to: Int.self).advanced(by: 2).pointee)
        }
        let v: [Int] = [0x1234567890ABCDEF, 0x2234567890ABCDEF, 0x3234567890ABCDEF, ]
        v.withUnsafeBufferPointer { vPtr in
            f(ptr: vPtr.baseAddress!)
        }
        v.withContiguousStorageIfAvailable { vPtr in
            f(ptr: vPtr.baseAddress!)
        }
    }

    func testImmutableStringToImmutablePointer() {
        func f(ptr: UnsafeRawPointer){
            XCTAssertEqual("0x1234567890ABCDEF", String(cString: ptr.assumingMemoryBound(to: CChar.self)))
        }
        let v: String = "0x1234567890ABCDEF"
        v.withCString { vPtr in
            f(ptr: vPtr)
        }
    }
}
