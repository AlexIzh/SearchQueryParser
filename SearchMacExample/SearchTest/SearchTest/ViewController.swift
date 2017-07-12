//
//  ViewController.swift
//  SearchTest
//
//  Created by Alex Severyanov on 12/07/2017.
//  Copyright © 2017 alexizh. All rights reserved.
//

import Cocoa
import OSXSearchQueryParser

extension Array {
	func randomItem() -> Element {
		let index = Int(arc4random_uniform(UInt32(self.count)))
		return self[index]
	}
}

class ViewController: NSViewController {
	
	@IBOutlet var arrayController: NSArrayController!
	@IBOutlet var searchField: NSSearchField!
	
	@IBOutlet var nameField: NSTextField!
	@IBOutlet var ageField: NSTextField!
	@IBOutlet var jobField: NSTextField!
	
	@IBOutlet var moreButton: NSButton!
	@IBOutlet var lessButton: NSButton!
	@IBOutlet var equalButton: NSButton!
	
	dynamic var predicate: NSPredicate?
	dynamic var managedObjectContext: NSManagedObjectContext!
	
	let factory = DefaultSearchQueryFactory()
	var builder: DefaultPredicateBuilder!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		managedObjectContext = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
		// Do any additional setup after loading the view.
		let generate = false
		if generate {
			let names = ["Emma", "Olivia", "Liam", "Noah", "Ava", "Mia", "Aria", "Oliver", "Logan"]
			let jobs = ["iOS Developer", "Android Developer", "Web Developer", "Data scientist", "CEO"]
			(NSApp.delegate as! AppDelegate).persistentContainer.performBackgroundTask {
				for _ in 0...20 {
					let entity = Entity(context: $0)
					entity.name = names.randomItem()
					entity.job = jobs.randomItem()
					entity.age = Int32(arc4random_uniform(UInt32(90)) + 10)
				}
				try? $0.save()
			}
		}
		
		builder = DefaultPredicateBuilder() {
			if let age = Int32($0) {
				if self.moreButton.state == NSOnState {
					return NSPredicate(format: "age > %d", age)
				} else if self.lessButton.state == NSOnState {
					return NSPredicate(format: "age < %d", age)
				}
				return NSPredicate(format: "age = %d", age)
			} else {
				return NSPredicate(format: "(name LIKE[c] %@) OR (job LIKE[c] %@)", $0, $0)
			}
		}
		
		arrayController.fetch(nil)
	}

	@IBAction func radioButton(_ sender: Any?) {
		search()
	}
	
	@IBAction func addEntity(_ sender: Any?) {
		guard let age = Int32(ageField.stringValue), !nameField.stringValue.isEmpty && !jobField.stringValue.isEmpty
			else { return }
		
		(NSApp.delegate as! AppDelegate).persistentContainer.performBackgroundTask {
			let entity = Entity(context: $0)
			entity.name = self.nameField.stringValue
			entity.age = age
			entity.job = self.jobField.stringValue
			
			try? $0.save()
			
			self.arrayController.performSelector(onMainThread: #selector(NSArrayController.fetch(_:)), with: nil, waitUntilDone: false)
		}
	}
	
	func search() {
		predicate = factory.makeQuery(for: searchField.stringValue).queryOperators.first.map { builder.build(from: $0) } ?? nil
	}
}

extension ViewController: NSSearchFieldDelegate {
	override func controlTextDidChange(_ obj: Notification) {
		search()
	}
}

