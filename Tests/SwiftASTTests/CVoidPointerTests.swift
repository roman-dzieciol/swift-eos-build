
import XCTest
import CTestHelpers
@testable import SwiftAST


//CTestHelpers_IntPtr(
//    ConstIntPtrConstPtrConst: <#T##UnsafePointer<UnsafePointer<Int32>?>!#>,
//    ConstIntPtrPtrConst: <#T##UnsafeMutablePointer<UnsafePointer<Int32>?>!#>,
//    ConstIntPtrConst: <#T##UnsafePointer<Int32>!#>,
//    ConstIntPtrPtr: <#T##UnsafeMutablePointer<UnsafePointer<Int32>?>!#>,
//    ConstIntPtr: <#T##UnsafePointer<Int32>!#>,
//    IntPtrPtr: <#T##UnsafeMutablePointer<UnsafeMutablePointer<Int32>?>!#>,
//    IntPtr: <#T##UnsafeMutablePointer<Int32>!#>)

final class CVoidPointerTests: XCTestCase {

    func testNilUnsafeMutableRawPointer() {
        XCTAssertNil(CTestHelpers_VoidPointerValue(0))
        XCTAssertNil(CTestHelpers_VoidPointer(nil))
    }

    func testNonNilUnsafeMutableRawPointer() {
        var v: Int = 0x1234567890ABCDEF
        let cPtr: UnsafeMutableRawPointer? = CTestHelpers_VoidPointer(&v)
        XCTAssertEqual(cPtr?.assumingMemoryBound(to: Int.self).pointee, 0x1234567890ABCDEF)
    }

    func testNilUnsafeRawPointer() {
        XCTAssertNil(CTestHelpers_ConstVoidPointerValue(0))
        XCTAssertNil(CTestHelpers_ConstVoidPointer(nil))
    }

    func testNonNilUnsafeRawPointer() {
        var v: Int = 0x1234567890ABCDEF
        let cPtr: UnsafeRawPointer? = CTestHelpers_ConstVoidPointer(&v)
        XCTAssertEqual(cPtr?.assumingMemoryBound(to: Int.self).pointee, 0x1234567890ABCDEF)
    }

    func testNilConstVoidConstPointer() {
        XCTAssertNil(CTestHelpers_ConstVoidConstPointerValue(0))
        XCTAssertNil(CTestHelpers_ConstVoidConstPointer(nil))
    }

    func testNonNilConstVoidConstPointer() {
        var v: Int = 0x1234567890ABCDEF
        let cPtr: UnsafeRawPointer? = CTestHelpers_ConstVoidConstPointer(&v)
        XCTAssertEqual(cPtr?.assumingMemoryBound(to: Int.self).pointee, 0x1234567890ABCDEF)
    }

    func testNilVoidConstPointer() {
        XCTAssertNil(CTestHelpers_VoidConstPointerValue(0))
        XCTAssertNil(CTestHelpers_VoidConstPointer(nil))
    }

    func testNonNilVoidConstPointer() {
        var v: Int = 0x1234567890ABCDEF
        let cPtr: UnsafeMutableRawPointer? = CTestHelpers_VoidConstPointer(&v)
        XCTAssertEqual(cPtr?.assumingMemoryBound(to: Int.self).pointee, 0x1234567890ABCDEF)
    }
}
