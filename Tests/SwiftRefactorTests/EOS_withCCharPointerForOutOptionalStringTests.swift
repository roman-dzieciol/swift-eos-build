import XCTest
@testable import SwiftRefactor

final class EOS_withCCharPointerForOutOptionalStringTests: XCTestCase {


    // MARK: capacityZero_throwsNone_writesNone_outNil

    func test_eos_withCCharPointerForOutOptionalString_inNil_capacityZero_throwsNone_writesNone_outNil() throws {
        var outOptionalString: String? = nil
        let result: Int = eos_withCCharPointerForOutOptionalString(outOptionalString: &outOptionalString, capacity: .zero) { charPointer in
            XCTAssertNil(charPointer)
            return 42
        }
        XCTAssertEqual(outOptionalString, "")
        XCTAssertEqual(result, 42)
    }

    func test_eos_withCCharPointerForOutOptionalString_inEmpty_capacityZero_throwsNone_writesNone_outNil() throws {
        var outOptionalString: String? = ""
        let result: Int = eos_withCCharPointerForOutOptionalString(outOptionalString: &outOptionalString, capacity: .zero) { charPointer in
            XCTAssertNil(charPointer)
            return 42
        }
        XCTAssertEqual(outOptionalString, "")
        XCTAssertEqual(result, 42)
    }

    func test_eos_withCCharPointerForOutOptionalString_inSome_capacityZero_throwsNone_writesNone_outNil() throws {
        var outOptionalString: String? = "some"
        let result: Int = eos_withCCharPointerForOutOptionalString(outOptionalString: &outOptionalString, capacity: .zero) { charPointer in
            XCTAssertNil(charPointer)
            return 42
        }
        XCTAssertEqual(outOptionalString, "")
        XCTAssertEqual(result, 42)
    }


    // MARK: capacityOne_throwsNone_writesNone_outNil

    func test_eos_withCCharPointerForOutOptionalString_inNil_capacityOne_throwsNone_writesNone_outNil() throws {
        var outOptionalString: String? = nil
        let result: Int = eos_withCCharPointerForOutOptionalString(outOptionalString: &outOptionalString, capacity: 1) { charPointer in
            XCTAssertNotNil(charPointer)
            return 42
        }
        XCTAssertEqual(outOptionalString, "")
        XCTAssertEqual(result, 42)
    }

    func test_eos_withCCharPointerForOutOptionalString_inEmpty_capacityOne_throwsNone_writesNone_outNil() throws {
        var outOptionalString: String? = ""
        let result: Int = eos_withCCharPointerForOutOptionalString(outOptionalString: &outOptionalString, capacity: 1) { charPointer in
            XCTAssertNotNil(charPointer)
            return 42
        }
        XCTAssertEqual(outOptionalString, "")
        XCTAssertEqual(result, 42)
    }

    func test_eos_withCCharPointerForOutOptionalString_inSome_capacityOne_throwsNone_writesNone_outNil() throws {
        var outOptionalString: String? = "some"
        let result: Int = eos_withCCharPointerForOutOptionalString(outOptionalString: &outOptionalString, capacity: 1) { charPointer in
            XCTAssertNotNil(charPointer)
            return 42
        }
        XCTAssertEqual(outOptionalString, "")
        XCTAssertEqual(result, 42)
    }

    // MARK: capacityOne_throwsNone_writesSome_outSome

    func test_eos_withCCharPointerForOutOptionalString_inNil_capacitySome_throwsNone_writesSome_outSome() throws {
        var outOptionalString: String? = nil
        let result: Int = eos_withCCharPointerForOutOptionalString(outOptionalString: &outOptionalString, capacity: 10) { charPointer in
            XCTAssertNotNil(charPointer)
            charPointer?.assign(from: GTest.current.pointer(string: "1234567890"), count: 10)
            return 42
        }
        XCTAssertEqual(outOptionalString, "1234567890")
        XCTAssertEqual(result, 42)
    }

    func test_eos_withCCharPointerForOutOptionalString_inEmpty_capacitySome_throwsNone_writesSome_outSome() throws {
        var outOptionalString: String? = ""
        let result: Int = eos_withCCharPointerForOutOptionalString(outOptionalString: &outOptionalString, capacity: 10) { charPointer in
            XCTAssertNotNil(charPointer)
            charPointer?.assign(from: GTest.current.pointer(string: "1234567890"), count: 10)
            return 42
        }
        XCTAssertEqual(outOptionalString, "1234567890")
        XCTAssertEqual(result, 42)
    }

