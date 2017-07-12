//
//  ViewController.swift
//  SearchTest
//
//  Created by Alex Severyanov on 07/07/2017.
//  Copyright © 2017 alexizh. All rights reserved.
//

import UIKit
import SearchQueryParser

class ViewController: UIViewController {

	var array: [Item] = []
	var filteredItems: [Item] = [] {
		didSet {
			tableView?.reloadData()
		}
	}
	
	@IBOutlet var tableView: UITableView!
	
	let factory = DefaultSearchQueryFactory(isCaseSensetive: false)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		array = [
			Item(color: "red", fruit: "apple"),
			Item(color: "green", fruit: "apple"),
			Item(color: "blue", fruit: "apple"),
			
			Item(color: "red", fruit: "orange"),
			Item(color: "green", fruit: "orange"),
			Item(color: "blue", fruit: "orange"),
			
			Item(color: "red", fruit: "banana"),
			Item(color: "green", fruit: "banana"),
			Item(color: "blue", fruit: "banana"),
			
		]
		
		filteredItems = array
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	class Item: NSObject {
		let color: String
		let fruit: String
		
		dynamic var searchString: String
		init(color: String, fruit: String) {
			self.color = color; self.fruit = fruit
			searchString = color + " " + fruit
		}
	}
}

extension ViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		let builder = DefaultFilterBlockBuilder<Item>(valuePredicate: { str in return { $0.searchString.lowercased().contains(str.lowercased()) }})
		let filterBlock = factory.makeQuery(for: searchText).queryOperators.first.map({ builder.build(from: $0) }) ?? { (Item) -> Bool in return true }
		filteredItems = array.filter(filterBlock)
	}
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredItems.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		cell.textLabel?.text = filteredItems[indexPath.row].searchString
		return cell
	}
}

