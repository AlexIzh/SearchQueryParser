# SearchQueryParser
Parsing search string and generate predicates or filtering blocks from it.

#### Public API isn't latest version and will be updated later. Current version of API is ugly, I know.

Current framework allows to use logical operators with search (like `SearchKit`). But only you don't need to generate `Index` file for using it.

Goal of this framework is generating one `NSPredicate`, closure, another filtering entities for using them for searching in array, database or any other sources.

Default entities supports `AND, &`, `OR, |`, `NOT, !` operators, but you can create custom operators yourself.

Default query operators (from highest to lowest precedence):

Operator | Meaning 
 --- | --- 
 `NOT`, ! | Boolean NOT. 
 `AND`, &, `<space>` | Boolean AND. The <space> character represents a Boolean operator when there are terms to both sides of the <space> character. In this case, <space> represents a Boolean AND by default, or a Boolean OR if specified by .spaceMeansOR option. 
 `OR`, &#124; | Boolean inclusive OR. 


## Example

iOS (Generating blocks for using `array.filter(_:)`) and Mac (generating `NSPredicate` for using with `CoreData`)

<img src="https://github.com/AlexIzh/SearchQueryParser/blob/master/Gifs/ios.gif" width="200"/> <img src="https://github.com/AlexIzh/SearchQueryParser/blob/master/Gifs/mac.gif" width="600"/>




## Using

It's pretty easy! You just need to create builder and define predicate/block for one token(small part of search string), after it you can generate predicates/blocks from any string.

Example with blocks:
```swift
import SearchQueryParser

let builder = DefaultFilterBlockBuilder<Item>(options: .caseInsensitive, valuePredicate: { str in
	return { $0.searchString.lowercased().contains(str.lowercased()) }
})

let filterBlock = builder.build(from: searchText)
filteredItems = array.filter(filterBlock ?? {_ in true})
```
Example with `NSPredicate`:
```swift
import SearchQueryParser

let builder = DefaultPredicateBuilder() { NSPredicate(format: "(name LIKE[c] %@) OR (job LIKE[c] %@)", $0, $0) }
self.predicate = builder.build(from: searchField.stringValue)
```