    func test_eos_withCCharPointerForOutOptionalString_inSome_capacitySome_throwsNone_writesSome_outSome() throws {
        var outOptionalString: String? = "some"
        let result: Int = eos_withCCharPointerForOutOptionalString(outOptionalString: &outOptionalString, capacity: 10) { charPointer in
            XCTAssertNotNil(charPointer)
            charPointer?.assign(from: GTest.current.pointer(string: "1234567890"), count: 10)
            return 42
        }
        XCTAssertEqual(outOptionalString, "1234567890")
        XCTAssertEqual(result, 42)
    }


    // MARK: capacityZero_throwsSome_writesNone_outNil

    func test_eos_withCCharPointerForOutOptionalString_inNil_capacityZero_throwsSome_writesNone_outNil() throws {
        var outOptionalString: String? = nil
        XCTAssertThrowsError(try eos_withCCharPointerForOutOptionalString(outOptionalString: &outOptionalString, capacity: .zero) { charPointer in
            XCTAssertNil(charPointer)
            throw TestError.some
        }) { error in
            guard case TestError.some = error else { return XCTFail("unexpected error: \(error)") }
        }
        XCTAssertEqual(outOptionalString, "")
    }

    func test_eos_withCCharPointerForOutOptionalString_inEmpty_capacityZero_throwsSome_writesNone_outNil() throws {
        var outOptionalString: String? = ""
        XCTAssertThrowsError(try eos_withCCharPointerForOutOptionalString(outOptionalString: &outOptionalString, capacity: .zero) { charPointer in
            XCTAssertNil(charPointer)
            throw TestError.some
        }) { error in
            guard case TestError.some = error else { return XCTFail("unexpected error: \(error)") }
        }
        XCTAssertEqual(outOptionalString, "")
    }

    func test_eos_withCCharPointerForOutOptionalString_inSome_capacityZero_throwsSome_writesNone_outNil() throws {
        var outOptionalString: String? = "some"
        XCTAssertThrowsError(try eos_withCCharPointerForOutOptionalString(outOptionalString: &outOptionalString, capacity: .zero) { charPointer in
            XCTAssertNil(charPointer)
            throw TestError.some
        }) { error in
            guard case TestError.some = error else { return XCTFail("unexpected error: \(error)") }
        }
        XCTAssertEqual(outOptionalString, "")
    }


    // MARK: capacityZero_throwsSome_writesSome_outNil

    func test_eos_withCCharPointerForOutOptionalString_inNil_capacityZero_throwsSome_writesSome_outNil() throws {
        var outOptionalString: String? = nil
        XCTAssertThrowsError(try eos_withCCharPointerForOutOptionalString(outOptionalString: &outOptionalString, capacity: .zero) { charPointer in
            XCTAssertNil(charPointer)
            charPointer?.assign(from: GTest.current.pointer(string: "1234567890"), count: 10)
            throw TestError.some
        }) { error in
            guard case TestError.some = error else { return XCTFail("unexpected error: \(error)") }
        }
        XCTAssertEqual(outOptionalString, "")
    }

    func test_eos_withCCharPointerForOutOptionalString_inEmpty_capacityZero_throwsSome_writesSome_outNil() throws {
        var outOptionalString: String? = ""
        XCTAssertThrowsError(try eos_withCCharPointerForOutOptionalString(outOptionalString: &outOptionalString, capacity: .zero) { charPointer in
            XCTAssertNil(charPointer)
            charPointer?.assign(from: GTest.current.pointer(string: "1234567890"), count: 10)
            throw TestError.some
        }) { error in
            guard case TestError.some = error else { return XCTFail("unexpected error: \(error)") }
        }
        XCTAssertEqual(outOptionalString, "")
    }

    func test_eos_withCCharPointerForOutOptionalString_inSome_capacityZero_throwsSome_writesSome_outNil() throws {
        var outOptionalString: String? = "some"
        XCTAssertThrowsError(try eos_withCCharPointerForOutOptionalString(outOptionalString: &outOptionalString, capacity: .zero) { charPointer in
            XCTAssertNil(charPointer)
            charPointer?.assign(from: GTest.current.pointer(string: "1234567890"), count: 10)
            throw TestError.some
        }) { error in
            guard case TestError.some = error else { return XCTFail("unexpected error: \(error)") }
        }
        XCTAssertEqual(outOptionalString, "")
    }
}


