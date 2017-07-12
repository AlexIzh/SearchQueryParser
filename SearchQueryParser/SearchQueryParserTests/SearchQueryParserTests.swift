//
//  SearchQueryParserTests.swift
//  SearchQueryParserTests
//
//  Created by Alex Severyanov on 10/07/2017.
//  Copyright © 2017 alexizh. All rights reserved.
//

import XCTest

extension QueryOperator: Equatable {}

public func ==<T>(_ lhs: QueryOperator<T>, _ rhs: QueryOperator<T>) -> Bool {
	switch (lhs, rhs) {
	case let (.value(str1), .value(str2)): return str1 == str2
	case let (.binaryOperator(i1, op1, i2), .binaryOperator(i3,op2,i4)): return i1 == i3 && op1 == op2 && i2 == i4
	case let (.unaryOperator(op1, i1), .unaryOperator(op2, i2)): return op1 == op2 && i1 == i2
	default: return false
	}
}


class SearchQueryParserTests: XCTestCase {
	
	let factory = DefaultSearchQueryFactory()
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	func check(_ string: String, expected: [QueryOperator<DefaultOperator>]) {
		XCTAssertEqual(factory.makeQuery(for: string).queryOperators, expected)
	}
	
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
			
			_ = self.factory.makeQuery(for: "\"a b c d e f g h asdasdasdsd l   ads asd as  s da AND (b | C) | r ! (a & b & c) | c ! a").queryOperators
			
        }
    }
	
	func testSimpleAND() { check("a b c", expected: [.binaryOperator(.value("c"), .and, .binaryOperator(.value("b"), .and, .value("a")))]) }
	func testTwoSpaces() { check("a  b", expected: [.binaryOperator(.value("b"), .and, .value("a"))]) }
	func testOnlyNOT() { check("NOT a", expected: [.unaryOperator(.not, .value("a"))]) }
	func testDefaultOpAndOR() { check("AND a OR b", expected: [.binaryOperator(.value("b"), .or, .binaryOperator(.value("a"), .and, .value("AND")))]) }

	func testNOTAtFirstInBrackets() { check("a (NOT a)", expected: [.binaryOperator(.unaryOperator(.not, .value("a")), .and, .value("a"))]) }
	/*
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

	//TODO: create issue for this and update test. "(" should be like simple value, in current implementation it will be omitted
	func testInvalidSecondBracketAtEndWithSpace() { check("a abc )", expected: [.value("a"), .value("abc"), .operator(.and)]) }
	func testInvalidSecondBracketWithSpaceInExpression() { check("a ) ab", expected: [.value("a"), .value("ab"), .operator(.and)]) }
*/
}
