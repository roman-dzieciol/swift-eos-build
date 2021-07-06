
import XCTest
import CTestHelpers
@testable import SwiftAST

final class CFuncPointerTests: XCTestCase {

    func testPassNil() {
        XCTAssertNil(CTestHelpers_FPTR_Pass_IntFromVoid(nil))
        XCTAssertNil(CTestHelpers_FPTR_Pass_IntFromValueStruct(nil))
    }

    func testPassVoid() {
        let fptr = CTestHelpers_FPTR_Pass_IntFromVoid {
            return 0x1234567890ABCDEF
        }
        XCTAssertEqual(fptr?(), 0x1234567890ABCDEF)
    }

    func testPassNilValueStruct() {
        let fptr = CTestHelpers_FPTR_Pass_IntFromValueStruct { arg in
            XCTAssertNil(arg)
            return UInt64.max
        }
        XCTAssertEqual(fptr?(nil), UInt64.max)
    }

    func testPassValueStruct() {
        var str = CTestHelpers_ValueStruct(value: 0x1234567890ABCDEF)
        let fptr = CTestHelpers_FPTR_Pass_IntFromValueStruct { arg in
            return arg!.pointee.value - 1
        }
        XCTAssertEqual(fptr?(&str), 0x1234567890ABCDEE)
    }

    func testPassGlobalCallback() {
        let fptr = CTestHelpers_FPTR_Pass_IntFromVoid(CCallbackHandler_IntFromVoid)
        XCTAssertEqual(fptr?(), 0x1234567890ABCDEF)
    }

    func testCallPtrFromOptions() {

        func swiftApi(completion: @escaping (TestCallbackInfo) -> Void) {
            let retainedSwiftCallback = RetainableCallbackObject(completion).retainedClientDataPtr()
            var cOptions = CTestHelpers_Options(ClientData: retainedSwiftCallback)
            CTestHelpers_FPTR_Call_WithOptions(
                &cOptions,
                CCallbackHandler_CallSwiftCallbackFromClientData)
        }

        var result: String = ""
        swiftApi(completion: { swiftCallbackInfo in
            result = swiftCallbackInfo.swiftString
        })
        XCTAssertEqual(result, "SUCCESS")
    }
}

private struct TestCallbackInfo {
    let swiftString: String

    init(cCallbackInfo: CTestHelpers_CallbackInfo) {
        swiftString = String(cString: cCallbackInfo.cString)
    }
}

private class RetainableCallbackObject<SwiftCallbackInfo> {

    let completion: (SwiftCallbackInfo) -> Void

    init(_ completion: @escaping (SwiftCallbackInfo) -> Void) {
        self.completion = completion
    }

    func retainedClientDataPtr() -> UnsafeMutableRawPointer {
        UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
    }

    static func from(clientDataPtr: UnsafeMutableRawPointer!) -> Self {
        Unmanaged<Self>.fromOpaque(clientDataPtr).takeRetainedValue()
    }

    static func from(clientDataPtr: UnsafeMutableRawPointer!, swiftCallbackInfo: () -> SwiftCallbackInfo) {
        from(clientDataPtr: clientDataPtr).completion(swiftCallbackInfo())
    }
}

private func CCallbackHandler_CallSwiftCallbackFromClientData(_ cCallbackInfoPtr: UnsafeMutablePointer<CTestHelpers_CallbackInfo>?) {
    guard let cCallbackInfoPtr = cCallbackInfoPtr else { fatalError() }
    guard let clientDataPtr: UnsafeMutableRawPointer = cCallbackInfoPtr.pointee.ClientData else { fatalError() }
    RetainableCallbackObject.from(clientDataPtr: clientDataPtr) {
        return TestCallbackInfo(cCallbackInfo: cCallbackInfoPtr.pointee)
    }
}

private func CCallbackHandler_IntFromVoid() -> UInt64 {
    return 0x1234567890ABCDEF
}
