import Foundation


final public class EnumConstantDecl: NamedDecl {

    public func valueTokens() -> [String] {
        Array(
            inner.filter { !($0 is Comment) }
                .map { $0.tokens() }
                .joined()
        )
    }
}
