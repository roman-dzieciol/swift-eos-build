
import Foundation
import SwiftAST
import os.log



class SwiftyArrayLinker {

    let prefixesToAdd = ["", "In"]
    let bufferSuffixesToRemove = ["", "Buffer", "s", "Ids"]
    let countPluralSuffixesToAdd = ["", "s"]
    let countSuffixesToAdd = ["Count", "Length", "LengthBytes", "SizeBytes"]
    let additionalSuffixesToAdd = ["", "_DEPRECATED"]

    let decl: SwiftAST
    let decls: [SwiftAST]

    init(in decl: SwiftAST) throws {

        self.decl = decl

        if let function = decl.canonical as? SwiftFunction {
            self.decls = function.inner
        }
        else if let object = decl.canonical as? SwiftObject {
            self.decls = object.inner
        }
        else {
            self.decls = []
        }
    }

    func overridenName(for name: String) -> String? {
        if name == "ByteArray", decl.name.hasSuffix("EOS_ByteArray_ToString") {
                return "Length"
        }

        if name == "OutData", decl.name.hasSuffix("EOS_P2P_ReceivePacket") {
                return "OutBytesWritten"
        }

        if name == "TargetUserIpAddresses", decl.name.hasSuffix("EOS_RTCAdmin_QueryJoinRoomTokenOptions") {
            return "TargetUserIdsCount"
        }

        return nil
    }

    func link() throws {

        guard !self.decls.isEmpty else { return }

        var maybeArrayBufferDecls = decls
            .compactMap { $0 as? SwiftVarDecl }
            .filter { isMaybeArrayBuffer(varDecl: $0) }
            .filter { isMaybeArrayBuffer(name: $0.name) }

        link(maybeArrayBufferDecls: &maybeArrayBufferDecls, in: decl)

        if !maybeArrayBufferDecls.isEmpty {
            retryLinkWithOptions(maybeArrayBufferDecls: &maybeArrayBufferDecls)
        }
    }

    func link(maybeArrayBufferDecls: inout [SwiftVarDecl], in decl: SwiftAST, invocationDecl: SwiftVarDecl? = nil) {

        let maybeArrayCountDecls = decl
            .inner
            .compactMap { $0 as? SwiftVarDecl }
            .filter { isMaybeArrayCount(varDecl: $0) }
            .filter { isMaybeArrayCount(name: $0.name) }

        var maybeArrayCountsByName = [String: SwiftVarDecl](uniqueKeysWithValues: maybeArrayCountDecls.map { ($0.name, $0) })

        let arrayDecls = maybeArrayBufferDecls
        arrayDecls.forEach { maybeArrayBuffer in
            if let arrayCount = findArrayCount(for: maybeArrayBuffer, in: maybeArrayCountsByName) {
                link(array: maybeArrayBuffer, num: arrayCount)
                if let invocationDecl = invocationDecl {
                    arrayCount.link(.invocation, ref: invocationDecl)
                    arrayCount.sdk!.link(.invocation, ref: invocationDecl.sdk!)
                }
                maybeArrayCountsByName.removeValue(forKey: arrayCount.name)
                maybeArrayBufferDecls.removeAll { $0 === maybeArrayBuffer }
            }
        }
    }

    /// WORKAROUND: array num in nested options, buffer in function parms
    func retryLinkWithOptions(maybeArrayBufferDecls: inout [SwiftVarDecl]) {
        if decl.canonical as? SwiftFunction != nil,
           let optionsParm = decl.inner
            .compactMap({ $0 as? SwiftVarDecl })
            .first(where: { $0.name == "Options" })?
            .canonical as? SwiftFunctionParm,
           let optionsDecl = optionsParm.type.canonical.asPointer?.pointeeType.asDeclRef?.decl.canonical {
            link(maybeArrayBufferDecls: &maybeArrayBufferDecls, in: optionsDecl, invocationDecl: optionsParm)
        }
    }

    func findArrayCount(
        for arrayBuffer: SwiftVarDecl,
        in arrayCounts: [String: SwiftVarDecl]
    ) -> SwiftVarDecl? {

        let name = arrayBuffer.name

        if let overridenName = overridenName(for: name) {
            guard let arrayCount = decl.inner.first(where: { $0.name == overridenName }) as? SwiftVarDecl else {
                fatalError("var with overriden name not found: \(overridenName) for: \(arrayBuffer.name) in: \(decl.name)")
            }
            return arrayCount
        }

        var names: Set<String> = []

        for prefixToAdd in prefixesToAdd {
            for additionalSuffix in additionalSuffixesToAdd {
                for countPluralSuffix in countPluralSuffixesToAdd {
                    for countSuffix in countSuffixesToAdd {
                        for bufferSuffix in bufferSuffixesToRemove {
                            let nameVariation = prefixToAdd + String(name.dropSuffix(additionalSuffix).dropSuffix(bufferSuffix)) + countPluralSuffix + countSuffix + additionalSuffix
                            names.insert(nameVariation)
                        }
                    }
                }
            }
        }

        for nameVariation in names {
            if let arrayCount = arrayCounts[nameVariation] {
                return arrayCount
            }
        }

        return nil
    }


    func isMaybeArrayBuffer(varDecl: SwiftVarDecl) -> Bool {

        let canonical = (varDecl.canonical as? SwiftVarDecl)?.type.canonical

        if canonical?.asArray != nil {
            return true
        }

        if canonical?.asPointer != nil {
            return true
        }

        return false
    }

    func isMaybeArrayCount(varDecl: SwiftVarDecl) -> Bool {
        let canonical = (varDecl.canonical as? SwiftVarDecl)?.type.canonical
        if canonical?.asBuiltin?.isInt == true {
            return true
        }

        if let pointer = canonical?.asPointer,
//           pointer.isMutable,
           pointer.pointeeType.asBuiltin?.isInt == true {
            return true
        }
        return false
    }

    func isMaybeArrayBuffer(name: String) -> Bool {
        for additionalSuffix in additionalSuffixesToAdd {
            for countSuffix in countSuffixesToAdd where !countSuffix.isEmpty {
                if String(name.dropSuffix(additionalSuffix)).hasSuffix(countSuffix) {
                    return false
                }
            }
        }
        return true
    }

    func isMaybeArrayCount(name: String) -> Bool {
        for additionalSuffix in additionalSuffixesToAdd {
            for countSuffix in countSuffixesToAdd where !countSuffix.isEmpty {
                if String(name.dropSuffix(additionalSuffix)).hasSuffix(countSuffix) {
                    return true
                }
            }
        }
        return false
    }


    func link(array: SwiftVarDecl, num: SwiftVarDecl) {
        array.link(.arrayLength, ref: num)
        num.link(.arrayBuffer, ref: array)

        array.sdk!.link(.arrayLength, ref: num.sdk!)
        num.sdk!.link(.arrayBuffer, ref: array.sdk!)

        array.otherAST = num
        num.otherAST = array
        array.add(comment: "- array num: \(num.name)")
        num.add(comment: "- array buffer: \(array.name)")
        os_log("array: %{public}s.%{public}s[%{public}s]", decl.name, array.name, num.name)
    }

}

