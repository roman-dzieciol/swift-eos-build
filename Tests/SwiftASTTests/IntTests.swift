import XCTest
import CTestHelpers
@testable import SwiftAST

final class IntTests: XCTestCase {

    func testPassthroughUInt32() {
        XCTAssertEqual(UInt32(exactly: Int(exactly: UInt32(UInt32.max))!)!, UInt32.max)
        XCTAssertEqual(UInt32(exactly: Int(exactly: UInt32(UInt32.max-1))!)!, UInt32.max-1)
        XCTAssertEqual(UInt32(exactly: Int(exactly: UInt32(UInt32.min+1))!)!, UInt32.min+1)
        XCTAssertEqual(UInt32(exactly: Int(exactly: UInt32(UInt32.min))!)!, UInt32.min)
    }

    func testPassthroughInt32() {
        XCTAssertEqual(Int32(exactly: Int(exactly: Int32(Int32.max))!)!, Int32.max)
        XCTAssertEqual(Int32(exactly: Int(exactly: Int32(Int32.max-1))!)!, Int32.max-1)
        XCTAssertEqual(Int32(exactly: Int(exactly: Int32(1))!)!, 1)
        XCTAssertEqual(Int32(exactly: Int(exactly: Int32(0))!)!, 0)
        XCTAssertEqual(Int32(exactly: Int(exactly: Int32(-1))!)!, -1)
        XCTAssertEqual(Int32(exactly: Int(exactly: Int32(Int32.min+1))!)!, Int32.min+1)
        XCTAssertEqual(Int32(exactly: Int(exactly: Int32(Int32.min))!)!, Int32.min)
    }

    func testPassthroughInt64() {
        XCTAssertEqual(Int64(exactly: Int(exactly: Int64(Int64.max))!)!, Int64.max)
        XCTAssertEqual(Int64(exactly: Int(exactly: Int64(Int64.max-1))!)!, Int64.max-1)
        XCTAssertEqual(Int64(exactly: Int(exactly: Int64(1))!)!, 1)
        XCTAssertEqual(Int64(exactly: Int(exactly: Int64(0))!)!, 0)
        XCTAssertEqual(Int64(exactly: Int(exactly: Int64(-1))!)!, -1)
        XCTAssertEqual(Int64(exactly: Int(exactly: Int64(Int64.min+1))!)!, Int64.min+1)
        XCTAssertEqual(Int64(exactly: Int(exactly: Int64(Int64.min))!)!, Int64.min)
    }

    func testPassthroughUInt64() {
        XCTAssertEqual(UInt64(bitPattern: Int64(exactly: Int(bitPattern: UInt(exactly: UInt64(UInt64.max))!))!), UInt64.max)
        XCTAssertEqual(UInt64(bitPattern: Int64(exactly: Int(bitPattern: UInt(exactly: UInt64(UInt64.max-1))!))!), UInt64.max-1)
        XCTAssertEqual(UInt64(bitPattern: Int64(exactly: Int(bitPattern: UInt(exactly: UInt64(UInt64.min+1))!))!), UInt64.min+1)
        XCTAssertEqual(UInt64(bitPattern: Int64(exactly: Int(bitPattern: UInt(exactly: UInt64(UInt64.min))!))!), UInt64.min)
    }

    func testIntToUInt64() {
        XCTAssertEqual(UInt64(bitPattern: Int64(exactly: Int(Int.max))!), 0x7FFFFFFFFFFFFFFF)
        XCTAssertEqual(UInt64(bitPattern: Int64(exactly: Int(Int.max-1))!), 0x7FFFFFFFFFFFFFFE)
        XCTAssertEqual(UInt64(bitPattern: Int64(exactly: Int(1))!), 0x1)
        XCTAssertEqual(UInt64(bitPattern: Int64(exactly: Int(0))!), 0x0)
        XCTAssertEqual(UInt64(bitPattern: Int64(exactly: Int(-1))!), 0xFFFFFFFFFFFFFFFF)
    }
}
