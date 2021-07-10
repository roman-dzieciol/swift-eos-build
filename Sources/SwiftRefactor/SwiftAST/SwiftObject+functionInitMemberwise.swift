
import Foundation
import SwiftAST


extension SwiftObject {

    func functionInitMemberwise() throws -> SwiftFunction {

        if let function = linked(.functionInitMemberwise) as? SwiftFunction {
            return function
        }

        let function = SwiftFunction(
            name: "init",
            isAsync: false,
            isThrowing: false,
            returnType: .void,
            inner: [],
            comment: .init("Memberwise initializer"))

        inner.append(function)
        link(.functionInitMemberwise, ref: function)

        var statements: [SwiftExpr] = []

        for member in members {

            if let decl = member.type.canonical.asDeclRef?.decl.canonical, let memberObject = decl as? SwiftObject, memberObject.inSwiftEOS {
                _ = try memberObject.functionInitMemberwise()
            }

            let functionParm = SwiftFunctionParm(
                label: member.name,
                name: member.name,
                type: member.type,
                comment: member.comment)

            functionParm.link(.member, ref: member)
            member.link(.initializer, ref: functionParm)

            function.append(functionParm)

            let stmt = SwiftExprBuilder(expr: .self_(.string(member.name)).assign(.string(functionParm.name)))
            stmt.link(ast: member)
            stmt.link(ast: functionParm)
            statements.append(stmt)
        }

        function.code = SwiftCodeBlock(statements: statements)

        return function
    }


    func functionDeinit() throws -> SwiftFunction {


        if let function = linked(.functionDeinit) as? SwiftFunction {
            return function
        }

        let function = SwiftFunction(
            name: "deinit",
            isAsync: false,
            isThrowing: false,
            returnType: .void,
            inner: [],
            comment: .init(""))

        inner.append(function)
        link(.functionDeinit, ref: function)

        var statements: [SwiftExpr] = []

        for member in members {

            if let releaseFunc = member.type.asDeclRef?.decl.linked(.releaseFunc) as? SwiftFunction {
                statements += [releaseFunc.call([.string("Handle").arg(nil)])]
            }
        }

        function.code = SwiftCodeBlock(statements: statements)

        return function
    }
}
