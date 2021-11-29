//
//  ViewController.swift
//  StudyManager
//
//  Created by Josef Gasewicz on 27/11/2021.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var CategorySelect: NSPopUpButton!
    @IBOutlet weak var CategoryTextField: NSTextField!
    @IBOutlet weak var StudyItemTextField: NSTextField!
    @IBOutlet weak var ImportantCheckBox: NSButton!
    @IBOutlet weak var TableView: NSTableView!
    @IBOutlet weak var DeleteButton: NSButton!
    var categories: [Category] = []
    var studyItems: [StudyItem] = []
    var categorySelectValues: [String] = []
    var selectedCategory: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fp = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print("fp path: \(fp)")
        // db at : /Users/josefgasewicz/Library/Containers/JRG-DEVELOPER-LTD.StudyManager/Data/Library/Application\ Support/StudyManager/
        
        getCategories()
        getStudyItems()
        CategorySelect.removeAllItems()
        if categories.count > 0 {
            for category in categories {
                categorySelectValues.append(category.name!)
            }
            CategorySelect.addItems(withTitles: categorySelectValues)
        }
        if selectedCategory == nil {
            selectedCategory = categories[0]
        }
        
    }
    
    
    @IBAction func CategoryAddButton(_ sender: Any) {
        if CategoryTextField.stringValue != "" {
            if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                let category = Category(context: context)
                category.name = CategoryTextField.stringValue
            }
        }
        (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
        
        CategoryTextField.stringValue = ""
        getCategories()
    }
    
    
    @IBAction func StudyItemButton(_ sender: Any) {
        if StudyItemTextField.stringValue != "" {
            if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                let studyItem = StudyItem(context: context)
                studyItem.name = StudyItemTextField.stringValue
                studyItem.parentCategory = self.selectedCategory
                if ImportantCheckBox.state == NSControl.StateValue.on {
                    studyItem.important = true
                } else {
                    studyItem.important = false
                }
            }
        }
        (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
        
        StudyItemTextField.stringValue = ""
        ImportantCheckBox.state = NSControl.StateValue.off
        getStudyItems()
    }
    
    func getCategories() {
        // Get categories from Core Data
        if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                categories = try context.fetch(Category.fetchRequest())
            } catch {
                print("Error fetching Categories")
            }
        }
        TableView.reloadData()
    }
    
    func getStudyItems() {
        if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                studyItems = try context.fetch(StudyItem.fetchRequest())
            } catch {
                print("Error fetching StudyItems!")
            }
        }
        TableView.reloadData()
    }
    
    // MARK: - TableView Datasource Methods
    // MARK: - TableView Delegate Methods
    // MARK: - Data Manipulation Methods
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return studyItems.count
    }
    
    @IBAction func deleteClickedStudyItem(_ sender: Any) {
        let row = TableView.selectedRow
        let studyItem = studyItems[row]
        if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            context.delete(studyItem)
            (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
            getStudyItems()
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier.rawValue == "importantColumn" {
            // identifire - importColumn
            if let cell = (tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "importantCell"), owner: self) as? NSTableCellView) {
                let studyItem = studyItems[row].important
                if studyItem {
                    cell.textField?.stringValue = " 🚨 "
                } else {
                    cell.textField?.stringValue = ""
                }
                return cell
            }
        } else {
             // identifier - studyItemColumn
            if let cell = (tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "studyItemCell"), owner: self) as? NSTableCellView) {
                let studyItem = studyItems[row].name!
                cell.textField?.stringValue = studyItem
                return cell
            }
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        DeleteButton.isHidden = false
    }
}
