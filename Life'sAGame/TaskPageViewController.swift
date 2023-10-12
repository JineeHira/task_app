//
//  TaskPageViewController.swift
//  Life'sAGame
//
//

import UIKit
import CoreData
import Firebase
import FirebaseAuth
let taskIdentifier = "taskIdentifier"

protocol addTasks {
    func storeTask (name: String, daily:String, pointValue: Int32)
}

let appDelegateTask = UIApplication.shared.delegate as! AppDelegate
let contextTask = appDelegate.persistentContainer.viewContext

var taskList: [NSManagedObject] = []
var dailyTaskList: [NSManagedObject] = []

class TaskPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var delegate: UIViewController!

    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var newTaskButton: UIButton!
    @IBOutlet weak var username: UILabel!
    
    var wasSentByEditing = false
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newTaskButton.backgroundColor = UIColor.lightGray
        taskTableView.delegate = self
        taskTableView.dataSource = self
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "Back", style: .plain, target: nil, action: nil)
        pointLabel.text = String(points)
    }
    
    // reload core data when the table appears
    override func viewDidAppear(_ animated: Bool) {
        let get = NSFetchRequest<NSManagedObject>(entityName: "Task")
        taskList = try! contextTask.fetch(get)
        
        var tempTaskList:[NSManagedObject] = []
        for tasks in taskList{
            if tasks.value(forKey: "userEmail") as! String == userEmail {
                tempTaskList.append(tasks)
            }
        }
        taskList = tempTaskList
        
        // add daily tasks to the daily task list
        for tasks in taskList{
            if tasks.value(forKey: "daily") as! String == "Yes" && dailyTaskList.contains(tasks) == false{
                dailyTaskList.append(tasks)
            }
        }
        taskTableView.reloadData()
        let currentUser = user as! User
        pointLabel.text = String(currentUser.value(forKey: "currentPoints") as! Int)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "taskSegue",
           let nextVC = segue.destination as? AddTaskViewController {
            nextVC.delegate = self
        }
        
        // allows for editing of a task
        if segue.identifier == "taskSegue",
           let nextVC = segue.destination as? AddTaskViewController {
            nextVC.delegate = self
            if wasSentByEditing {
                nextVC.rewardName = taskList[selectedIndex].value(forKey: "name") as! String
                nextVC.rewardPoint = String(taskList[selectedIndex].value(forKey: "pointValue") as! Int)
                nextVC.daily = taskList[selectedIndex].value(forKey: "daily") as! String
                nextVC.selectedRowAt = selectedIndex
                nextVC.wasSentByEditing = wasSentByEditing
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: taskIdentifier, for: indexPath)
        let row = indexPath.row
        
        // Configure Cell
        cell.textLabel?.text = "\(taskList[row].value(forKey: "name")!)"
        cell.detailTextLabel?.text = "Repeats Daily: \(taskList[row].value(forKey: "daily")!) \n  Points: \(taskList[row].value(forKey: "pointValue")!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showActionSheet(indexPath: indexPath)
        selectedIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func showActionSheet(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Task Options", message: "Select an Option", preferredStyle: .actionSheet)
        
        // edit task
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { action in
            self.wasSentByEditing = true
            self.performSegue(withIdentifier: "taskSegue", sender: self)
        }))
        
        // add a task to home page
        alert.addAction(UIAlertAction(title: "Add to Home Page", style: .default, handler: { [self](action) in
            let otherVC = self.tabBarController?.viewControllers?[0] as! HomeViewController
            let newIndex = storeTaskIndex(index: indexPath.row)
            otherVC.todaysTasks.append(newIndex)}))

        // delete a task
        alert.addAction(UIAlertAction(title: "Delete Task", style: .destructive, handler: { [self](action) in
            
            let otherVC = self.tabBarController?.viewControllers?[0] as! HomeViewController
            
            // remove from taskList
            let task = taskList[indexPath.row]
            context.delete(task)
            taskList.remove(at: indexPath.row)
            taskTableView.deleteRows(at: [indexPath], with: .fade)
            saveContext()
            
            // delete task from todays tasks
            var deletedIndex: NSManagedObject?
            
            for index in otherVC.todaysTasks {
                if index.value(forKey: "index") as! Int == indexPath.row {
                    deletedIndex = index
                    otherVC.todaysTasks.remove(at: otherVC.todaysTasks.firstIndex(of: index)!)
                }
            }
            if deletedIndex != nil {
                context.delete(deletedIndex!)
            }
            
            // loops through todaystasks and updates index of those with index greater then that of deleted task
            for index in otherVC.todaysTasks {
                // if the index was grater then the index of the thing deleted index went down by one thus must subtract one from index
                if index.value(forKey: "index") as! Int > indexPath.row {
                    index.setValue(index.value(forKey: "index") as! Int - 1, forKey: "index")
                }
            }
            saveContext()
        }))
        
        // cancel alert
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
        }))
        present(alert, animated: true)
    }
}
