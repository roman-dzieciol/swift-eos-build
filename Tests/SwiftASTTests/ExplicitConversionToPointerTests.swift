
import XCTest
@testable import SwiftAST

final class ExplicitConversionToPointerTests: XCTestCase {

    func testMutableValueToImmutablePointer() {
        func f(ptr: UnsafePointer<Int>) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.pointee)
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
        func f(ptr: UnsafeMutablePointer<Int>) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.pointee)
        }
        var v: Int = 0x1234567890ABCDEF
        withUnsafeMutablePointer(to: &v) { vPtr in
            f(ptr: vPtr)
        }
    }

    func testMutableValueArrayToImmutablePointer() {
        func f(ptr: UnsafePointer<Int>) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.pointee)
            XCTAssertEqual(0x2234567890ABCDEF, ptr.advanced(by: 1).pointee)
            XCTAssertEqual(0x3234567890ABCDEF, ptr.advanced(by: 2).pointee)
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
        func f(ptr: UnsafeMutablePointer<Int>) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.pointee)
            XCTAssertEqual(0x2234567890ABCDEF, ptr.advanced(by: 1).pointee)
            XCTAssertEqual(0x3234567890ABCDEF, ptr.advanced(by: 2).pointee)
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
        func f(ptr: UnsafePointer<Int>) {
            XCTAssertEqual(0x1234567890ABCDEF, ptr.pointee)
            XCTAssertEqual(0x2234567890ABCDEF, ptr.advanced(by: 1).pointee)
            XCTAssertEqual(0x3234567890ABCDEF, ptr.advanced(by: 2).pointee)
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
        func f(ptr: UnsafePointer<CChar>){
            XCTAssertEqual("0x1234567890ABCDEF", String(cString: ptr))
        }
        let v: String = "0x1234567890ABCDEF"
        v.withCString { vPtr in
            f(ptr: vPtr)
        }
    }
}
