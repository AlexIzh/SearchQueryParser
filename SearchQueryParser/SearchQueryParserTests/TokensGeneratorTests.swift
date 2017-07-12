//
//  _TokenizerTests.swift
//  SearchQueryParser
//
//  Created by Alex Severyanov on 10/07/2017.
//  Copyright © 2017 alexizh. All rights reserved.
//

import XCTest

typealias _Token = TokensGenerator.Token

extension TokensGenerator.Token: Equatable, CustomStringConvertible {
	
	init(_ value: String, _ type: Kind = .default) {
		self.init(value: value, type: type)
	}
	
	public var description:String {
		return "(\(value) \(type))"
	}
}

func ==(_ lhs: TokensGenerator.Token, _ rhs: TokensGenerator.Token) -> Bool {
	return lhs.value == rhs.value && lhs.type == rhs.type
}

class TokensGeneratorTests: XCTestCase {
	
	let tokenizer = TokensGenerator()
	
	func check(_ string: String, expected: [TokensGenerator.Token]) {
		let tokens = tokenizer.makeTokens(from: string)
		XCTAssertEqual(tokens, expected)
	}
	
	func testOpeningBracketsTogether_More() {
		check("a OR (((a + b) + c)", expected: [_Token("a"), _Token("OR"), _Token("("), _Token("(", .validOpeningBrackets), _Token("(", .validOpeningBrackets), _Token("a"), _Token("+"), _Token("b"), _Token(")", .validClosingBrackets), _Token("+"), _Token("c"), _Token(")", .validClosingBrackets)])
		check("a OR ( ( ( a + b ) + c )", expected: [_Token("a"), _Token("OR"), _Token("("), _Token("(", .validOpeningBrackets), _Token("(", .validOpeningBrackets), _Token("a"), _Token("+"), _Token("b"), _Token(")", .validClosingBrackets), _Token("+"), _Token("c"), _Token(")", .validClosingBrackets)])
	}
	func testOpeningBracketOne() {
		check("a OR (b", expected: [_Token("a"), _Token("OR"), _Token("(b")])
		check("a OR (b c (d (e f", expected: [_Token("a"), _Token("OR"), _Token("(b"), _Token("c"), _Token("(d"), _Token("(e"), _Token("f")])
		check("a OR ( b", expected: [_Token("a"), _Token("OR"), _Token("("), _Token("b")])
		check("a OR b (", expected: [_Token("a"), _Token("OR"), _Token("b"), _Token("(")])
	}
	func testTwoSpaces() { check("a  b", expected: [_Token("a"), _Token("b")]) }
	
	
	func testOneQuote() {
		check("a \" b", expected: [_Token("a"), _Token("\""), _Token("b")])
	}
	
	func testQuotesSimple() { check("\"a b c\"", expected: [_Token("a b c", .phrase)]) }
	func testOnlyOneQuote() { check("\"", expected: [_Token("\"")]) }
	func testOnlyQuotes() { check("\"\"", expected: []) }
	func testOnlyQuoteAndOpeningBracket() { check("(\"", expected: [_Token("(\"")]) }
	func testOnlyQuoteAndClosingBracket() { check("\")", expected: [_Token("\")")]) }
	func testEmptyQuotesInBrackets() { check("(\"\")", expected: [_Token("(", .validOpeningBrackets), _Token(")", .validClosingBrackets)]) }
	func testQuotesWithSpaceInBrackets() { check("(\" \")", expected: [_Token("(", .validOpeningBrackets), _Token(" ", .phrase), _Token(")", .validClosingBrackets)]) }
	
	func testQuotesInExpression() { check("( a b ) \"c d\"", expected: [_Token("(", .validOpeningBrackets), _Token("a"), _Token("b"), _Token(")", .validClosingBrackets), _Token("c d", .phrase)]) }
	func testFewQuotesInStart() { check("\"a b\" OR \"b c\" AND \"c d\"", expected: [_Token("a b", .phrase), _Token("OR"), _Token("b c", .phrase), _Token("AND"),  _Token("c d", .phrase)]) }
	func testQuotesInStart() { check("\"a b\" d", expected: [_Token("a b", .phrase), _Token("d")]) }
	
	func testInvalidOneQuoteAtStart() { check("\"ab", expected: [_Token("\"ab")]) }
	func testInvalidOneQuoteAtStartInExpression() { check("a \"ab", expected: [_Token("a"), _Token("\"ab")]) }
	func testInvalidOneQuoteAtMiddle() { check("a\"c ab", expected: [_Token("a\"c"), _Token("ab")]) }
	func testInvalidOneQuoteAtEndInExpression() { check("a abc\" d", expected: [_Token("a"), _Token("abc\""), _Token("d")]) }
	func testInvalidOneQuoteAtEnd() { check("a abc\"", expected: [_Token("a"), _Token("abc\"")]) }
	
	func testInvalidBothQuotes() { check("a\"bc\"d", expected: [_Token("a\"bc\"d")]) }
	func testInvalidBothQuotesInExpression() { check("a a\"bc\"d c", expected: [_Token("a"), _Token("a\"bc\"d"), _Token("c")]) }
	
	func testInvalidFirstQuote() { check("a\"bc\" d", expected: [_Token("a\"bc\""), _Token("d")]) }
	func testInvalidSecondQuote() { check("\"ab\"c d", expected: [_Token("\"ab\"c"), _Token("d")]) }
	
	func testQuotesInQuotes() { check("a \"ab\"c b\"d\" d", expected: [_Token("a"), _Token("ab\"c b\"d", .phrase), _Token("d")]) }
}
