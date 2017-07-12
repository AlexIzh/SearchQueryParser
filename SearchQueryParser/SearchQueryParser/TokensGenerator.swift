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
		
		let isStart: (String.Index) -> Bool = { prevChar == " " || prevChar == self.brackets.opening || $0 == string.startIndex }
		let map: (String.Index) -> Character = { string[$0] }
		let isEnd: (String.Index, String.Index?) -> Bool = { $1.map(map) == " " || $1.map(map) == self.brackets.closing || $0 == string.index(before: string.endIndex) }
		
		var index = string.startIndex
		var nextIndex: String.Index?
		
		let saveValue: () -> Void = {
			tokens.append(Token(value: value))
			value = ""
		}
		let resetValue: () -> Void = { value = "" }
		
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

			if phrases.opening == char && isStart(index) {
				var phrase = ""
				var newIndex = string.index(after: index)
				var newChar: Character? = newIndex == string.endIndex ? nil : string[newIndex]
				var nextIndex: String.Index? = newIndex != string.endIndex ? string.index(after: newIndex) : nil
				if nextIndex == string.endIndex { nextIndex = nil }
				while newIndex != string.endIndex && (newChar != phrases.closing || !isEnd(newIndex, nextIndex)) {
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
					resetValue()
					continue
				}
			}
			if self.brackets.opening == char && isStart(index) {
				brackets.append(tokens.count+1)
				
				saveValue()
				
				tokens.append(Token(value: ""))
				continue
			}
			if self.brackets.closing == char && isEnd(index, nextIndex) {
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
