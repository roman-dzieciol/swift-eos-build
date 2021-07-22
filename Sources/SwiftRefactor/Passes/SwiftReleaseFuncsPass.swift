
import Foundation
import SwiftAST
import os.log

final public class SwiftReleaseFuncsPass: SwiftRefactorPass {

    public override func refactor(module: SwiftModule) throws {

        let funcs = module.inner
            .compactMap { $0 as? SwiftFunction }

        let releaseFuncs = funcs
            .filter { $0.name.hasSuffix("_Release") }
            .filter { $0.sdk?.name.hasSuffix("EOS_Leaderboards_LeaderboardDefinition_Release") != true }

        releaseFuncs.forEach {
            linkStructNameFor($0)
            linkCanonicalNameFor($0)
        }

        let notifyFuncs = funcs.filter { $0.name.contains("Notify") }
        let notifyFuncsByName = [String: [SwiftFunction]](grouping: notifyFuncs, by: { $0.name })

        notifyFuncs
            .filter { $0.name.contains("AddNotify") }
            .forEach { addNotifyFunc in
                
                let removeNotifyName = addNotifyFunc.name.replacingOccurrences(of: "_AddNotify", with: "_RemoveNotify")
                if let removeNotifyFunc = notifyFuncsByName[removeNotifyName]?.first {
                    addNotifyFunc.link(.removeNotifyFunc, ref: removeNotifyFunc)
                }

                let removeNotifyNameWithoutVersion = String(String(removeNotifyName.reversed().drop(while: { $0.isNumber }).reversed()).dropSuffix("V"))
                if let removeNotifyFunc = notifyFuncsByName[removeNotifyNameWithoutVersion]?.first {
                    addNotifyFunc.link(.removeNotifyFunc, ref: removeNotifyFunc)
                }
            }
    }
}

private func link(decl: SwiftAST, toReleaseFunc: SwiftFunction) {
    decl.swifty?.comment?.append(SwiftCommentBlock(name: "Note", comments: [SwiftCommentParagraph(text: ["Release func: ``\(toReleaseFunc.name)``"])]))
    decl.link(.releaseFunc, ref: toReleaseFunc)
}

private func linkStructNameFor(_ releaseFunction: SwiftFunction) {

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

private func linkCanonicalNameFor(_ releaseFunction: SwiftFunction) {

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

private func structNameFor(_ releaseFunction: SwiftFunction) -> String {

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

private func canonicalNameFor(_ releaseFunction: SwiftFunction) -> String {

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
