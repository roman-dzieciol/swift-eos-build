
import Foundation
import ClangAST

final public class CTestableImpl {

    let clangAST: TranslationUnitDecl
    let headersURL: URL
    let implURL: URL
    let indent = String(repeating: " ", count: 4)

    var headersString: String = ""
    var implString: String = ""
    var functions: [FunctionDecl] = []

    public init(ast clangAST: ClangAST, headersURL: URL, implURL: URL) {
        self.clangAST = clangAST as! TranslationUnitDecl
        self.headersURL = headersURL.appendingPathComponent("TestableEOSSDK.h")
        self.implURL = implURL.appendingPathComponent("TestableEOSSDK.c")
    }

    public func emit() throws {

        headersString = "\n"
        headersString += "#pragma once"
        headersString += "\n"
        headersString += "#include \"EOSSDK/eos_umbrella.h\""
        headersString += "\n"
        headersString += "\n"


        implString = "\n"
        implString += "#include <stdio.h>\n"
        implString += "#include <stdlib.h>\n"
        implString += "#include <assert.h>\n"
        implString += "#include \"include/TestableEOSSDK.h\"\n"
        implString += "\n"


        functions = []

        try visit(ast: clangAST)

        functions.sort(by: { $0.name < $1.name })

        for function in functions {

            let testPointName = "__on_" + function.name

            let functionPointerString = printFunctionSignature(function: function, name: "(*" + testPointName + ")")

            headersString += "extern \(functionPointerString);\n\n"

            let returnString = function.returnType != "void" ? "return " : ""

            implString +=
"""
\(functionPointerString) = NULL;

\(printFunctionSignature(function: function, name: function.name)) {
    if(NULL != \(testPointName)) {
        \(returnString)\(printFunctionCall(function: function, name: testPointName));
    } else {
        assert(!"NULL == \(testPointName)");
        exit(EXIT_FAILURE);
    }
}


"""
        }

        try headersString.write(to: headersURL, atomically: true, encoding: .utf8)
        try implString.write(to: implURL, atomically: true, encoding: .utf8)
    }

    public func visit(ast: ClangAST) throws {

        if let function = ast as? FunctionDecl {
            functions.append(function)
        }

        try ast.inner.forEach {
            try visit(ast: $0)
        }
    }

    func printFunctionCall(function: FunctionDecl, name functionName: String) -> String {
        var output: String = ""
        output += functionName
        output += "("
        let args = function.parms.map { $0.name }
        output += args.joined(separator: ", ")
        output += ")"
        return output
    }

    func printFunctionSignature(function: FunctionDecl, name functionName: String) -> String {
        var parmsOutput: [String] = []
        function.parms.forEach { parm in
            var parmOutput: String = ""
            parmOutput += parm.type
            if parmOutput.last != "*" {
                parmOutput += " "
            }
            parmOutput += parm.name
            parmsOutput.append(parmOutput)
        }

        var output: String = ""
        output += function.returnType
        if output.last != "*" {
            output += " "
        }
        output += functionName
        output += "("
        output += parmsOutput.joined(separator: ", ")
        output += ")"
        return output
    }
}
