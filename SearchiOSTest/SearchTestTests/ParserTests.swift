//
//  ParserTests.swift
//  SearchTest
//
//  Created by Alex Severyanov on 10/07/2017.
//  Copyright © 2017 alexizh. All rights reserved.
//

import XCTest
//@testable import SearchTest

extension Builder.StackItem: Equatable {}

func ==(_ lhs: Builder.StackItem, _ rhs: Builder.StackItem) -> Bool {
	switch (lhs, rhs) {
	case let (.value(v1), .value(v2)): return v1 == v2
	case let (.operator(o1), .operator(o2)): return o1 == o2
	default: return false
	}
}

class ParserTests: XCTestCase {
	
	let builder = Builder()
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	func check(_ string: String, expected: [Builder.StackItem]) {
		let stack = builder.parse(string)
		XCTAssertEqual(stack.allValues, expected)
	}
	//MARK: - Operators
	func testSimpleAND() { check("a b c", expected: [.value("a"), .value("b"), .operator(.and), .value("c"), .operator(.and)]) }
	func testTwoSpaces() { check("a  b", expected: [.value("a"), .value("b"), .operator(.and)]) }
	func testNOTAtFirst() { check("NOT a", expected: [.value("a"), .operator(.not)]) }
	func testANDAtFirst() { check("AND a b", expected: [.value("a"), .value("AND"), .operator(.and), .value("b"), .operator(.and)]) }
	func testANDAtEnd() { check("a b AND", expected: [.value("a"), .value("b"), .operator(.and), .value("AND"), .operator(.and)]) }
	func testNOTAtEnd() { check("a b NOT", expected: [.value("a"), .value("b"), .operator(.and), .value("NOT"), .operator(.and)]) }
	
	func testNOTAtFirstInBrackets() { check("a (NOT a)", expected: [.value("a"), .value("a"), .operator(.not), .operator(.and)]) }
	func testANDAtFirstInBrackets() { check("a (AND a b)", expected: [.value("a"), .value("AND"), .value("a"), .operator(.and), .value("b"), .operator(.and), .operator(.and)]) }
	func testANDAtEndInBrackets() { check("a (a b AND)", expected: [.value("a"), .value("a"), .value("b"), .operator(.and), .value("AND"), .operator(.and), .operator(.and)]) }
	func testNOTAtEndInBrackets() { check("a (b NOT)", expected: [.value("a"), .value("b"), .value("NOT"), .operator(.and), .operator(.and)]) }
	
	//MARK: - Quotes
	func testQuotesSimple() { check("\"a b c\"", expected: [.value("a b c")]) }
	func testOnlyOneQuote() { check("\"", expected: [.value("\"")]) }
	func testOnlyQuotes() { check("\"\"", expected: []) }
	func testOnlyQuoteAndOpeningBracket() { check("(\"", expected: [.value("(\"")]) }
	func testOnlyQuoteAndClosingBracket() { check("\")", expected: [.value("\")")]) }
	func testEmptyQuotesInBrackets() { check("(\"\")", expected: []) }
	func testQuotesWithSpaceInBrackets() { check("(\" \")", expected: [.value(" ")]) }
	
	func testQuotesInExpression() { check("( a b ) \"c d\"", expected: [.value("a"), .value("b"), .operator(.and), .value("c d"), .operator(.and)]) }
	func testQuotesInStart() { check("\"a b\" OR \"b c\" AND \"c d\"", expected: [.value("a b"), .value("b c"), .operator(.or), .value("c d"), .operator(.and)]) }
	func testQuotesInBrackets() { check("a (\"a b c\" OR \"b a c\") d", expected: [.value("a"), .value("a b c"), .value("b a c"), .operator(.or), .operator(.and), .value("d"), .operator(.and)]) }
	
	func testInvalidOneQuoteAtStart() { check("\"ab", expected: [.value("\"ab")]) }
	func testInvalidOneQuoteAtStartInExpression() { check("a \"ab", expected: [.value("a"), .value("\"ab"), .operator(.and)]) }
	func testInvalidOneQuoteAtMiddle() { check("a\"c ab", expected: [.value("a\"c"), .value("ab"), .operator(.and)]) }
	func testInvalidOneQuoteAtEndInExpression() { check("a abc\" d", expected: [.value("a"), .value("abc\""), .operator(.and), .value("d"), .operator(.and)]) }
	func testInvalidOneQuoteAtEnd() { check("a abc\"", expected: [.value("a"), .value("abc\""), .operator(.and)]) }
	
	func testInvalidBothQuotes() { check("a\"bc\"d", expected: [.value("a\"bc\"d")]) }
	func testInvalidBothQuotesInExpression() { check("a a\"bc\"d c", expected: [.value("a"), .value("a\"bc\"d"), .operator(.and), .value("c"), .operator(.and)]) }
	
