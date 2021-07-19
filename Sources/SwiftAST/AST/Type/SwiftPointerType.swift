
import Foundation

public class SwiftPointerType: SwiftType {

    public let pointeeType: SwiftType

    public override var baseType: SwiftType {
        pointeeType.baseType
    }

    public override var canonical: SwiftType {
        SwiftPointerType(pointeeType: pointeeType.canonical, isMutable: isMutable, qual: qual)
    }

    public override var innerType: SwiftType { pointeeType }

    public let isMutable: Bool

    public override var debugDescriptionDetails: String {
        "\(super.debugDescriptionDetails), \(pointeeType.debugDescription)"
    }

    public init(pointeeType: SwiftType, isMutable: Bool = false, qual: SwiftQual = .none) {
        self.pointeeType = pointeeType
        self.isMutable = isMutable
        super.init(qual: qual)
    }

    public override func handle(visitor: SwiftVisitor) throws -> SwiftType {
        let newPointeeType = try visitor.visit(type: pointeeType)
        if newPointeeType != pointeeType {
            return SwiftPointerType(pointeeType: newPointeeType, isMutable: isMutable, qual: qual)
        }
        return self
    }

    public override func isEqual(rhs: SwiftType) -> Bool {
        guard let rhs = rhs as? Self else { return false }
        return super.isEqual(rhs: rhs) &&
        pointeeType == rhs.pointeeType
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(pointeeType)
    }

    public override func copy(_ adjust: (SwiftQual) -> SwiftQual) -> SwiftType {
        SwiftPointerType(pointeeType: pointeeType, isMutable: isMutable, qual: adjust(qual))
    }

    public override var immutable: SwiftPointerType {
        SwiftPointerType(pointeeType: pointeeType, isMutable: false, qual: qual)
    }

    public override var mutable: SwiftPointerType {
        SwiftPointerType(pointeeType: pointeeType, isMutable: true, qual: qual)
    }

    public override func write(to swift: SwiftOutputStream) {

        if pointeeType.isVoid {
            if isMutable {
                swift.write(name: "UnsafeMutableRawPointer")
            } else {
                swift.write(name: "UnsafeRawPointer")
            }
        } else if pointeeType is SwiftOpaqueType {
            swift.write(pointeeType)
        } else if isMutable {
            swift.write(name: "UnsafeMutablePointer")
            swift.write(nested: "<", ">") {
                swift.write(pointeeType)
            }
        } else {
            swift.write(name: "UnsafePointer")
            swift.write(nested: "<", ">") {
                swift.write(pointeeType)
            }
        }

        swift.write(text: Self.token(isOptional: isOptional))
    }

    public override var isTrivial: Bool {
        pointeeType.isOpaque == true
    }
}

extension SwiftType {

    public var asPointer: SwiftPointerType? {
        self as? SwiftPointerType
    }

    public var isPointer: Bool {
        self is SwiftPointerType
    }

    public var asImmutablePointer: SwiftPointerType? {
        (asPointer?.isMutable == false) ? asPointer : nil
    }

    public var asMutablePointer: SwiftPointerType? {
        (asPointer?.isMutable == true) ? asPointer : nil
    }

    public var asOpaquePointer: SwiftPointerType? {
        (asPointer?.pointeeType is SwiftOpaqueType) ? asPointer : nil
    }

    public func isOpaquePointer() -> Bool {
        ((withoutTypealias as? SwiftPointerType)?.pointeeType.withoutTypealias as? SwiftOpaqueType) != nil
    }
}
