
import Foundation

open class SwiftWriterStream<OutputStream>: SwiftOutputStream where OutputStream: TextOutputStream {

    public var stack: [SwiftOutputStreamable] = []

    var outputStream: OutputStream

    var lastOutput: String = ""
    var indent: String = ""

    let tabSpaces: Int = 4
    let identifierCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
    let newlineCharacters = CharacterSet.newlines

    let reservedNames: Set<String> = ["Type"]

    public init(outputStream: OutputStream) {
        self.outputStream = outputStream
    }

    private func write(_ swift: String, terminator: String, to stream: inout OutputStream) {
        print(swift, terminator: terminator, to: &stream)
        let swift = swift + terminator
        if !swift.isEmpty {
            lastOutput = swift
        }
    }

    public func write(text: String) {
        write(text, terminator: "", to: &outputStream)
    }

    public func write(textIfNeeded text: String) {
        guard !lastOutput.hasSuffix(text) else { return }
        write(text, terminator: "", to: &outputStream)
    }

    public func write(token: String) {
        format(token: token) {
            write(text: token)
        }
    }

    public func write(name: String) {
        format(name: name) { name in
            write(text: name)
        }
    }

    public func write(nested opening: String, _ closing: String, _ contents: () -> Void) {
        if !opening.isEmpty {
            write(token: opening)
        }
        format(nested: opening, closing, contents)
        if !closing.isEmpty {
            write(token: closing)
        }
    }

    public func write(_ ast: SwiftOutputStreamable?) {
        guard let ast = ast else { return }
        format(ast) {
            stack(ast) {
                ast.write(to: self)
            }
        }
    }

    public func write(_ inner: [SwiftOutputStreamable]) {
        inner.forEach {
            write($0)
        }
    }

    public func write(_ inner: [SwiftOutputStreamable], separated: String) {
        inner.enumerated().forEach { (index, element) in
            write(element)
            if index != inner.count - 1 {
                write(token: separated)
            }
        }
    }

    public func write(optRef: SwiftVarDecl) {
        write(name: optRef.name)
    }


    public func indent(offset: Int, _ action: () -> Void) {
        let indentString = String(repeating: " ", count: abs(offset))
        if offset > 0 {
            indent.append(indentString)
            action()
            indent.removeLast(offset)
        } else {
            indent.removeLast(offset)
            action()
            indent.append(indentString)
        }
    }

    private func stack(_ inner: SwiftOutputStreamable, _ action: () -> Void) {
        stack.append(inner)
        action()
        stack.removeLast()
    }
}

extension SwiftWriterStream {

    private func outputWasIdentifier() -> Bool {
        lastOutput.unicodeScalars.last.map { identifierCharacters.contains($0) } == true
    }

    private func outputWasNewLine() -> Bool {
        lastOutput.unicodeScalars.last.map { newlineCharacters.contains($0) } == true
    }

    private func writeIndent() {
        write(text: indent)
    }

    private func format(token: String, _ action: () -> Void) {

        if let formatting = textPrefix(token: token, stack: stack) {
            write(textIfNeeded: formatting)
        }

        if outputWasNewLine() {
            writeIndent()
        }

        action()

        if let formatting = textPostfix(token: token, stack: stack) {
            write(textIfNeeded: formatting)
        }
    }

    private func format(name: String, _ action: (String) -> Void) {

        if let formatting = textPrefix(name: name, stack: stack) {
            write(textIfNeeded: formatting)
        }

        if outputWasNewLine() {
            writeIndent()
        }
        else if outputWasIdentifier() {
            write(textIfNeeded: " ")
        }

        action(handleReserved(name: name))

        if let formatting = textPostfix(name: name, stack: stack) {
            write(textIfNeeded: formatting)
        }
    }

    private func handleReserved(name: String) -> String {
        if reservedNames.contains(name) {
            return "`\(name)`"
        } else {
            return name
        }
    }

