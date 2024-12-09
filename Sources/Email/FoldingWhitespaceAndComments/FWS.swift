import Parsing
import Foundation

typealias FWS = FoldableWhitespace

enum FoldableWhitespace {
    @ParserBuilder<Substring> static func parser() -> some Parser<Substring, Token> {
        CharacterSet.whitespacesAndNewlines
            .map { Token.foldableWhiteSpace($0) }
    }
}
