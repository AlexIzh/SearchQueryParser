//
//  ParserTests.swift
//  SearchTest
//
//  Created by Alex Severyanov on 10/07/2017.
//  Copyright © 2017 alexizh. All rights reserved.
//

import XCTest

extension ReversePolishNotation.QueryItem: Equatable {}

func ==<T>(_ lhs: ReversePolishNotation.QueryItem<T>, _ rhs: ReversePolishNotation.QueryItem<T>) -> Bool {
    switch (lhs, rhs) {
    case let (.value(v1), .value(v2)): return v1 == v2
    case let (.operator(o1), .operator(o2)): return o1 as? DefaultOperator == o2 as? DefaultOperator
    default: return false
    }
}

class ReversePolishNotationTests: XCTestCase {
    
    func check(_ tokens: [Token<DefaultOperator>], expected: [ReversePolishNotation.QueryItem<DefaultOperator>]) {
        XCTAssertEqual(ReversePolishNotation.generate(from: tokens), expected)
    }
    // MARK: - Operators
    func testSimpleAND() {
        check([.value("a"), .operator(.and), .value("b"), .operator(.and), .value("c")],
              expected: [.value("a"), .value("b"), .operator(.and), .value("c"), .operator(.and)])
    }
    
    func testNOTAtFirst() {
        check([.operator(.not), .value("a")],
              expected: [.value("a"), .operator(.not)])
    }
    
    func testNOTAtFirstInBrackets() {
        check([.value("a"), .operator(.and), .bracket(isOpening: true), .operator(.not), .value("a"), .bracket(isOpening: false)],
              expected: [.value("a"), .value("a"), .operator(.not), .operator(.and)])
    }
    
    func testOneFirstBracket() {
        check([.value("a"), .operator(.and), .bracket(isOpening: true), .operator(.and), .value("a")],
              expected: [.value("a"), .value("a"), .operator(.and), .operator(.and)])
    }
    
    func testAND_OR() {
        check([.value("AND"), .operator(.and), .value("a"), .operator(.or), .value("b")],
              expected: [.value("AND"), .value("a"), .operator(.and), .value("b"), .operator(.or)])
    }
    
    func testOR_AND() {
        check([.value("NOT"), .operator(.or), .value("a"), .operator(.and), .value("b")],
              expected: [.value("NOT"), .value("a"), .value("b"), .operator(.and), .operator(.or)])
    }
}
