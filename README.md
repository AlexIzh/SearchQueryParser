# SearchQueryParser
Parsing search string and generate predicates or filtering blocks from it.

#### Public API isn't latest version and will be updated later. Current version of API is ugly, I know.

Current framework allows to use logical operators with search (like `SearchKit`). But only you don't need to generate `Index` file for it. 

Factory supports custom operators, but also you can use default factory with next operators:</br>
1/ `AND`, `&` </br>
2/ `OR`, `|` </br>
3/ `NOT`, `!` </br>

Also, you can configure case sensitive for operators (for example, supports "and", "or", "not" also).  


## Example

iOS (Generating blocks for using `array.filter(_:)`)
![iOS](https://github.com/AlexIzh/SearchQueryParser/blob/master/Gifs/ios.gif)

Mac (generating `NSPredicate` for using with `CoreData`)
![Mac](https://github.com/AlexIzh/SearchQueryParser/blob/master/Gifs/mac.gif)

## Using

```swift
import SearchQueryParser

let factory = DefaultSearchQueryFactory(isCaseSensetive: false) // Create factory with default operators

let blocksBuilder = DefaultFilterBlockBuilder<Item>(valuePredicate: { str in // Create builder with default operators for generating blocks
    return { $0.searchString.lowercased().contains(str.lowercased()) } // return closure for filtering one part of search string, string will be splitted automatically
  }) 
  /// OR, if you use NSPredicate
let builder = DefaultPredicateBuilder() { // Create Predicate's builder for default operators 
      // Create predicate for one part of search string, string will be splitted automatically
      
			if let age = Int32($0) { // if component is number, then search for age
				if self.moreButton.state == NSOnState {
					return NSPredicate(format: "age > %d", age)
				} else if self.lessButton.state == NSOnState {
					return NSPredicate(format: "age < %d", age)
				}
				return NSPredicate(format: "age = %d", age)
			} else { // otherwise, search for name or job with LIKE (supporting ?, * symbools)
				return NSPredicate(format: "(name LIKE[c] %@) OR (job LIKE[c] %@)", $0, $0) 
			}
		}
    //generate 
    let query = factory.makeQuery(for: searchField.stringValue)
    DispatchQueue.global().async {
        let operators = query.queryOperators //parsing string and generates special operators. Basically this array will contain only one element or will be empty.
        if let operator = operators.first {
          var predicate = builder.build(from: operator) // build predicate from operator
          DispatchQueue.main.async { self.predicate = predicate }
        }
    }

```
