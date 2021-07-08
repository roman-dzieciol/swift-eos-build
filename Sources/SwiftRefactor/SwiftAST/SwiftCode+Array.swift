
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


class SwiftAddPairsPassVisitor: SwiftVisitor {

    let postfixToDrop: String

    init(postfixToDrop: String = "") {
        self.postfixToDrop = postfixToDrop
    }

    static let suffixes = ["Count", "Buffer", "Length", "LengthBytes", "SizeBytes", "sCount", "sBuffer", "sLength"]

    override func visit(type: SwiftType) throws -> SwiftType {
        return type
    }

    override func visit(ast: SwiftAST) throws {

        if let object = ast as? SwiftObject {
            let numericDecls = object.members.filter { isRelevantNumeric(type: $0.type) && isRelevant(name: $0.name) }
            object.members.forEach { decl in
                guard decl.otherAST == nil else { return }
                guard let arrayType = arrayType(for: decl.type) else { return }
                if let otherDecl = otherDecl(container: object, member: decl, otherDecls: numericDecls) {
                    link(array: decl, num: otherDecl)
                    decl.type = arrayType
                    print(ast.name + " \(decl.name) <> \(otherDecl.name)")
                }
            }
            return
        }

        else if let function = ast as? SwiftFunction {
            let numericDecls = function.parms.filter { isRelevantNumeric(type: $0.type) && isRelevant(name: $0.name) }
            function.parms.forEach { decl in
                guard decl.otherAST == nil else { return }
                guard let arrayType = arrayType(for: decl.type) else { return }

                if let otherDecl = otherDecl(container: function, member: decl, otherDecls: numericDecls) {
                    link(array: decl, num: otherDecl)
                    decl.type = arrayType
                    print(ast.name + " \(decl.name) <> \(otherDecl.name)")
                }
            }
            return
        }

        try super.visit(ast: ast)
    }

    func link(array: SwiftAST, num: SwiftAST) {
        array.link(.arrayLength, ref: num)
        num.link(.arrayBuffer, ref: array)
        array.otherAST = num
        num.otherAST = array
        array.add(comment: "- array num: \(num.name)")
        num.add(comment: "- array buffer: \(array.name)")
    }

    func edgeCase(container: SwiftAST, member: SwiftAST, otherDecls: [SwiftAST]) -> SwiftAST? {
        if container.name.contains("EOS_ByteArray_ToString"), member.name == "ByteArray" {
            return otherDecls.first(where: { $0.name == "Length" })
        }
        return nil
    }

    func otherDecl(container: SwiftAST, member: SwiftAST, otherDecls: [SwiftAST]) -> SwiftAST? {
        if let edgeCase = edgeCase(container: container, member: member, otherDecls: otherDecls) {
            return edgeCase
        }
        let suffixesToDrop = ["", "s", "Ids"]
        let memberName = String(member.name.dropSuffix(postfixToDrop))
        for suffixToDrop in suffixesToDrop {
            let names = Set(Self.nameCombinations(name: memberName, suffixesToAdd: Self.suffixes, suffixesToDrop: [suffixToDrop])
                                .map { $0 + postfixToDrop })
            if let ast = otherDecls.first(where: { names.contains($0.name) }) {
                return ast
            }
        }
        return nil
    }

    func arrayType(for origType: SwiftType) -> SwiftType? {
        let type = origType.canonical
        if let arrayType = type.asArray {
            return arrayType
        }

        if let pointerType = type.asPointer {
            if let builtinType = pointerType.pointeeType.asBuiltin {
                if builtinType.isVoid {
                    if pointerType.isMutable {
                        return SwiftArrayType(elementType: SwiftBuiltinType(name: "UInt8", qual: .none), qual: pointerType.qual)
                        //                        return SwiftBuiltinType(name: "Data", qual: pointerType.qual)
                    }
                }
                else {
                    return SwiftArrayType(elementType: builtinType, qual: pointerType.qual)
                }
            }
            else if let declType = pointerType.pointeeType.asDeclRef {
                return SwiftArrayType(elementType: declType, qual: pointerType.qual)
            }

            //            else if let outerType = origType.outer(type: pointerType.pointeeType), outerType != pointerType {
            //                return SwiftArrayType(elementType: outerType, qual: pointerType.qual)
            //
            //            }


            //            return SwiftArrayType(elementType: pointerType.pointeeType.copy{$0.with(isOptional: false)}, qual: pointerType.qual)
            //            else if let opaqueType = pointerType.pointeeType.asOpaque {
            //                if let opaqueOuterType = origType.outer(type: opaqueType)?.asDeclRef,
            //                   opaqueOuterType.decl is SwiftTypealias {
            //                    return SwiftArrayType(elementType: opaqueOuterType, qual: pointerType.qual)
            //                } else {
            //                    print("")
            //                }
            //            }
        }
        return nil
    }

    func isRelevant(name: String) -> Bool {
        let name = name.dropSuffix(postfixToDrop)
        return Self.suffixes.contains(where: { name.hasSuffix($0) })
    }

    func isRelevantNumeric(type: SwiftType) -> Bool {
        if let builtinType = type as? SwiftBuiltinType {
            return builtinType.isNumeric == true && type.qual == .none
        } else if let pointerType = type as? SwiftPointerType,
                  let builtinType = pointerType.pointeeType as? SwiftBuiltinType {
            return isRelevantNumeric(type: builtinType)
        }
        return false
    }

    static func nameCombinations(name: String, suffixesToAdd: [String], suffixesToDrop: [String]) -> [String] {
        var result: [String] = []

        var baseNames: [String] = [name]

        baseNames += suffixesToDrop
            .filter { name.hasSuffix($0) }
            .map { String(name.dropSuffix($0)) }

        baseNames.forEach { baseName in
            suffixesToAdd.forEach {
                result.append(baseName + $0)
            }
        }

        return result
    }
}


