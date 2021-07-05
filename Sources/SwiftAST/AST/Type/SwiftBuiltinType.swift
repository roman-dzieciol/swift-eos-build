
import Foundation

public class SwiftBuiltinType: SwiftType {

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
        swift.write(text: Self.token(isOptional: isOptional))
    }

    public override var isTrivial: Bool {
        isInt
    }
}


extension SwiftType {

    public var asBuiltin: SwiftBuiltinType? {
        self as? SwiftBuiltinType
    }

    public var isNumeric: Bool {
        isInt
    }

    public var isInt: Bool {
        asBuiltin?.builtinName.hasPrefix("UInt") == true ||
        asBuiltin?.builtinName.hasPrefix("Int") == true
    }

    public var isByte: Bool {
        asBuiltin?.builtinName == "UInt8"  ||
        asBuiltin?.builtinName == "Int8"
    }

    public var isString: Bool {
        asBuiltin?.builtinName == "String"
    }

    public var isCChar: Bool {
        asBuiltin?.builtinName == "CChar"
    }

    public var isVoid: Bool {
        asBuiltin?.builtinName == "Void"
    }
}


extension SwiftType {

    public var asInt: SwiftBuiltinType? {
        isInt ? asBuiltin : nil
    }

    public var asByte: SwiftBuiltinType? {
        isByte ? asBuiltin : nil
    }

    public var asString: SwiftBuiltinType? {
        isString ? asBuiltin : nil
    }

    public var asCChar: SwiftBuiltinType? {
        isCChar ? asBuiltin : nil
    }

    public var asVoid: SwiftBuiltinType? {
        isVoid ? asBuiltin : nil
    }
}
