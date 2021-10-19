//
//  DetailTableViewController.swift
//  NotedTasks
//
//  Created by Odirile Kekana on 2021/10/01.
//

import UIKit

class DetailTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var delegate: SaveItem?
    var editTitle: String?
    var editDesc: String?
    var editPri: String?
    var editDate: String?
    var pri: String?
    var indexPath: NSIndexPath?
    
    var dateFormatter = DateFormatter()

    @IBOutlet weak var taskText: UITextField!
    @IBOutlet weak var dsecText: UITextView!
    @IBOutlet weak var pickerText: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var picker = UIPickerView()
    
    let pickerArray = ["High", "Medium", "Low"]
    let colors = [UIColor.red, UIColor.orange, UIColor.green]
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        taskText.text = editTitle
        dsecText.text = editDesc
        pickerText.text = pri
        
        dateFormatter.dateFormat = "MM/dd/yy"
        if editDate != nil {
            let date = dateFormatter.date(from: editDate!)
            let calendar = Calendar.current
            let components = calendar.dateComponents([.month, .day, .year], from: date!)
            let finalDate = calendar.date(from: components)
            datePicker.date = finalDate!
        }
        
        picker.delegate = self
        picker.dataSource = self
        
        pickerText.inputView = picker
        pickerText.textAlignment = .center
        pickerText.placeholder = "Select priority"
        
            
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        
        let newPri = Task(context: context)
        let title = taskText.text!
        let dsec = dsecText.text!
        datePicker.datePickerMode = UIDatePicker.Mode.date
        dateFormatter.dateFormat = "MMMM dd, yyyy 'at' HH:mm"
        let selectedDate = dateFormatter.string(from: datePicker.date)
        let date = selectedDate
        
        if pickerText.text != "" {
           // newPri.color = colors[count]
        if pickerText.text == "Low" {
            newPri.order = 0
        }
        if pickerText.text == "Medium" {
            newPri.order = 1
        }
        if pickerText.text == "High" {
            newPri.order = 2
        }
        let priority = pickerText.text!
        delegate?.saveTasks(by: self, title: title, desc: dsec, priority: priority, date: date ,at: indexPath)
        
        
        }
        saveContext()
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerText.text = pickerArray[row]
        //pickerText.textColor = colors[row]
        count = row
        pickerText.resignFirstResponder()
        
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let ret = NSAttributedString(string: pickerArray[row])
        return ret
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        }
        else {
            navigationController?.popViewController(animated: true)
        }
    }
    func saveContext() {
        do {
            try context.save()
        }
        catch {
            print("error")
        }
    }
   
}
