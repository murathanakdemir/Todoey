//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Murathan Akdemir on 25.04.2019.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }
    
    // MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destination.selectedCategory = self.categoryArray[indexPath.row]
        }
        
    }
    
    // MARK: - Data manipulation methods
    
    
    func saveCategories() {
        do {
            try context.save()
        } catch  {
            print(error)
        }
        self.tableView.reloadData()
    }
    
    func loadCategories(request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryArray = try context.fetch(request)
        } catch  {
            print(error)
        }
        self.tableView.reloadData()
    }
    
    @IBAction func addPressButton(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "New Category", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Add New Category", style: .default) { (alertAction) in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categoryArray.append(newCategory)
            self.saveCategories()
            
            
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Category Name"
            textField = alertTextField
        }
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
}
