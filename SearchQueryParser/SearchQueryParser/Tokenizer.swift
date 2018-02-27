//
//  Tokenizer.swift
//  SearchQueryParser
//
//  Created by Alex Severyanov on 10/07/2017.
//  Copyright © 2017 alexizh. All rights reserved.
//

import Foundation

enum Token<Item: Operator> {
    case bracket(isOpening: Bool)
    case value(String)
    case `operator`(Item)
}

private struct TokenizerOperators<Item: Operator> {
    let operators: [Item: [String]]
    let whitespace: Item
}

class Tokenizer<Item: Operator> {

    var isCaseSensitive = true {
        didSet {
            if isCaseSensitive != oldValue {
                generateOperatorsMap()
            }
        }
    }

    private let operators: [Item: [String]]
    private let whitespace: Item
    private var map: [String: Item] = [:]

    init(operators: [Item: [String]], whitespace: Item) {
        self.operators = operators
        self.whitespace = whitespace

        generateOperatorsMap()
    }

    func tokenize(_ string: String) -> [Token<Item>] {
        let generator = TokensGenerator()
        let tokens = generator.makeTokens(from: string)

        var result: [Token<Item>] = []

        var prev: Token<Item>?
        var next: TokensGenerator.Token?
        for (index, current) in tokens.enumerated() {
            prev = result.last
            if case .bracket(let opening)? = prev, opening { prev = nil }

            next = index < tokens.count - 1 ? tokens[index+1] : nil
            if next?.type == .validClosingBrackets { next = nil }

            switch current.type {
            case .default:
                if let item = operatorItem(for: current.value) {
                    if item.type == .binary {
                        if let prev = prev, isOperator(prev) == false && next != nil {
                            result.append(.operator(item))
                            break
                        }
                    } else {
                        if next != nil {
                            if prev.map(isOperator) == false {
                                result.append(.operator(whitespace))
                            }
                            result.append(.operator(item))
                            break
                        }
                    }
                }
                fallthrough

            case .phrase:
                if prev.map(isClosingBrackets) == true {
                    result.append(.operator(whitespace))
                } else if prev.map(isOperator) == false {
                    result.append(.operator(whitespace))
                }

                result.append(.value(current.value))

                if next?.type == .validOpeningBrackets {
                    result.append(.operator(whitespace))
                }

            case .validClosingBrackets:
                result.append(.bracket(isOpening: false))

            case .validOpeningBrackets:
                result.append(.bracket(isOpening: true))
            }
        }

        return result
    }

    private func generateOperatorsMap() {
        map = [:]
        for (key, values) in operators {
            values.forEach { map[isCaseSensitive ? $0 : $0.lowercased()] = key }
        }
    }

    private func operatorItem(for string: String) -> Item? {
        return map[isCaseSensitive ? string : string.lowercased()]
    }

    private func isOperator(_ token: Token<Item>) -> Bool {
        switch token {
        case .`operator`(_): return true
        default: return false
        }
    }

    private func isClosingBrackets(_ token: Token<Item>) -> Bool {
        switch token {
        case .bracket(let v): return !v
        default: return false
        }
    }
}
