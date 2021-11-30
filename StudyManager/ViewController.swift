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
    @IBOutlet weak var tableName: NSTextField!
    
    var categories : [Category] = []
    var studyItems : [StudyItem] = []
    var categorySelectValues : [String] = []
    var selectedCategory : Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fp = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print("fp path: \(fp)")
        // db at : /Users/josefgasewicz/Library/Containers/JRG-DEVELOPER-LTD.StudyManager/Data/Library/Application\ Support/StudyManager/
        CategorySelect.removeAllItems()
        getCategories()
        selectedCategory = categories[0]
        let name = selectedCategory?.name
        tableName.stringValue = name!
        getStudyItems(selectedCategoryName: selectedCategory?.name)
    }
    
    @IBAction func CategoryAddButton(_ sender: Any) {
        var newCategory : Category?
        if CategoryTextField.stringValue != "" {
            if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                newCategory = Category(context: context)
                newCategory?.name = CategoryTextField.stringValue
            }
        }
        (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
        
        CategoryTextField.stringValue = ""
        getCategories()
        if newCategory != nil {
            // After save the new category set the PopUpButton's selected value
            for (index, category) in categories.enumerated() {
                if category.name == newCategory?.name! {
                    CategorySelect.selectItem(at: index)
                }
            }
            // Update the selected category
            self.selectedCategory = newCategory
        }
        // Update table name
        tableName.stringValue = (newCategory?.name)!
        // Update the table
        getStudyItems(selectedCategoryName: newCategory?.name)
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
    
    func getCategories() -> Void {
        if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
            self.categories = try context.fetch(Category.fetchRequest())
            } catch {
                print("Error fetching Categories")
            }
        }
        for category in self.categories {
            categorySelectValues.append(category.name!)
        }
        CategorySelect.removeAllItems()
        CategorySelect.addItems(withTitles: categorySelectValues)

        TableView.reloadData()
        return
    }
    
    func getStudyItems(selectedCategoryName : String? = nil) -> Void {
        let categoryName = selectedCategoryName != nil ? selectedCategoryName : selectedCategory?.name
        if categoryName == nil {
            return
        }
        // Get studyItems by parent category from Core Data
        if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fetchRequest = NSFetchRequest<StudyItem>(entityName: "StudyItem")
                let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", categoryName!)
                fetchRequest.predicate = categoryPredicate
                self.studyItems = try context.fetch(fetchRequest)
            } catch {
                print("Error fetching study items")
            }
        }
        TableView.reloadData()
        return
    }
    
    
    @IBAction func categoryItemDidChange(_ sender: Any) {
        let selectedCategoryTitle = CategorySelect.selectedItem?.title
        for category in categories {
            if category.name == selectedCategoryTitle {
                self.selectedCategory = category
            }
        }
        getStudyItems(selectedCategoryName : selectedCategoryTitle)
        tableName.stringValue = selectedCategoryTitle!
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
            DeleteButton.isHidden = true
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
