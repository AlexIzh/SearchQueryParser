//
//  _TokenizerTests.swift
//  SearchQueryParser
//
//  Created by Alex Severyanov on 10/07/2017.
//  Copyright © 2017 alexizh. All rights reserved.
//

import XCTest

extension TokensGenerator.Token: Equatable, CustomStringConvertible {
    
    init(_ value: String, _ type: Kind = .default) {
        self.init(value: value, type: type)
    }
    
    public var description: String {
        return "(\(value) \(type))"
    }
}

func ==(_ lhs: TokensGenerator.Token, _ rhs: TokensGenerator.Token) -> Bool {
    return lhs.value == rhs.value && lhs.type == rhs.type
}

class TokensGeneratorTests: XCTestCase {
    typealias Token = TokensGenerator.Token
    
    let tokenizer = TokensGenerator()
    
    func check(_ string: String, expected: [TokensGenerator.Token]) {
        let tokens = tokenizer.makeTokens(from: string)
        XCTAssertEqual(tokens, expected)
    }
    
    func testOpeningBracketsTogether_More() {
        check("a OR (((a + b) + c)", expected: [Token("a"),
                                                Token("OR"),
                                                Token("("),
                                                Token("(", .validOpeningBrackets),
                                                Token("(", .validOpeningBrackets),
                                                Token("a"),
                                                Token("+"),
                                                Token("b"),
                                                Token(")", .validClosingBrackets),
                                                Token("+"),
                                                Token("c"),
                                                Token(")", .validClosingBrackets)])
        
        check("a OR ( ( ( a + b ) + c )", expected: [Token("a"),
                                                     Token("OR"),
                                                     Token("("),
                                                     Token("(", .validOpeningBrackets),
                                                     Token("(", .validOpeningBrackets),
                                                     Token("a"),
                                                     Token("+"),
                                                     Token("b"),
                                                     Token(")", .validClosingBrackets),
                                                     Token("+"),
                                                     Token("c"),
                                                     Token(")", .validClosingBrackets)])
    }
    
    func testOpeningBracketOne() {
        check("a OR (b", expected: [Token("a"), Token("OR"), Token("(b")])
        check("a OR (b c (d (e f", expected: [Token("a"), Token("OR"), Token("(b"), Token("c"), Token("(d"), Token("(e"), Token("f")])
        check("a OR ( b", expected: [Token("a"), Token("OR"), Token("("), Token("b")])
        check("a OR b (", expected: [Token("a"), Token("OR"), Token("b"), Token("(")])
    }
    
    func testTwoSpaces() { check("a  b", expected: [Token("a"), Token("b")]) }
    
    func testOneQuote() {
        check("a \" b", expected: [Token("a"), Token("\""), Token("b")])
    }
    
    func testQuotesSimple() { check("\"a b c\"", expected: [Token("a b c", .phrase)]) }
    
    func testOnlyOneQuote() { check("\"", expected: [Token("\"")]) }
    
    func testOnlyQuotes() { check("\"\"", expected: []) }
    
    func testOnlyQuoteAndOpeningBracket() { check("(\"", expected: [Token("(\"")]) }
    
    func testOnlyQuoteAndClosingBracket() { check("\")", expected: [Token("\")")]) }
    
    func testEmptyQuotesInBrackets() { check("(\"\")", expected: [Token("(", .validOpeningBrackets), Token(")", .validClosingBrackets)]) }
    
    func testQuotesWithSpaceInBrackets() { check("(\" \")", expected: [Token("(", .validOpeningBrackets), Token(" ", .phrase), Token(")", .validClosingBrackets)]) }
    
    func testQuotesInExpression() {
        check("( a b ) \"c d\"", expected: [Token("(", .validOpeningBrackets),
                                            Token("a"),
                                            Token("b"),
                                            Token(")", .validClosingBrackets),
                                            Token("c d", .phrase)])
    }
    
    func testFewQuotesInStart() {
        check("\"a b\" OR \"b c\" AND \"c d\"", expected: [Token("a b", .phrase),
                                                           Token("OR"),
                                                           Token("b c", .phrase),
                                                           Token("AND"),
                                                           Token("c d", .phrase)])
    }
    
    func testQuotesInBrackets() {
        check("(\"a b\")", expected: [Token("(", .validOpeningBrackets),
                                      Token("a b", .phrase),
                                      Token(")", .validClosingBrackets)])
    }
    
    func testQuotesInStart() { check("\"a b\" d", expected: [Token("a b", .phrase), Token("d")]) }
    
    func testInvalidOneQuoteAtStart() { check("\"ab", expected: [Token("\"ab")]) }
    
    func testInvalidOneQuoteAtStartInExpression() { check("a \"ab", expected: [Token("a"), Token("\"ab")]) }
    
    func testInvalidOneQuoteAtMiddle() { check("a\"c ab", expected: [Token("a\"c"), Token("ab")]) }
    
    func testInvalidOneQuoteAtEndInExpression() { check("a abc\" d", expected: [Token("a"), Token("abc\""), Token("d")]) }
    
    func testInvalidOneQuoteAtEnd() { check("a abc\"", expected: [Token("a"), Token("abc\"")]) }
    
    func testInvalidBothQuotes() { check("a\"bc\"d", expected: [Token("a\"bc\"d")]) }
    
    func testInvalidBothQuotesInExpression() { check("a a\"bc\"d c", expected: [Token("a"), Token("a\"bc\"d"), Token("c")]) }
    
    func testInvalidFirstQuote() { check("a\"bc\" d", expected: [Token("a\"bc\""), Token("d")]) }
    
    func testInvalidSecondQuote() { check("\"ab\"c d", expected: [Token("\"ab\"c"), Token("d")]) }
    
    func testQuotesInQuotes() { check("a \"ab\"c b\"d\" d", expected: [Token("a"), Token("ab\"c b\"d", .phrase), Token("d")]) }
}
