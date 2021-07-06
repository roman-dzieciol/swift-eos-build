
import XCTest
import CTestHelpers
@testable import SwiftAST

final class CIntPointerTests: XCTestCase {

    func testNilUnsafeMutableRawPointer() {
        XCTAssertNil(CTestHelpers_IntPointerValue(0))
        XCTAssertNil(CTestHelpers_IntPointer(nil))
    }

    func testNonNilUnsafeMutableRawPointer() {
        var v: UInt64 = 0x1234567890ABCDEF
        let cPtr: UnsafeMutablePointer<UInt64>? = CTestHelpers_IntPointer(&v)
        XCTAssertEqual(cPtr?.pointee, 0x1234567890ABCDEF)
    }

    func testNilUnsafeRawPointer() {
        XCTAssertNil(CTestHelpers_ConstIntPointerValue(0))
        XCTAssertNil(CTestHelpers_ConstIntPointer(nil))
    }

    func testNonNilUnsafeRawPointer() {
        var v: UInt64 = 0x1234567890ABCDEF
        let cPtr: UnsafePointer<UInt64>? = CTestHelpers_ConstIntPointer(&v)
        XCTAssertEqual(cPtr?.pointee, 0x1234567890ABCDEF)
    }

    func testNilConstIntConstPointer() {
        XCTAssertNil(CTestHelpers_ConstIntConstPointerValue(0))
        XCTAssertNil(CTestHelpers_ConstIntConstPointer(nil))
    }

    func testNonNilConstIntConstPointer() {
        var v: UInt64 = 0x1234567890ABCDEF
        let cPtr: UnsafePointer<UInt64>? = CTestHelpers_ConstIntConstPointer(&v)
        XCTAssertEqual(cPtr?.pointee, 0x1234567890ABCDEF)
    }

    func testNilIntConstPointer() {
        XCTAssertNil(CTestHelpers_IntConstPointerValue(0))
        XCTAssertNil(CTestHelpers_IntConstPointer(nil))
    }

    func testNonNilIntConstPointer() {
        var v: UInt64 = 0x1234567890ABCDEF
        let cPtr: UnsafeMutablePointer<UInt64>? = CTestHelpers_IntConstPointer(&v)
        XCTAssertEqual(cPtr?.pointee, 0x1234567890ABCDEF)
    }
}
