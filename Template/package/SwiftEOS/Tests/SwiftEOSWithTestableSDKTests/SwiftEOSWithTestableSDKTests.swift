
import Foundation
import XCTest
import EOSSDK
@testable import SwiftEOSWithTestableSDK


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

final class SwiftEOSWithTestableSDKTests: XCTestCase {
    func testExample() throws {

        __on_EOS_EResult_ToString = { result in
            XCTAssertEqual(result, .EOS_Success)
            return Globals.shared.pointer(to: "123")
        }

        XCTAssertEqual(SwiftEOS_EResult_ToString(Result: .EOS_Success), "123")
    }
}
