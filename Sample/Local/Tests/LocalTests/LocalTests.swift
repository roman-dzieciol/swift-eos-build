import XCTest
@testable import Local
import EOSSDK

final class LocalTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Local().text, "Hello, World!")
    }
}
