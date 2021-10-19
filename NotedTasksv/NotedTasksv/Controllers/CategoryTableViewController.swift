//
//  CategoryTableViewController.swift
//  NotedTasks
//
//  Created by Odirile Kekana on 2021/10/01.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    var sectionName = ["Incomplete", "Complete"]
    
    var categories = [Category]()
    var comp = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    @IBAction func addBtnTapped(_ sender: Any) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.category = textField.text!
            
            self.categories.append(newCategory)
            
            self.saveCategories()
            self.tableView.reloadData()
            
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows: Int?
        if section == 0 {
            rows = categories.count
        }
        else {
            rows = comp.count
        }
        return rows!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CatCell", for: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = categories[indexPath.row].category
        }
        else {
            cell.textLabel?.text = comp[indexPath.row].category
        }
      
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionName[section]
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in
            
            if indexPath.section == 0 {
            let item = self.categories[indexPath.row]
            self.context.delete(item)
            }
            else {
                let item = self.comp[indexPath.row]
                self.context.delete(item)
            }
            self.saveCategories()
            self.loadCategories()
            tableView.reloadData()
        }
        
        if indexPath.section == 0 {
            let done = UIContextualAction(style: .normal, title: "Done") { _,_,_ in
                if indexPath.section == 0 {
                    self.categories[indexPath.row].done = true
                }
                else {
                self.comp[indexPath.row].done = true
                }
                self.saveCategories()
                self.loadCategories()
                tableView.reloadData()
            }
            done.backgroundColor = UIColor.green
            let swipe = UISwipeActionsConfiguration(actions: [delete, done])
            return swipe
        }
        else {
            let swipe = UISwipeActionsConfiguration(actions: [delete])
            return swipe
        }
        
    }



    func saveCategories() {
         do {
             try self.context.save()
         } catch {
             print(error)
         }
     }
     
     func loadCategories() {
         
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
         
         do{
             let result = try context.fetch(request)
            let resultArray = result as! [Category]
            
            categories = [Category]()
            comp = [Category]()
            
            for item in resultArray {
                if item.done == false {
                    categories.append(item)
                }
                else {
                    comp.append(item)
                }
            }
         } catch {
             print("Error loading categories \(error)")
         }
     }
}
