//
//  ReversePolishNotation.swift
//  SearchQueryParser
//
//  Created by Alex Severyanov on 12/07/2017.
//  Copyright © 2017 alexizh. All rights reserved.
//

import Foundation

enum ReversePolishNotation {
	enum QueryItem<Item: Operator> {
		case value(String)
		case `operator`(Item)
	}
	
	private enum StackOperatorItem<Item: Operator> {
		case logical(Item)
		case openingBracket
	}
	
	static func generate<T>(from tokens: [Token<T>]) -> [QueryItem<T>] where T: Operator {
		
		var output: [QueryItem<T>] = []
		var operations: [StackOperatorItem<T>] = []
		
		for token in tokens {
			switch token {
			case .operator(let op):
				while let item = operations.last, case .logical(let op2) = item,
					(op.type == .binary && op.priority <= op2.priority) || (op.type == .unary && op.priority < op2.priority) {
						
						output.append(.operator(op2))
						_ = operations.removeLast()
				}
				operations.append(.logical(op))
				
			case .bracket(let opening):
				if opening {
					operations.append(.openingBracket)
				} else {
					while let item = operations.last, case .logical(let op) = item {
						output.append(.operator(op))
						_ = operations.removeLast()
					}
					_ = operations.removeLast()
				}
				
			case .value(let str):
				output.append(.value(str))
			}
		}
		
		while let item = operations.last {
			switch item {
			case .logical(let op):
				output.append(.operator(op))
				
			case .openingBracket:
				break
			}
			_ = operations.removeLast()
		}
		
		return output
	}
}
