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
    case let (.binaryOperator(i1, op1, i2), .binaryOperator(i3, op2, i4)): return i1 == i3 && op1 == op2 && i2 == i4
    case let (.unaryOperator(op1, i1), .unaryOperator(op2, i2)): return op1 == op2 && i1 == i2
    default: return false
    }
}

class SearchQueryParserTests: XCTestCase {
    
    let factory = DefaultSearchQueryFactory()
    
    func check(_ string: String, expected: [QueryOperator<DefaultOperator>]) {
        XCTAssertEqual(factory.makeQuery(for: string).queryOperators, expected)
    }
    
    func testPerformanceExample() {
        self.measure {
            _ = self.factory.makeQuery(for: "\"a b c d e f g h asdasdasdsd l   ads asd as  s da AND (b | C) | r ! (a & b & c) | c ! a").queryOperators
            
        }
    }
    
    func testSimpleAND() { check("a b c", expected: [.binaryOperator(.value("c"), .and, .binaryOperator(.value("b"), .and, .value("a")))]) }
    
    func testTwoSpaces() { check("a  b", expected: [.binaryOperator(.value("b"), .and, .value("a"))]) }
    
    func testOnlyNOT() { check("NOT a", expected: [.unaryOperator(.not, .value("a"))]) }
    
    func testDefaultOpAndOR() { check("AND a OR b", expected: [.binaryOperator(.value("b"), .or, .binaryOperator(.value("a"), .and, .value("AND")))]) }
    
    func testNOTAtFirstInBrackets() { check("a (NOT a)", expected: [.binaryOperator(.unaryOperator(.not, .value("a")), .and, .value("a"))]) }
    // MARK: and)]) }
    /* TODO: check them
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