	func testInvalidFirstQuote() { check("a\"bc\" d", expected: [.value("a\"bc\""), .value("d"), .operator(.and)]) }
	func testInvalidSecondQuote() { check("\"ab\"c d", expected: [.value("\"ab\"c"), .value("d"), .operator(.and)]) }
	
	func testQuotesInQuotes() { check("a \"ab\"c b\"d\" d", expected: [.value("a"), .value("ab\"c b\"d"), .operator(.and), .value("d"), .operator(.and)]) }
	
	//MARK: - Brackets
	func testBrackets() { check("a (b OR c) d", expected: [.value("a"), .value("b"), .value("c"), .operator(.or), .operator(.and), .value("d"), .operator(.and)]) }
	func testOnlyBrackets() { check("()", expected: []) }
	func testOnlyBrackets_space() { check("( )", expected: []) }
	func testOneInBrackets() { check("(a)", expected: [.value("a")]) }
	func testOneInBracketsInExpression() { check("a (b) c", expected: [.value("a"), .value("b"), .operator(.and), .value("c"), .operator(.and)]) }
	func testFewInBracketsInExpression() { check("a (b c) d", expected: [.value("a"), .value("b"), .value("c"), .operator(.and), .operator(.and), .value("d"), .operator(.and)]) }
	
	func testInvalidOnlyFirstBracket() { check("(", expected: []) }//TODO: should be "("
	func testInvalidOnlySecondBracket() { check(")", expected: []) }//TODO: should be ")"
	
	func testInvalidFirtBracketAtStart() { check("(ab", expected: [.value("(ab")]) }
	func testInvalidFirtBracketAtStartInExpression() { check("a (ab (a b)", expected: [.value("a"), .value("(ab"), .value("a"), .value("b"), .operator(.and), .operator(.and), .operator(.and)]) }
	func testInvalidFirtBracketWithSpaceInExpression() { check("a ( ab", expected: [.value("a"), .value("ab"), .operator(.and)]) }//TODO: create issue for this and update test. "(" should be like simple value, in current implementation it will be omitted
//	func testInvalidFirstBracketWithManyBrackets() {
//		check("a ( ab (c) (b) (d (a) )", expected: [.value("a"), .value("("), .operator(.and), .value("ab"), .operator(.and)])
//	}
	func testInvalidFirtBracketAtMiddle() { check("a(c ab", expected: [.value("a(c"), .value("ab"), .operator(.and)]) }
	func testInvalidFirtBracketAtEnd() { check("a abc( d", expected: [.value("a"), .value("abc("), .operator(.and), .value("d"), .operator(.and)]) }
	
	func testInvalidSecondBracketAtStart() { check(")ab", expected: [.value(")ab")]) }
	func testInvalidSecondBracketAtStartInExpression() { check("a )ab", expected: [.value("a"), .value(")ab"), .operator(.and)]) }
	func testInvalidSecondBracketAtMiddle() { check("a)c ab", expected: [.value("a)c"), .value("ab"), .operator(.and)]) }
	func testInvalidSecondBracketAtEndInExpression() { check("(a a) bc) d", expected: [.value("a"), .value("a"), .operator(.and), .value("bc)"), .operator(.and), .value("d"), .operator(.and)]) }
	func testInvalidSecondBracketAtEnd() { check("a abc)", expected: [.value("a"), .value("abc)"), .operator(.and)]) }
	func testInvalidSecondBracketWithInvalidQuote() { check("a abc\")", expected: [.value("a"), .value("abc\")"), .operator(.and)]) }
	func testInvalidSecondBracketWithQuotes() { check("\"a abc\")", expected: [.value("a"), .value("abc\")"), .operator(.and)]) }
	
	//TODO: create issue for this and update test. "(" should be like simple value, in current implementation it will be omitted
	func testInvalidSecondBracketAtEndWithSpace() { check("a abc )", expected: [.value("a"), .value("abc"), .operator(.and)]) }
	func testInvalidSecondBracketWithSpaceInExpression() { check("a ) ab", expected: [.value("a"), .value("ab"), .operator(.and)]) }
	
	func testNestingBrackets() { check("e NOT ((a b) (c d))", expected: [.value("e"), .value("a"), .value("b"), .operator(.and), .value("c"), .value("d"), .operator(.and), .operator(.and), .operator(.not), .operator(.and)]) }
	func testInvalidNestingBrackets() {
		check("e ((a b) (c d)", expected: [])
	}
	func testInvalidNestingBrackets_2() {
		check("e (a b) (c d))", expected: [])
	}
}
