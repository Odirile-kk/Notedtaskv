//
//  TaskTableViewController.swift
//  NotedTasks
//
//  Created by Odirile Kekana on 2021/10/01.
//

import UIKit
import CoreData
import EventKit
import UserNotifications

class TaskTableViewController: UITableViewController, SaveItem, TaskTableViewCellDelegate, UNUserNotificationCenterDelegate {
    
    
    
    var taskArray = [Task]()
    
//    var done = [Done]()
    var tasks: Task!
    
    var remind: DetailTableViewController!
    
    var eventStore: EKEventStore!
    var reminders: [EKReminder]!

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    var indexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchTasks()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if (granted) {
                print("granted")
            }else {
                UserNotification.shared.showAlertMessage(vc: self, titleStr: "", messageStr: "\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.GetRemindersData()
    }
    
    func GetRemindersData() {
        // 1
        self.eventStore = EKEventStore()
        self.reminders = [EKReminder]()
        self.eventStore.requestAccess(to: .reminder) { (granted, error) in
            
        if granted {
                // 2
            let predicate = self.eventStore.predicateForReminders(in: nil)
            self.eventStore.fetchReminders(matching: predicate, completion: { (reminders: [EKReminder]?) -> Void in

                self.reminders = reminders
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        } else {
            UserNotification.shared.showAlertMessage(vc: self, titleStr: "", messageStr: "The app is not permitted to access reminders, make sure to grant permission in the settings and try again")
        }
      }
    }
    
    func addTasks(_ title: String) {
        let newTask = Task(context: context)
        newTask.title = title
        save()
    }

    @IBAction func checkBtnTapped(_ sender: Any) {
        
    }
    
    
    @IBAction func addBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "AddDetail", sender: sender)
    }
    
    func checkBoxToggle(sender: TaskTableViewCell) {
        if let selectedIndexPath = tableView.indexPath(for: sender) {
            taskArray[selectedIndexPath.row].done = !taskArray[selectedIndexPath.row].done
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
//            saveTasks(by: DetailTableViewController, title: title!, desc: desc!, priority: priority!, at: selectedIndexPath as NSIndexPath)
        }
    }
    
    
    func cancelBtnTapped(by controller: DetailTableViewController) {
        dismiss(animated: true, completion: nil)
    }
    // MARK: - Table view data source
 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return taskArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TaskTableViewCell
       
        let item = taskArray[indexPath.row]
        cell.taskLbl.text = item.title
        cell.descLbl.text = item.desc
        cell.pickBtn.setTitle(item.priority, for: .normal)
        cell.checkBtn.isSelected = taskArray[indexPath.row].done
        cell.date.text = taskArray[indexPath.row].date
       

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        taskArray[indexPath.row].done = !taskArray[indexPath.row].done
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        save()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddDetail" {
            let navigationController = segue.destination as! UINavigationController
            let detailTableViewConroller = navigationController.topViewController as! DetailTableViewController
            detailTableViewConroller.delegate = self
            
            if (sender as? NSIndexPath) != nil {
                let indexPath = sender as! NSIndexPath
                let item = taskArray[indexPath.row]
                detailTableViewConroller.editTitle = item.title!
                detailTableViewConroller.editDesc = item.desc!
                detailTableViewConroller.editPri = item.priority!
                detailTableViewConroller.editDate = item.date!
                detailTableViewConroller.indexPath = indexPath
            }
            }
        }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 167
    }
   
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in
            // delete item at indexPath
            let item = self.taskArray[indexPath.row]
            //func that save to the deleted
            self.context.delete(item)
            
            self.save()
            self.taskArray.remove(at: indexPath.row)
            tableView.reloadData()
        }
        
//        let edit = UIContextualAction(style: .normal, title: "Edit") {_,_,_ in
//
//            prepare(for: <#T##UIStoryboardSegue#>, sender: self)
     //   }
        
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        
        return swipe
    }
    
    
    
    //MARK: - ------ Manage Notifications ------------
    func SetNotifications(remi : EKReminder) {
        print("button tapped")
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: remi.title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: remi.notes ?? "", arguments: nil)
        
        content.sound = .default
        
        let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.day, .month, .year, .hour, .minute, .second], from: self.remind.datePicker.date)

        var dateComponent = DateComponents()
        dateComponent.hour = dateComponents.hour
        dateComponent.minute = dateComponents.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        
        // Create the request object.
        let request = UNNotificationRequest(identifier: remi.title, content: content, trigger: trigger)
        
        // Schedule the request.
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    func removenotifications(remi : EKReminder) {
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: [remi.title])
        center.removePendingNotificationRequests(withIdentifiers: [remi.title])
    }
    
    // UNUserNotificationCenterDelegates
    internal func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(notification.request.content.title)
        // Play a sound.
//        completionHandler(UNNotificationPresentationOptions.sound)
        completionHandler([.banner, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.title)
    }
    
    
    func saveTasks(by controller: DetailTableViewController, title: String, desc: String, priority: String, date: String, at indexPath: NSIndexPath?) {
        if let index = indexPath {
            taskArray[index.row].title = title
            taskArray[index.row].desc = desc
            taskArray[index.row].priority = priority
        }
        else {
            let item = NSEntityDescription.insertNewObject(forEntityName: "Task", into: context) as! Task
            item.title = title
            item.desc = desc
            item.priority = priority
            item.date = date
            taskArray.append(item)
            print(taskArray)
        }
        
        save()
        
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func fetchTasks() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        let sort1 = NSSortDescriptor(key: "order", ascending: false)
        request.sortDescriptors = [sort1]
        do {
            let result = try context.fetch(request)
            taskArray = result as! [Task]
        } catch {
            print(error)
        }
    }
    
    func save() {
        do {
            try context.save()
        }
        catch{
            print(error)
        }
        //tableView.reloadData()
    }
}


