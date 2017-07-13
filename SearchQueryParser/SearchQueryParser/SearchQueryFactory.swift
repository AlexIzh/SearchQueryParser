//
//  SearchQueryFactory.swift
//  SearchQueryParser
//
//  Created by Alex Severyanov on 12/07/2017.
//  Copyright © 2017 alexizh. All rights reserved.
//

import Foundation

public struct PredicateBuilder<Element, Item> where Item: Operator {
	let value: (String) -> Element
	let binary: (Element, Item, Element) -> Element
	let unary: (Item, Element) -> Element
	
	public func build(from: QueryOperator<Item>) -> Element {
		switch from {
		case let .unaryOperator(item, op):
			return unary(item, self.build(from: op))
			
		case let .binaryOperator(item1, op, item2):
			return binary(self.build(from: item1), op, self.build(from: item2))
			
		case .value(let str):
			return value(str)
		}
	}
}

open class SearchQueryFactory<Item: Operator> {
	public var operators: [Item: [String]]
	public var whitespaceOperator: Item
	
	public var isCaseSensitive = true
	
	public init(operators: [Item: [String]], whitespaceOperator: Item) {
		self.operators = operators
		self.whitespaceOperator = whitespaceOperator
	}
	
	public func makeQuery(for string: String) -> SearchQuery<Item> {
		return SearchQuery(string, isCaseSensitive: isCaseSensitive, operators: operators, whitespaceOperator: whitespaceOperator)
	}
}
