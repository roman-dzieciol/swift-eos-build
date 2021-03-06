
import Foundation

final public class SwiftBuiltinType: SwiftType {

    public let builtinName: String

    public static let intTypesExactlyConvertibleToInt = Set(["Int8", "UInt8", "Int16", "UInt16", "Int32", "UInt32", "Int64"])

    public static let intTypes32BitPlus = Set(["Int32", "UInt32", "Int64", "UInt64"])
    
    public override var debugDescriptionDetails: String {

        "\(super.debugDescriptionDetails), " +
        "\(builtinName)"
    }

    public init(name: String, qual: SwiftQual = .none) {
        self.builtinName = name
        super.init(qual: qual)
    }

    public override func isEqual(rhs: SwiftType) -> Bool {
        guard let rhs = rhs as? Self else { return false }
        return super.isEqual(rhs: rhs) &&
        builtinName == rhs.builtinName
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(builtinName)
    }

    public override func copy(_ adjust: (SwiftQual) -> SwiftQual) -> SwiftType {
        SwiftBuiltinType(name: builtinName, qual: adjust(qual))
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(name: builtinName)
        swift.write(text: SwiftName.token(isOptional: isOptional))
    }

    public override var isTrivial: Bool {
        isInt
    }

    public override var nilExpr: SwiftExpr? {
        if let nilExpr = super.nilExpr {
            return nilExpr
        }
        if isBool {
            return .false
        }
        if isNumeric {
            return .zero
        }
        if isString {
            return .string("\"\"")
        }
        if isUnion {
            return .string(".init()")
        }

        return nil
    }

}


extension SwiftType {

    final public var asBuiltin: SwiftBuiltinType? {
        self as? SwiftBuiltinType
    }

    final public var isNumeric: Bool {
        isInt || isFloatingPoint
    }

    final public var isInt: Bool {
        asBuiltin?.builtinName.hasPrefix("UInt") == true ||
        asBuiltin?.builtinName.hasPrefix("Int") == true
    }

    final public var isFloatingPoint: Bool {
        asBuiltin?.builtinName == "Double" ||
        asBuiltin?.builtinName == "Float"
    }

    final public var isByte: Bool {
        asBuiltin?.builtinName == "UInt8"  ||
        asBuiltin?.builtinName == "Int8"
    }

    final public var isString: Bool {
        asBuiltin?.builtinName == "String"
    }

    final public var isCChar: Bool {
        asBuiltin?.builtinName == "CChar"
    }

    final public var isVoid: Bool {
        asBuiltin?.builtinName == "Void"
    }

    final public var isBool: Bool {
        asBuiltin?.builtinName == "Bool"
    }

    final public var isEosBool: Bool {
        asDeclRef?.decl.canonical.name == "EOS_Bool"
    }

    final public var isTuple: Bool {
        asBuiltin?.builtinName.hasPrefix("(") == true &&
        asBuiltin?.builtinName.hasSuffix(")") == true
    }

    final public var isFixedWidthString: Bool {
        asBuiltin?.builtinName.hasPrefix("String_") == true
    }

    final public var isUnion: Bool {
        (asBuiltin?.builtinName.contains("__Unnamed_union") == true) ||
        (asDeclRef?.decl.canonical is SwiftUnion)
    }
}


extension SwiftType {

    final public var asInt: SwiftBuiltinType? {
        isInt ? asBuiltin : nil
    }

    final public var asByte: SwiftBuiltinType? {
        isByte ? asBuiltin : nil
    }

    final public var asString: SwiftBuiltinType? {
        isString ? asBuiltin : nil
    }

    final public var asCChar: SwiftBuiltinType? {
        isCChar ? asBuiltin : nil
    }

    final public var asVoid: SwiftBuiltinType? {
        isVoid ? asBuiltin : nil
    }
}
