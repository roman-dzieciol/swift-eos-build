import XCTest
@testable import SwiftRefactor


enum TestError: Error {
    case some
}

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

class GTest {

    static let current = GTest()

    var strings: [String: UnsafeMutableBufferPointer<CChar>] = [:]
    var deallocs: [() -> Void] = []

    init() {}

    func reset() {

        strings.forEach {
            $0.value.deallocate()
        }
        strings.removeAll()

        deallocs.forEach {
            $0()
        }
        deallocs.removeAll()
    }

    func pointer(string: String) -> UnsafePointer<CChar> {
        if let pointer = strings[string] {
            return UnsafePointer(pointer.baseAddress!)
        }

        let buffer = string.utf8CString
        let pointer = UnsafeMutableBufferPointer<CChar>.allocate(capacity: buffer.count)
        _ = pointer.initialize(from: buffer)
        strings[string] = pointer
        return UnsafePointer(pointer.baseAddress!)
    }

    func pointer<Object>(object: Object) -> UnsafeMutablePointer<Object> {
        let pointer = UnsafeMutablePointer<Object>.allocate(capacity: 1)
        pointer.initialize(to: object)
        deallocs += [{
            pointer.deinitialize(count: 1)
            pointer.deallocate()
        }]
        return pointer
    }
}
