
import Foundation

public struct SwiftWriterOptions: OptionSet {

    public static let compact = SwiftWriterOptions(rawValue: 1 << 1)

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}


final public class SwiftWriterStream<OutputStream>: SwiftOutputStream where OutputStream: TextOutputStream {

    private enum Alignment: Hashable {
        case paragraph
    }

    public let options: SwiftWriterOptions

    public private(set) var stack: [SwiftOutputStreamable] = []

    public private(set) var outputStream: OutputStream

    private var currentColumn: Int = 0
    private var lastOutput: String = ""
    private var indent: String = ""
    private let tabSpaces: Int = 4
    private let identifierCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
    private let newlineCharacters = CharacterSet.newlines
    private let reservedNames: Set<String> = ["Type"]
    private var indentIfNeeded: String { outputWasNewLine() ? indent : "" }
    private var columns: [Alignment: Int] = [:]
    private let alignColumns: Bool = true

    public init(outputStream: OutputStream, options: SwiftWriterOptions = []) {
        self.outputStream = outputStream
        self.options = options
    }

    private func write(_ swift: String, terminator: String, to stream: inout OutputStream) {
        print(swift, terminator: terminator, to: &stream)
        let swift = swift + terminator
        if !swift.isEmpty {
            lastOutput = swift

            if alignColumns {
                if let index = lastOutput.lastIndex(where: { $0 == "\n" }) {
                    let distance = lastOutput.distance(from: lastOutput.startIndex, to: index)
                    currentColumn = lastOutput.count - (distance + 1)
                } else {
                    currentColumn += lastOutput.count
                }
            }
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
}

extension SwiftWriterStream {

    private func stack(_ inner: SwiftOutputStreamable, _ action: () -> Void) {
        stack.append(inner)
        action()
        stack.removeLast()
    }

    private func outputWasIdentifier() -> Bool {
        lastOutput.unicodeScalars.last.map { identifierCharacters.contains($0) } == true
    }

    private func outputWasNewLine() -> Bool {
        lastOutput.unicodeScalars.last.map { newlineCharacters.contains($0) } == true
    }

    private func writeIndent() {
        write(text: indent)
    }

    private func handleReserved(name: String) -> String {
        if reservedNames.contains(name) {
            return "`\(name)`"
        } else {
            return name
        }
    }
}

extension SwiftWriterStream {

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

    private func format(_ inner: SwiftOutputStreamable, _ action: () -> Void) {

        if let formatting = textPrefix(inner, stack: stack) {
            write(textIfNeeded: formatting)
        }

        action()

        if let formatting = textPostfix(inner, stack: stack) {
            write(textIfNeeded: formatting)
        }
    }

    private func format(nested opening: String, _ closing: String, _ action: () -> Void) {
        indent.append(String(repeating: " ", count: tabSpaces))
        action()
        indent.removeLast(tabSpaces)
    }
}

extension SwiftWriterStream {

    private func textPrefix(name: String, stack: [SwiftOutputStreamable]) -> String? {
        switch (name, stack.last) {
        case ("in", is SwiftClosureSignatureExpr): return " "
        case ("throws", is SwiftFunction): return " "
        default: return nil
        }
    }

    private func textPostfix(name: String, stack: [SwiftOutputStreamable]) -> String? {
        switch (name, stack.last) {
        case ("in", is SwiftClosureSignatureExpr): return "\n"
        default: return nil
        }
    }

    private func textPrefix(token: String, stack: [SwiftOutputStreamable]) -> String? {
        switch (token, stack.last) {
        case ("=", _): return " "
        case ("{", _) where !lastOutput.hasSuffix("\n"): return " "
        case ("}", _) where !options.contains(.compact): return outputWasNewLine() ? nil : "\n"
        case ("}", is SwiftObject): return "\n"
        case ("}", is SwiftFunction): return "\n"
        case ("}", is SwiftMember): return "\n"
        case ("}", _): return outputWasNewLine() ? nil : " "
        case (")", let s as SwiftFunctionCallArgClauseExpr) where shouldUseMultilineFormat(s): return "\n"
        case (")", let s as SwiftFunction) where !s.parms.isEmpty: return "\n"
        case ("->", _): return " "
        default: return nil
        }
    }

    private func textPostfix(token: String, stack: [SwiftOutputStreamable]) -> String? {
        switch (token, stack.last) {
        case ("=", _): return " "
        case (",", is SwiftFunction): return "\n"
        case ("{", is SwiftDecl): return "\n"
        case ("{", _): return " "
        case ("(", let s as SwiftFunction) where !s.parms.isEmpty: return "\n"
        case ("(", let s as SwiftFunctionCallArgClauseExpr) where shouldUseMultilineFormat(s): return "\n"
        case (",", let s as SwiftFunctionCallArgListExpr): return shouldUseMultilineFormat(s) ? "\n": " "
        case (",", is SwiftClosureParameterListExpr): return " "
        case ("]", is SwiftCaptureListExpr): return " "
        case (":", _): return " "
        case ("->", _): return " "
        default: return nil
        }
    }

    private func textPrefix(_ streamable: SwiftOutputStreamable, stack: [SwiftOutputStreamable]) -> String? {
        switch (streamable, stack.last) {
        case (is SwiftCommentText, _): return textPrefixSwiftCommentText()
        case (is SwiftCommentParam, _): return nil
        case (is SwiftCommentBlock, _): return nil
        case (is SwiftCommentParagraph, _): return textPrefixSwiftCommentParagraph()
        case (let c as SwiftComment, _): return textPrefixSwiftComment(c)
        case (is SwiftDecl, _): return "\n"
        default: return nil
        }
    }

    private func textPostfix(_ streamable: SwiftOutputStreamable, stack: [SwiftOutputStreamable]) -> String? {
        switch (streamable, stack.last) {
        case (is SwiftCommentText, _): return textPostfixSwiftCommentText(stack: stack)
        case (is SwiftCommentParam, _): return nil
        case (is SwiftCommentBlock, _): return nil
        case (let c as SwiftCommentParagraph, _): return textPostfixSwiftCommentParagraph(c, stack: stack)
        case (let c as SwiftComment, _): return textPostfixSwiftComment(c)
        case (is SwiftObject, _): return "\n"
        case (is SwiftFunction, _): return "\n"
        case (is SwiftMember, _): return "\n"
        case (is SwiftClosureSignatureExpr, _): return "\n"
        default: return nil
        }
    }
}

extension SwiftWriterStream {

    private func isMultiline(_ comment: SwiftComment) -> Bool {
        !comment.isOneLine
    }

    private func shouldUseMultilineFormat(_ expr: SwiftFunctionCallArgClauseExpr) -> Bool {
        return expr.list.nonTrailingClosureItems.count > 1 && expr.list.trailingClosureItems.isEmpty

    }

    private func shouldUseMultilineFormat(_ expr: SwiftFunctionCallArgListExpr) -> Bool {
        return expr.nonTrailingClosureItems.count > 1 && expr.trailingClosureItems.isEmpty
    }
}

extension SwiftWriterStream {

    private func textPrefixSwiftCommentText() -> String? {
        guard let outerOuterComment = stack.dropLast().last as? SwiftComment else { fatalError() }
        if alignColumns && !(outerOuterComment is SwiftCommentParam) {
            if let previousColumn = columns[.paragraph] {
                let adjustment = previousColumn - currentColumn
                if adjustment > 0 {
                    return String(repeating: " ", count: adjustment)
                }
            } else {
                columns[.paragraph] = currentColumn
            }
        }
        return nil
    }

    private func textPrefixSwiftCommentParagraph() -> String? {
        if alignColumns {
            columns[.paragraph] = nil
        }
        return nil
    }

    private func textPrefixSwiftComment(_ c: SwiftComment) -> String? {
        if c.isTopLevel {
            return ("\n" + indent + "/**") + (isMultiline(c) ? "\n" : " ")
        }
        return nil
    }

    private func textPostfixSwiftCommentText(stack: [SwiftOutputStreamable]) -> String? {
        guard let outerOuterComment = stack.dropLast().last as? SwiftComment else { fatalError() }
        if outerOuterComment.isTopLevel {
            if isMultiline(outerOuterComment){
                write(text: "\n")
                return nil
            } else {
                return nil
            }
        } else {
            return "\n"
        }
    }

    private func textPostfixSwiftCommentParagraph(_ c: SwiftCommentParagraph, stack: [SwiftOutputStreamable]) -> String? {
        guard let outerComment = stack.last as? SwiftComment else { fatalError() }
        if outerComment.isTopLevel {
            if !isMultiline(outerComment) {
                return nil
            } else if outerComment.inner.last !== c {
                write(text: "\n")
                return nil
            }
        }
        return "\n"
    }

    private func textPostfixSwiftComment(_ c: SwiftComment) -> String? {
        if c.isTopLevel {
            return (isMultiline(c) ? indentIfNeeded : " ") + "*/" + "\n"
        }
        return nil
    }
}

