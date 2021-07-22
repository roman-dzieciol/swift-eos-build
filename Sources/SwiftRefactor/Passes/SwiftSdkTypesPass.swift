
import Foundation
import SwiftAST
import os.log

final public class SwiftSdkTypesPass: SwiftRefactorPass {

    public override func refactor(module: SwiftModule) throws {

        // EOS_UI_ReportKeyEventOptions is unused
        module.replaceWithSdkRefs { decl in
            decl.sdk?.name.hasSuffix("EOS_UI_ReportKeyEventOptions")
        }

        // EOS_UI_ReportKeyEventOptions is unused
        module.replaceWithSdkRefs { decl in
            decl.sdk?.name.hasSuffix("EOS_UI_PrePresentOptions")
        }

        // *_Release funcs are present in SDK AST only
        module.replaceWithSdkRefs { decl in
            (decl as? SwiftFunction)?.name.hasSuffix("_Release") == true
        }
        
        // *RemoveNotify* funcs are present in SDK AST only
        module.replaceWithSdkRefs { decl in
            (decl as? SwiftFunction)?.name.contains("RemoveNotify") == true
        }

        // *ProtectMessage* funcs are present in SDK AST only
        module.replaceWithSdkRefs { decl in
            (decl as? SwiftFunction)?.name.contains("ProtectMessage") == true
        }

        // *UnprotectMessage* funcs are present in SDK AST only
        module.replaceWithSdkRefs { decl in
            (decl as? SwiftFunction)?.name.contains("UnprotectMessage") == true
        }

        // *ReceivePacket* funcs are present in SDK AST only
        module.replaceWithSdkRefs { decl in
            (decl as? SwiftFunction)?.name.contains("ReceivePacket") == true
        }



//        // Vec3f is present in SDK AST only
//        module.replaceWithSdkRefs { decl in
//            (decl as? SwiftObject)?.name.hasSuffix("EOS_AntiCheatCommon_Vec3f") == true
//        }
//
//        // Quat is present in SDK AST only
//        module.replaceWithSdkRefs { decl in
//            (decl as? SwiftObject)?.name.hasSuffix("EOS_AntiCheatCommon_Quat") == true
//        }
//
//        // EOS_AntiCheatCommon_LogPlayerUseWeaponData is present in SDK AST only
//        module.replaceWithSdkRefs { decl in
//            (decl as? SwiftObject)?.name.hasSuffix("EOS_AntiCheatCommon_LogPlayerUseWeaponData") == true
//        }
//
//        // EOS_AntiCheatCommon_LogEventParamPair is present in SDK AST only
//        module.replaceWithSdkRefs { decl in
//            (decl as? SwiftObject)?.name.hasSuffix("EOS_AntiCheatCommon_LogEventParamPair") == true
//        }
//
//        // EOS_AntiCheatCommon_RegisterEventParamDef is present in SDK AST only
//        module.replaceWithSdkRefs { decl in
//            (decl as? SwiftObject)?.name.hasSuffix("EOS_AntiCheatCommon_RegisterEventParamDef") == true
//        }



        // EOS_P2P_SocketId is present in SDK AST only
//        module.replaceWithSdkRefs { decl in
//            (decl as? SwiftObject)?.name.hasSuffix("EOS_P2P_SocketId") == true
//        }

        // EOS_P2P_PacketQueueInfo is present in SDK AST only
        module.replaceWithSdkRefs { decl in
            (decl as? SwiftObject)?.sdk?.name.hasSuffix("EOS_P2P_PacketQueueInfo") == true
        }



        // Handles are present in SDK AST only
        module.replaceWithSdkRefs { decl in
            decl.name.hasSuffix("Handle") == true
        }

        // Enums are present in SDK AST only
        module.replaceWithSdkRefs { decl in
            decl is SwiftEnum
        }

        // Enum typealiases are present in SDK AST only
        module.replaceWithSdkRefs { decl in
            ((decl as? SwiftTypealias)?.type.canonical.asDeclRef?.decl.canonical is SwiftEnum) == true
        }

        // Value typealiases are present in SDK AST only
        module.replaceWithSdkRefs { decl in
            (decl as? SwiftTypealias)?.type.canonical.asBuiltin != nil
        }

        // Callback typealiases are present in SDK AST only
        module.replaceWithSdkRefs { decl in
            (decl as? SwiftTypealias)?.type.canonical.asFunction != nil
        }

        // Opaque pointer typealiases are present in SDK AST only
        module.replaceWithSdkRefs { decl in
            (decl as? SwiftTypealias)?.type.canonical.asOpaquePointer != nil
        }

        try SwiftUseSdkTypesPassVisitor().visit(ast: module)
    }
}

private class SwiftUseSdkTypesPassVisitor: SwiftVisitor {

    override func visit(type: SwiftType) throws -> SwiftType {

        if let declType = type as? SwiftDeclRefType,
           declType.decl is SwiftUnion,
           let sdkDecl = declType.decl.origAST as? SwiftUnion,
           let outerStruct = stack.last(where: { $0 is SwiftObject }),
           let outerSdkStruct = outerStruct.origAST as? SwiftObject {
            let sdkUnionName = outerSdkStruct.name + "." + sdkDecl.name
            os_log("union: %{public}s.%{public}s", stackPath, sdkUnionName)
            return SwiftBuiltinType(name: sdkUnionName, qual: type.qual)
//            return SwiftDeclRefType(decl: declType.decl, qual: type.qual)
        }

        return try super.visit(type: type)
    }
}

