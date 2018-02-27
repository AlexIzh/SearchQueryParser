//
//  QueryOperator.swift
//  SearchQueryParser
//
//  Created by Alex Severyanov on 10/07/2017.
//  Copyright © 2017 alexizh. All rights reserved.
//

import Foundation

public enum OperatorType {
	case binary
	case unary
}

public protocol Operator: Hashable {
	var priority: Int { get }
    var type: OperatorType { get }
}

public indirect enum QueryOperator<Item: Operator> {
	case value(String)
	case binaryOperator(QueryOperator, Item, QueryOperator)
	case unaryOperator(Item, QueryOperator)
}
