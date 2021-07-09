
import Foundation
import SwiftAST
import os.log

public class SwiftReleaseFuncsPass: SwiftRefactorPass {

    public override func refactor(module: SwiftModule) throws {

        let releaseFuncs = module.inner
            .compactMap { $0 as? SwiftFunction }
            .filter { $0.name.hasSuffix("_Release") }
            .filter { $0.sdk?.name.hasSuffix("EOS_Leaderboards_LeaderboardDefinition_Release") != true }

//        let releaseFuncsByTypeName = [String: SwiftFunction]
//            .init(releaseFuncs.map { (canonicalNameFor($0), $0) }) { lhs, rhs in
//                fatalError()
//            }


        releaseFuncs.forEach {
            linkStructNameFor($0)
            linkCanonicalNameFor($0)
        }


//        try SwiftReleaseFuncsPassVisitor().visit(ast: module)
    }
}

func link(decl: SwiftAST, toReleaseFunc: SwiftFunction) {
    decl.swifty?.add(comment: "")
    decl.swifty?.add(comment: " - see: release func: \(toReleaseFunc.name)")
//    decl.swifty?.link(.releaseFunc, ref: toReleaseFunc)
    decl.link(.releaseFunc, ref: toReleaseFunc)
}

func linkStructNameFor(_ releaseFunction: SwiftFunction) {

    let type = releaseFunction.parms[0].type

    if let decl = type.asDeclRef?.decl {
        link(decl: decl, toReleaseFunc: releaseFunction)
        return
    }

    if let ptrType = type.asPointer, let decl = ptrType.pointeeType.asDeclRef?.decl {
        link(decl: decl, toReleaseFunc: releaseFunction)
        return
    }
}

func linkCanonicalNameFor(_ releaseFunction: SwiftFunction) {

    let type = releaseFunction.parms[0].type.canonical

    if let decl = type.asDeclRef?.decl.canonical {
        link(decl: decl, toReleaseFunc: releaseFunction)
        return
    }

    if let ptrType = type.asPointer, let decl = ptrType.pointeeType.asDeclRef?.decl.canonical {
        link(decl: decl, toReleaseFunc: releaseFunction)
        return
    }
}

func structNameFor(_ releaseFunction: SwiftFunction) -> String {

    let type = releaseFunction.parms[0].type

    if let decl = type.asDeclRef?.decl {
        return decl.name
    }

    guard let ptrType = type.asPointer else { fatalError() }

    if let decl = ptrType.pointeeType.asDeclRef?.decl {

        return decl.name
    } else if let opaque = ptrType.pointeeType.asOpaque {
        return opaque.typeName
    } else {
        fatalError("\(ptrType)")
    }
}

func canonicalNameFor(_ releaseFunction: SwiftFunction) -> String {

    let type = releaseFunction.parms[0].type

    if let decl = type.canonical.asDeclRef?.decl.canonical {
        return decl.name
    }

    guard let ptrType = type.canonical.asPointer else { fatalError() }

    if let decl = ptrType.pointeeType.asDeclRef?.decl.canonical {

        return decl.name
    } else if let opaque = ptrType.pointeeType.asOpaque {
        return opaque.typeName
    } else {
        fatalError("\(ptrType)")
    }
}

private class SwiftReleaseFuncsPassVisitor: SwiftVisitor {

    override func visit(type: SwiftType) throws -> SwiftType {

//        if let declType = type as? SwiftDeclRefType,
//           declType.decl is SwiftUnion,
//           let sdkDecl = declType.decl.origAST as? SwiftUnion,
//           let outerStruct = stack.last(where: { $0 is SwiftObject }),
//           let outerSdkStruct = outerStruct.origAST as? SwiftObject {
//            let sdkUnionName = outerSdkStruct.name + "." + sdkDecl.name
//            os_log("union: %{public}s.%{public}s", stackPath, sdkUnionName)
//            return SwiftBuiltinType(name: sdkUnionName, qual: type.qual)
//            //            return SwiftDeclRefType(decl: declType.decl, qual: type.qual)
//        }

        return try super.visit(type: type)
    }
}

