//
//  TokenizerTests.swift
//  SearchQueryParser
//
//  Created by Alex Severyanov on 11/07/2017.
//  Copyright © 2017 alexizh. All rights reserved.
//

import XCTest

extension Token: Equatable {}

func ==<T>(_ lhs: Token<T>, _ rhs: Token<T>) -> Bool where T: Operator {
	switch (lhs, rhs) {
	case let (.operator(op1), .operator(op2)):
		if let op1 = op1 as? DefaultOperator, let op2 = op2 as? DefaultOperator {
			return op1 == op2
		}
		return false
		
	case let (.value(str1), .value(str2)):
		return str1 == str2
		
	case let (.bracket(v1), .bracket(v2)):
		return v1 == v2
	
	default:
		return false
	}
}

class TokenizerTests: XCTestCase {
	
	let tokenizer = Tokenizer<DefaultOperator>(operators: [.and: ["AND", "&"], .or: ["OR", "|"], .not: ["NOT", "!"]], whitespace: .and)
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func check(_ string: String, expected: [Token<DefaultOperator>]) {
		let tokens = tokenizer.tokenize(string)
		XCTAssertEqual(tokens, expected)
	}
	
	func testSimple() {
		check("a a AND b NOT c (a AND b) OR c OR", expected: [.value("a"), .operator(.and), .value("a"), .operator(.and), .value("b"), .operator(.and), .operator(.not), .value("c"), .operator(.and), .bracket(true), .value("a"), .operator(.and), .value("b"), .bracket(false), .operator(.or), .value("c"), .operator(.and), .value("OR")])
	}
}
