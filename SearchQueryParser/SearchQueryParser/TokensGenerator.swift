//
//  TokensGenerator.swift
//  SearchQueryParser
//
//  Created by Alex Severyanov on 11/07/2017.
//  Copyright © 2017 alexizh. All rights reserved.
//

import Foundation

class TokensGenerator {
    struct Token {
        enum Kind {
            case validOpeningBrackets
            case validClosingBrackets
            case phrase
            case `default`
        }
        
        let value: String
        var type: Kind = .default
        
        init(value: String, type: Kind = .default) {
            self.value = value
            self.type = type
        }
    }
    
    struct Group {
        let opening: Character
        let closing: Character
    }
    
    var brackets = Group(opening: "(", closing: ")")
    var phrases = Group(opening: "\"", closing: "\"")
    
    func makeTokens(from string: String) -> [Token] {
        var brackets: [Int] = []
        var tokens: [Token] = []
        
        var value = ""
        var prevChar: Character?
        
        func isStart(index: String.Index) -> Bool {
            return prevChar == " " || prevChar == self.brackets.opening || index == string.startIndex
        }
        func isEnd(index: String.Index, nextIndex: String.Index?) -> Bool {
            let nextChar = nextIndex.map { string[$0] }
            return nextChar == " " || nextChar == self.brackets.closing || index == string.index(before: string.endIndex)
        }
        
        var index = string.startIndex
        var nextIndex: String.Index?
        
        func saveValue() {
            tokens.append(Token(value: value))
            value = ""
        }
        
        while index != string.endIndex {
            let char = string[index]
            
            nextIndex = string.index(after: index)
            if nextIndex == string.endIndex {
                nextIndex = nil
            }
            
            defer {
                prevChar = char
                if index != string.endIndex {
                    index = string.index(after: index)
                }
            }
            
            guard char != " " else { saveValue(); continue }
            
            // if it's valid opening phrase character
            if phrases.opening == char && isStart(index: index) {
                var phrase = ""
                var newIndex = string.index(after: index)
                var newChar: Character? = newIndex == string.endIndex ? nil : string[newIndex]
                var nextIndex: String.Index? = newIndex != string.endIndex ? string.index(after: newIndex) : nil
                if nextIndex == string.endIndex { nextIndex = nil }
                while newIndex != string.endIndex && (newChar != phrases.closing || !isEnd(index: newIndex, nextIndex: nextIndex)) {
                    phrase += String(newChar!)
                    
                    newIndex = string.index(after: newIndex)
                    if newIndex != string.endIndex {
                        newChar = string[newIndex]
                        nextIndex = string.index(after: newIndex)
                        if nextIndex == string.endIndex { nextIndex = nil }
                    }
                }
                if newChar == phrases.closing {
                    index = newIndex
                    
                    tokens.append(Token(value: phrase, type: .phrase))
                    value = ""
                    continue
                }
            }
            if self.brackets.opening == char && isStart(index: index) {
                brackets.append(tokens.count+1)
                
                saveValue()
                
                tokens.append(Token(value: ""))
                continue
            }
            if self.brackets.closing == char && isEnd(index: index, nextIndex: nextIndex) {
                if let i = brackets.last {
                    tokens[i] = Token(value: String(self.brackets.opening), type: .validOpeningBrackets)
                    
                    _ = brackets.popLast()
                    
                    saveValue()
                    
                    tokens.append(Token(value: String(char), type: .validClosingBrackets))
                    continue
                }
            }
            
            value.append(char)
        }
        tokens.append(Token(value: value))
        
        brackets.forEach { tokens[$0+1] = Token(value: "\(self.brackets.opening)" + tokens[$0+1].value) }
        brackets.removeAll()
        
        tokens = tokens.filter({ !$0.value.isEmpty })
        
        return tokens
    }
}
