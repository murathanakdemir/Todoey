//
//  ViewController.swift
//  Todoey
//
//  Created by Murathan Akdemir on 21.04.2019.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    var itemArray = [Item]()

    let dataFilePath = FileManager.default.urls(for: .documentDirectory , in: .userDomainMask).first?.appendingPathComponent("Item.plist")
    
    @IBOutlet weak var searchBar: UISearchBar!
    let defaults = UserDefaults.standard
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //table data sources
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    
    }
    
    //Table Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let doneState: Bool = itemArray[indexPath.row].done
        
        itemArray[indexPath.row].done = !doneState
        
        saveItems()
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func addPressButton(_ sender: UIBarButtonItem) {
        var textField = UITextField();
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add New Item", style: .default) { (action) in
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveItems()
            
            
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Item Name"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print(error)
        }
        self.tableView.reloadData()
    }
    
    func loadItems(request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print(error)
        }
        
        self.tableView.reloadData()
    }
    
    
    
}

extension ToDoListViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count != 0 {
            let request : NSFetchRequest<Item> = Item.fetchRequest()
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
            request.predicate = predicate
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            loadItems(request: request,predicate: predicate)
        } else {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
        
    }
}

