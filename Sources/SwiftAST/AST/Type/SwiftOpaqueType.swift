
import Foundation

public class SwiftOpaqueType: SwiftType {

    public let typeName: String

    public override var debugDescriptionDetails: String {
        "\(super.debugDescriptionDetails), \(typeName)"
    }

    public init(name: String, qual: SwiftQual) {
        self.typeName = name
        super.init(qual: qual)
    }

    public override func isEqual(rhs: SwiftType) -> Bool {
        guard let rhs = rhs as? Self else { return false }
        return super.isEqual(rhs: rhs) &&
        typeName == rhs.typeName
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(typeName)
    }
    
    public override func copy(_ adjust: (SwiftQual) -> SwiftQual) -> SwiftType {
        SwiftOpaqueType(name: typeName, qual: adjust(qual))
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(name: typeName)
    }
}


extension SwiftType {

    public var asOpaque: SwiftOpaqueType? {
        self as? SwiftOpaqueType
    }

    public var isOpaque: Bool {
        self is SwiftOpaqueType
    }
}
