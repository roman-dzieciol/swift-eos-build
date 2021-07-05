
import Foundation

public extension Array {

    @inlinable mutating func replaceElement<C>(at index: Index, with newElements: C) where C : Collection, Element == C.Element {
        remove(at: index)
        insert(contentsOf: newElements, at: index)
    }
}
