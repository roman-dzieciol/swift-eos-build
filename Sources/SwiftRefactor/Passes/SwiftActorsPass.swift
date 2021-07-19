
import Foundation
import SwiftAST

// TODO: Add Actor support
public class SwiftActorsPass: SwiftRefactorPass {

    public override func refactor(module: SwiftModule) throws {

        var objectsByName: [String: SwiftObject] = [:]

        func object(named objectName: String) -> SwiftObject {
            if let object = objectsByName[objectName] {
                return object
            }

            let object = objectsByName[objectName] ?? SwiftObject(name: objectName, tagName: "class", superTypes: ["SwiftEOSActor"])
            module.append(object)
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
            object.link(.module, ref: module)


            let handleParm = function.parms.first(where: { $0.name == "Handle" })!

            if object.inner.isEmpty {

                let handle = SwiftMember(name: handleParm.name, type: handleParm.type, isMutable: false, getter: nil, comment: handleParm.comment)
                object.append(handle)

                let initializer = try object.functionInitMemberwise()
                initializer.attributes.formUnion(["required"])

                if let acquireFunc = functionsReturningHandle.first(where: { $0.returnType.canonical == handle.type.canonical }) {
                    acquireFunc.returnType = SwiftDeclRefType(decl: object, qual: .optional)
                    acquireFunc.code = .function.returningActorFromHandle(nest: acquireFunc.code!)
                }
            }

            _ = try object.functionDeinit()

            function.removeAll([handleParm])
            object.append(function)

            return function

        }

        module.removeAll(movedFunctions)

    }
}
