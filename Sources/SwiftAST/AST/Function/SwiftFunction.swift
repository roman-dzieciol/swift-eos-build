
import Foundation
import SwiftEOSBuildCore

public class SwiftFunction: SwiftDecl {

    public var returnType: SwiftType
    public var isThrowing: Bool
    public var isRethrowing: Bool
    public var isAsync: Bool
    public var isOptional: Bool
    public var code: SwiftExpr?
    public var genericTypes: [String]

    public var parms: [SwiftFunctionParm] {
        inner.compactMap { $0 as? SwiftFunctionParm }
    }

    public convenience init(name: String, isAsync: Bool = false, isOptional: Bool = false, isThrowing: Bool = false, returnType: SwiftType, inner: [SwiftAST] = [], comment: SwiftComment? = nil, code: @escaping (SwiftOutputStream) -> Void) {
        self.init(name: name, isAsync: isAsync, isOptional: isOptional, isThrowing: isThrowing, returnType: returnType, inner: inner, comment: comment, code: SwiftTempExpr(output: code))
    }

    public init(name: String, isAsync: Bool = false, isOptional: Bool = false, isThrowing: Bool = false, returnType: SwiftType, inner: [SwiftAST] = [], comment: SwiftComment? = nil, code: SwiftExpr? = nil) {
        self.returnType = returnType
        self.isThrowing = isThrowing
        self.isRethrowing = false
        self.isAsync = isAsync
        self.isOptional = isOptional
        self.code = code
        self.genericTypes = []
        super.init(name: name, inner: inner, comment: comment)
    }

    public override func handle(visitor: SwiftVisitor) throws {
        try visitor.visitReplacing(type: &returnType)
        try super.handle(visitor: visitor)
    }

    public override func copy() -> SwiftFunction {
        let copy = SwiftFunction(name: name, isAsync: isAsync, isOptional: isOptional, isThrowing: isThrowing, returnType: returnType, inner: inner.map { $0.copy() }, comment: comment?.copy(), code: code)
        linkCopy(from: self, to: copy)
        return copy
    }

    public func funcType(qual: SwiftQual) -> SwiftFunctionType {
        SwiftFunctionType(paramTypes: parms.map { $0.parmType() },
                          returnType: returnType,
                          qual: qual)
    }

    public override func write(to swift: SwiftOutputStream) {

        swift.write(comment)

        guard name != "deinit" else {
            swift.write(name: name)
            swift.write(nested: "{", "}") {
                swift.write(code)
            }
            return
        }

        swift.write(name: access)
        swift.write(name: attributes.joined(separator: " "))
        if name == "init" {
            swift.write(name: "init")
            if isOptional {
                swift.write(token: "?")
            }
        } else {
            swift.write(name: "func")
            swift.write(name: name)
        }
        if !genericTypes.isEmpty {
            swift.write(nested: "<", ">") {
                swift.write(genericTypes, separated: ",")
            }
        }
        swift.write(nested: "(", ")") {
            swift.write(parms, separated: ",")
        }
        if isAsync {
            swift.write(name: "async")
        }
        if isThrowing {
            swift.write(name: "throws")
        }
        if isRethrowing {
            swift.write(name: "rethrows")
        }
        if returnType.asBuiltin?.isVoid != true {
            swift.write(token: "->")
            swift.write(returnType)
        }
        swift.write(nested: "{", "}") {
            swift.write(code)
        }
    }

    public func add(parm: SwiftFunctionParm) {
        inner.append(parm)
    }

    public func replace(parm: SwiftFunctionParm, with parms: [SwiftFunctionParm]) {

        // Replace parm with specified parms
        guard let parmIndex = inner.firstIndex(where: { $0 === parm }) else { fatalError() }
        inner.replaceElement(at: parmIndex, with: parms)

        // Replace parm comment with specified parm comments
        let parmsComments = parms.map { param -> SwiftCommentParam in
            let paramComment = SwiftCommentParam(
                name: param.name,
                comments: (param.comment?.comments ?? [SwiftCommentParagraph(comments: [" "])])
            )
            paramComment.link(param: param)
            return paramComment
        }

        if let commentIndex = comment?.inner.firstIndex(where: { ($0 as? SwiftCommentParam)?.name == parm.name }) {
            comment?.inner.replaceElement(at: commentIndex, with: parmsComments)
        } else {
            comment?.inner.append(contentsOf: parmsComments)
        }
    }

}