    private func format(_ inner: SwiftOutputStreamable, _ action: () -> Void) {

        if let comment = inner as? SwiftComment {

            if type(of: comment) == SwiftComment.self {
                write(textIfNeeded: "\n")
                write(text: "\n")
                write(token: "/**")
                if !comment.isOneLine {
                    write(textIfNeeded: "\n")
                }
            }

            if outputWasNewLine() {
                if type(of: comment) == SwiftCommentText.self {
                    write(token: " *")
                } else if type(of: comment) == SwiftCommentBlock.self || type(of: comment) == SwiftCommentParam.self {
                    write(token: " * ")
                }
            }
        }

        if let formatting = textPrefix(inner, stack: stack) {
            write(textIfNeeded: formatting)
        }

        action()

        if let formatting = textPostfix(inner, stack: stack) {
            write(textIfNeeded: formatting)
        }

        if let comment = inner as? SwiftComment {
            if type(of: comment) == SwiftComment.self {
                write(token: " */")
                write(textIfNeeded: "\n")
            } else if comment is SwiftCommentText,
                      let topComment = stack.last(where: { type(of: $0) == SwiftComment.self }) as? SwiftComment,
                      !topComment.isOneLine {
                write(text: "\n")
            }
        }
    }

    private func format(nested opening: String, _ closing: String, _ action: () -> Void) {
        let indentSpacing = self.indentSpacing(for: stack.last)
        indent.append(String(repeating: " ", count: indentSpacing))
        action()
        indent.removeLast(indentSpacing)
    }

    private func indentSpacing(for inner: SwiftOutputStreamable?) -> Int {
        return tabSpaces
    }


    func textPrefix(name: String, stack: [SwiftOutputStreamable]) -> String? {
        switch (name, stack.last) {
        case ("in", is SwiftClosureSignatureExpr): return " "
        case ("throws", is SwiftFunction): return " "
        default: return nil
        }
    }

    func textPostfix(name: String, stack: [SwiftOutputStreamable]) -> String? {
        switch (name, stack.last) {
        case ("in", is SwiftClosureSignatureExpr): return "\n"
        default: return nil
        }
    }

    func textPrefix(token: String, stack: [SwiftOutputStreamable]) -> String? {
        switch (token, stack.last) {
        case ("=", _): return " "
        case ("{", _) where !lastOutput.hasSuffix("\n"): return " "
        case ("}", is SwiftObject): return "\n"
        case ("}", is SwiftFunction): return "\n"
        case ("}", _): return " "
        case (")", let s as SwiftFunctionCallArgClauseExpr) where shouldUseMultilineFormat(s): return "\n"
        case (")", let s as SwiftFunction) where !s.parms.isEmpty: return "\n"
        case ("->", _): return " "
        default: return nil
        }
    }

    func shouldUseMultilineFormat(_ expr: SwiftFunctionCallArgClauseExpr) -> Bool {
        return expr.list.nonTrailingClosureItems.count > 1 && expr.list.trailingClosureItems.isEmpty

    }

    func shouldUseMultilineFormat(_ expr: SwiftFunctionCallArgListExpr) -> Bool {
        return expr.nonTrailingClosureItems.count > 1 && expr.trailingClosureItems.isEmpty
    }

    func textPostfix(token: String, stack: [SwiftOutputStreamable]) -> String? {
        switch (token, stack.last) {
        case ("=", _): return " "
        case (",", is SwiftFunction): return "\n"
        case ("{", is SwiftDecl): return "\n"
        case ("{", _): return " "
        case ("(", let s as SwiftFunction) where !s.parms.isEmpty: return "\n"
        case ("(", let s as SwiftFunctionCallArgClauseExpr) where shouldUseMultilineFormat(s): return "\n"
        case (",", let s as SwiftFunctionCallArgListExpr): return shouldUseMultilineFormat(s) ? "\n": " "
        case ("]", is SwiftCaptureListExpr): return " "
        case (":", _): return " "
        case ("->", _): return " "
        default: return nil
        }
    }

    func textPrefix(_ streamable: SwiftOutputStreamable, stack: [SwiftOutputStreamable]) -> String? {
        nil
    }

    func textPostfix(_ streamable: SwiftOutputStreamable, stack: [SwiftOutputStreamable]) -> String? {
        switch (streamable, stack.last) {
        case (is SwiftObject, _): return "\n"
        case (is SwiftFunction, _): return "\n"
        case (is SwiftMember, _): return "\n"
        case (is SwiftClosureSignatureExpr, _): return "\n"
        default: return nil
        }
    }
}

