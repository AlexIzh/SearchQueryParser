# SearchQueryParser
Parsing search string and generate predicates or filtering blocks from it.

#### Public API isn't latest version and will be updated later. Current version of API is ugly, I know.

Current framework allows to use logical operators with search (like `SearchKit`). But only you don't need to generate `Index` file for it. 

Factory supports custom operators, but also you can use default factory with next operators:
1/ AND, & 
2/ OR, |
3/ NOT, !

Also, you can configure case sensitive for operators (for example, supports "and", "or", "not" also).  


## Example

iOS (Generating blocks for using `array.filter(_:)`)
![iOS](https://github.com/AlexIzh/SearchQueryParser/blob/master/Gifs/ios.gif)

Mac (generating `NSPredicate` for using with `CoreData`)
![Mac](https://github.com/AlexIzh/SearchQueryParser/blob/master/Gifs/mac.gif)
