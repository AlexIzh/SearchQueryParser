//
//  DefaultSearchQueryFactory.swift
//  SearchQueryParser
//
//  Created by Alex Severyanov on 13/07/2017.
//  Copyright © 2017 alexizh. All rights reserved.
//

import Foundation

public enum DefaultOperator: Int, Operator {
    case not = 3, and = 2, or = 1
    
    public var type: OperatorType { return self == .not ? .unary : .binary }
    public var priority: Int { return self.rawValue }
}

public struct DefaultOptions: OptionSet {
    public let rawValue: Int
    
    public static let spaceMeansOR = DefaultOptions(rawValue: 1 << 0)
    public static let caseInsensitive = DefaultOptions(rawValue: 1 << 1)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public struct DefaultPredicateBuilder {
    
    var options: DefaultOptions { return factory.options }
    
    private let builder: PredicateBuilder<NSPredicate, DefaultOperator>
    private let factory: DefaultSearchQueryFactory
    
    public init(options: DefaultOptions = [], valuePredicate: @escaping (String) -> NSPredicate) {
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
        
        factory = DefaultSearchQueryFactory(options: options)
    }
    
    public func build(from searchString: String) -> NSPredicate? {
        let operators = factory.makeQuery(for: searchString).queryOperators
        return operators.first.map { builder.build(from: $0) }
    }
    
    public func build(from query: QueryOperator<DefaultOperator>) -> NSPredicate {
        return builder.build(from: query)
    }
}

public struct DefaultFilterBlockBuilder<Item> {
    public typealias BlockType = (Item) -> Bool
    
    var options: DefaultOptions { return factory.options }
    
    private let builder: PredicateBuilder<BlockType, DefaultOperator>
    private let factory: DefaultSearchQueryFactory
    
    public init(options: DefaultOptions = [], valuePredicate: @escaping (String) -> BlockType) {
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
        
        factory = DefaultSearchQueryFactory(options: options)
    }
    
    public func build(from searchString: String) -> BlockType? {
        let operators = factory.makeQuery(for: searchString).queryOperators
        return operators.first.map { builder.build(from: $0) }
    }
    
    public func build(from query: QueryOperator<DefaultOperator>) -> BlockType {
        return builder.build(from: query)
    }
}

public class DefaultSearchQueryFactory: SearchQueryFactory<DefaultOperator> {
    let options: DefaultOptions
    
    public init(options: DefaultOptions = []) {
        self.options = options
        
        super.init(operators: [.and: ["AND", "&"], .or: ["OR", "|"], .not: ["NOT", "!"]], whitespaceOperator: options.contains(.spaceMeansOR) ? .or : .and)
        self.isCaseSensitive = !options.contains(.caseInsensitive)
    }
}
