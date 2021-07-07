
import Foundation
import SwiftAST

// TODO: Add Actor support
public class SwiftActorsPass: SwiftRefactorPass {

    public override func refactor(module: SwiftModule) throws {

//        let sdkModule = module.origAST as! SwiftModule

        var objectsByName: [String: SwiftObject] = [:]

        func object(named objectName: String) -> SwiftObject {
            if let object = objectsByName[objectName] {
                return object
            }

            let object = objectsByName[objectName] ?? SwiftObject(name: objectName, tagName: "class", superTypes: ["SwiftEOSActor"])
            module.inner.append(object)
            objectsByName[objectName] = object
            return object
        }


        let functions = module.inner
            .compactMap { $0 as? SwiftFunction }

        let functionsWithHandle = functions
            .filter { $0.parms.first?.name == "Handle" }


        let functionsReturningHandle = functions
//            .filter { $0.parms.isEmpty }
            .filter { $0.name.hasPrefix("SwiftEOS_Platform_Get") }

        let movedFunctions: [SwiftFunction] = try functionsWithHandle.compactMap { function in

            var components = function.name.split(separator: "_", maxSplits: Int.max, omittingEmptySubsequences: true)

            if components.first == "SwiftEOS" {
                components.removeFirst()
            }

            guard components.count > 1 else {
                return nil
            }

            let namespace = components[0]
            let functionName = components.dropFirst()
            function.name = functionName.joined(separator: "_")

            let objectName = "SwiftEOS_" + namespace + "_Actor"
            let object = object(named: objectName)


            let handleParm = function.parms.first(where: { $0.name == "Handle" })!

            if object.inner.isEmpty {

                let handle = SwiftMember(name: handleParm.name, type: handleParm.type, isMutable: false, getter: nil, comment: handleParm.comment)
                object.inner.append(handle)

                let initializer = try object.functionInitMemberwise()
                initializer.attributes.formUnion(["required"])

                if let acquireFunc = functionsReturningHandle.first(where: { $0.returnType.canonical == handle.type.canonical }) {
                    acquireFunc.returnType = SwiftDeclRefType(decl: object, qual: .optional)
                    acquireFunc.code = .function.returningActorFromHandle(nest: acquireFunc.code!)
                }
            }

            _ = try object.functionDeinit()

            function.removeAll([handleParm])
            object.inner.append(function)

            return function

        }

        module.removeAll(movedFunctions)

//        // Gather available sdk objects by name
//        let sdkObjects = [String: SwiftObject](uniqueKeysWithValues: sdkModule.inner
//                                                .compactMap { $0 as? SwiftObject }
//                                                .map { ($0.name, $0) })
//
//        // Add actors for all the sdk handles
//        sdkModule.inner
//            .compactMap { $0 as? SwiftTypealias }
//            .filter { $0.type.withoutTypealias.isOpaquePointer() }
//            .filter { $0.type.baseType.name.hasSuffix("Handle") }
//            .forEach { handleDecl in
//
//                let actorName = String(handleDecl.type.baseType.name.dropSuffix("Handle"))
//                let handleActor = SwiftActor(name: actorName, superTypes: [], inner: [], comment: nil)
//                let handleType = SwiftDeclRefType(decl: handleDecl, qual: .none)
//                let handleField = SwiftMember(name: "Handle", type: handleType, comment: nil)
//                handleActor.inner.append(handleField)
//
////                if let currentSdkObject = sdkObjects["_tag" + actorName] {
////                    guard let object = currentSdkObject.copiedAST as? SwiftObject else { fatalError() }
////                    print(currentSdkObject.name)
////                } else {
////                }
//            }
    }
}
