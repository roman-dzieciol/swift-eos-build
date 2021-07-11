
import Foundation
import SwiftAST

public class SwiftApiNotesPass: SwiftRefactorPass {

    public func refactor(module: SwiftModule, apiNotesURL: URL) throws {

        var apiNotes: String = ""

        print("---", to: &apiNotes)
        print("Name: EOSSDK", to: &apiNotes)

        print("", to: &apiNotes)
        print("Tags:", to: &apiNotes)

        module.inner
            .compactMap { $0 as? SwiftEnum }
            .forEach { swiftEnum in
                print("- Name: \(swiftEnum.name)", to: &apiNotes)
                print("  EnumKind: NSEnum", to: &apiNotes)
            }

        try apiNotes.write(to: apiNotesURL, atomically: true, encoding: .utf8)
    }
}
