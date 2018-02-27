//
//  SearchQuery.swift
//  SearchQueryParser
//
//  Created by Alex Severyanov on 12/07/2017.
//  Copyright © 2017 alexizh. All rights reserved.
//

import Foundation

public class SearchQuery<Item: Operator> {
    public let string: String

    public let operators: [Item: [String]]
    public let whitespaceOperator: Item
    
    public let isCaseSensitive: Bool
    public var queryOperators: [QueryOperator<Item>] {
        if _queryOperators == nil {
            parseQueryIfNeeded()
        }
        return _queryOperators!
    }

    private var _queryOperators: [QueryOperator<Item>]?

    public init(_ string: String, isCaseSensitive: Bool = true, operators: [Item: [String]], whitespaceOperator: Item) {
        precondition(whitespaceOperator.type == .binary, "whitespace operator (\(whitespaceOperator)) should be binary")

        self.string = string
        self.operators = operators
        self.whitespaceOperator = whitespaceOperator

        self.isCaseSensitive = isCaseSensitive
    }

    public func parseQueryIfNeeded() {
        let tokenizer = Tokenizer<Item>(operators: operators, whitespace: whitespaceOperator)
        tokenizer.isCaseSensitive = isCaseSensitive

        _queryOperators = makeQueryOperators(from: ReversePolishNotation.generate(from: tokenizer.tokenize(string)))
    }
}

private func makeQueryOperators<T>(from stack: [ReversePolishNotation.QueryItem<T>]) -> [QueryOperator<T>] {
    var input = stack
    var result: [QueryOperator<T>] = []

    while let item = input.first {
        switch item {
        case .operator(let op):
            guard let one = result.popLast() else { break }
            if op.type == .binary {
                guard let second = result.popLast() else { break }
                result.append(.binaryOperator(one, op, second))
            } else {
                result.append(.unaryOperator(op, one))
            }

        case .value(let str):
            result.append(.value(str))
        }
        input.removeFirst()
    }
    return result
}
