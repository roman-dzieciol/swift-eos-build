

import Foundation
import SwiftAST
import os.log

extension SwiftAST {

    public func removeAll(_ array: [SwiftAST]) {
        removeAll(Set(array.map { ObjectIdentifier($0) }) )
        let comments = array.compactMap { $0.linked(.comment) }
        if let decl = self as? SwiftDecl {
            decl.comment?.removeAll(comments)
        }
    }

    public func removeAll(_ objects: Set<ObjectIdentifier>) {
        inner.removeAll { decl in
            if objects.contains(ObjectIdentifier(decl)) {
                os_log("removing %{public}s.%{public}s", name, decl.name)
                return true
            }
            return false
        }
    }
}
