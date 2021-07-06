
import Foundation

public final class SwiftWildcardExpr: SwiftPrimaryExpr {

    public override func write(to swift: SwiftOutputStream) {
        swift.write(token: "_")
    }
}
