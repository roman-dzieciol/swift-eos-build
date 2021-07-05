import XCTest
@testable import SwiftRefactor

final class SwiftRefactorTests: XCTestCase {

    func testNilInOut() throws {

        func f(v: inout Int?) {
            v = (v ?? 0) + 1
        }

        var i: Int? = 10
        XCTAssertEqual(i, 10)
        f(v: &i)
        XCTAssertEqual(i, 11)
        i = nil
        f(v: &i)
        XCTAssertEqual(i, 1)
    }
}
