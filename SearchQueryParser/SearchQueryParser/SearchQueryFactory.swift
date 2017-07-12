//
//  SearchQueryFactory.swift
//  SearchQueryParser
//
//  Created by Alex Severyanov on 12/07/2017.
//  Copyright © 2017 alexizh. All rights reserved.
//

import Foundation

public enum DefaultOperator: Operator {
	case not, and, or
	
	public var type: OperatorType { return self == .not ? .unary : .binary }
	public var priority: Int {
		switch self {
		case .not: return 3
		case .and: return 2
		case .or: return 1
		}
	}
}

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

public struct DefaultPredicateBuilder {
	private let builder: PredicateBuilder<NSPredicate, DefaultOperator>
	
	public init(valuePredicate: @escaping (String) -> NSPredicate) {
		builder = PredicateBuilder(value: valuePredicate, binary: { predicate1, op, predicate2 in
			switch op {
			case .and:
				return NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
				
			case .or:
				return NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1, predicate2])
				
			default:
				return predicate1
			}
		}, unary: { op, predicate in
			return NSCompoundPredicate(notPredicateWithSubpredicate: predicate)
		})
	}
	
	public func build(from query: QueryOperator<DefaultOperator>) -> NSPredicate {
		return builder.build(from: query)
	}
}

public struct DefaultFilterBlockBuilder<Item> {
	public typealias BlockType = (Item) -> Bool
	
	private let builder: PredicateBuilder<BlockType, DefaultOperator>
	
	public init(valuePredicate: @escaping (String) -> BlockType) {
		builder = PredicateBuilder(value: valuePredicate, binary: { predicate1, op, predicate2 in
			switch op {
			case .and:
				return { predicate1($0) && predicate2($0) }
				
			case .or:
				return { predicate1($0) || predicate2($0) }
				
			default:
				return predicate1
			}
		}, unary: { op, predicate in
			return { !predicate($0) }
		})
	}
	
	public func build(from query: QueryOperator<DefaultOperator>) -> BlockType {
		return builder.build(from: query)
	}
}

public class DefaultSearchQueryFactory: SearchQueryFactory<DefaultOperator> {
	public init(isCaseSensetive: Bool = true, whitespaceIsAND: Bool = true) {//should be used AND for whitespaces
		super.init(operators: [.and: ["AND", "&"], .or: ["OR", "|"], .not: ["NOT", "!"]], whitespaceOperator: whitespaceIsAND ? .and : .or)
		self.isCaseSensitive = isCaseSensitive
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
		return SearchQuery(string, operators: operators, whitespaceOperator: whitespaceOperator)
	}
}
