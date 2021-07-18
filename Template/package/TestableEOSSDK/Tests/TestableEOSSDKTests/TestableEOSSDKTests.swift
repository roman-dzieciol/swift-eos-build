import XCTest
@testable import EOSSDK


final class TestableEOSSDKTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        _ = Globals.shared.pointer(to: "123")
    }

    func testExample() throws {

        __on_EOS_EResult_ToString = { result in
            XCTAssertEqual(result, .EOS_Success)
            return Globals.shared.pointer(to: "123")
        }

        XCTAssertEqual(String(cString: EOS_EResult_ToString(.EOS_Success)), "123")
    }
}

class Globals {

    static let shared = Globals()

    var strings: [String: UnsafeMutableBufferPointer<CChar>] = [:]

    init() {}

    func pointer(to string: String) -> UnsafePointer<CChar>? {
        if let pointer = strings[string] {
            return UnsafePointer(pointer.baseAddress!)
        }


        let buffer = string.utf8CString
        let pointer = UnsafeMutableBufferPointer<CChar>.allocate(capacity: buffer.count)
        _ = pointer.initialize(from: buffer)
        strings[string] = pointer
        return UnsafePointer(pointer.baseAddress!)
    }

    func deallocate() {
        strings.forEach {
            $0.value.deallocate()
        }
        strings.removeAll()
    }
}
