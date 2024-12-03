import Foundation
import Parsing

public enum Mailbox {
    @ParserBuilder<Substring> static func parser() -> some Parser<Substring, (localPart: Token, domainPart: Token)> {
        OneOf {
            AddrSpec.parser()
            NameAddr.parser()
        }
    }
}
