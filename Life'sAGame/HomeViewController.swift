//
//  HomeViewController.swift
//  Life'sAGame
//
//
//

import UIKit
import CoreData
import Firebase
import FirebaseCore
import FirebaseAuth

let textCellIdentifier = "textCellIdentifier"
let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext

var points: Int = 0
var timeCount: Int = 1

protocol TaskTransfer{
    func taskTransfer(addTasklist:String)}

class HomeViewController: UIViewController,UITableViewDelegate, UITableViewDataSource  {
    
    var todaysTasks:[NSManagedObject] = []
    var hasNewDayStarted = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentPoints: UILabel!
    
    let taskIdentifier = "TaskIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background.PNG")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        
        self.view.insertSubview(backgroundImage, at: 0)
        currentPoints.text = String(user!.value(forKey: "currentPoints") as! Int)
        
        // retrieve current task index
        let allCurrentTaskIndex = retrieveTaskIndex()
        
        // if the index for the current task matches index, add this task to today's task list
        todaysTasks = []
        for index in allCurrentTaskIndex {
            if let currentIndex = index.value(forKey: "userEmail") as! String?, currentIndex == userEmail {
                todaysTasks.append(index)
            }
        }
        let allTasks = retrieveTasks()
        
        // if the index for the current task matches any task in all task list, add this task to all task list
        taskList = []
        for task in allTasks {
            if let currentTask = task.value(forKey: "userEmail") as! String?, currentTask == userEmail {
                taskList.append(task)
            }
        }
        let allRewards = retrieveRewards()
        
        // if current reward matches the reward value, add the reward to the reward list.
        rewardList = []
        for reward in allRewards {
            if let currentRewad = reward.value(forKey: "userEmail") as! String?, currentRewad == userEmail {
                rewardList.append(reward)
            }
        }

        tableView.delegate = self
        tableView.dataSource = self
        
        // check to see if a new day has started
        newDay()
        if hasNewDayStarted == true{
            // readd daily tasks to home page if so
            dailyTaskReset()
            hasNewDayStarted = false
       }
        if user?.value(forKey: "doesPlaySound") as! Bool == false {
            player!.stop()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        currentPoints.text = String(user!.value(forKey: "currentPoints") as! Int)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTaskPage",
           let nextVC = segue.destination as? TaskPageViewController {
            nextVC.delegate = self
            }
        }
    
    // segue to the add task page
    @IBAction func addPressed(_ sender: Any) {
        let viewController = self.tabBarController?.viewControllers?[2] as? TaskPageViewController
            viewController?.delegate = self
        self.tabBarController?.selectedIndex = 1
    }
    
    // segue to the reward page
    @IBAction func rewardPressed(_ sender: Any) {
        let viewController = self.tabBarController?.viewControllers?[3] as? RewardsPageViewController
            viewController?.delegate = self
        self.tabBarController?.selectedIndex = 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todaysTasks.count
    }
    
    // put all relevant values into the table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: taskIdentifier, for: indexPath)
        let row = indexPath.row
        
        // Fetch Task by using the index
        let tempVar = todaysTasks[row].value(forKey: "index") as! Int
        let taskList1 = taskList[todaysTasks[row].value(forKey: "index") as! Int]
        
        // Configure Cell
        cell.textLabel?.text = "\(taskList1.value(forKey: "name")!)"
        cell.detailTextLabel?.text = "Repeats Daily:  \(taskList1.value(forKey: "daily")!) \n  Points: \(taskList1.value(forKey: "pointValue")!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // swipe gesture recognition for delete or complete
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath)-> [UITableViewRowAction]?{
        
        // this is an index rather than a task
        let task = todaysTasks[indexPath.row]
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { UITableViewRowAction, IndexPath in
            contextTask.delete(task)
            self.todaysTasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            self.saveContext()
        }
        
        let completeAction = UITableViewRowAction(style: .normal, title: "Complete") {
            UITableViewRowAction, IndexPath in
            
            // tryng to get a point value of an index rather than a task
            let pointValue = taskList[task.value(forKey: "index") as! Int].value(forKey: "pointValue") as! Int
            var currentPoints = 0
            let userList = self.retrieveUser()
            for possibleUser in userList {
                if possibleUser.value(forKey: "email") as! String == userEmail {
                    user = possibleUser
                }
            }
            
            if user != nil
            {
                currentPoints = user!.value(forKey: "currentPoints") as! Int
            }
            
            user!.setValue(currentPoints + pointValue , forKey: "currentPoints")
            points = user!.value(forKey: "currentPoints") as! Int
            
            self.currentPoints.text = "\(points)"
            contextTask.delete(task)
            self.todaysTasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.saveContext()
        }
        
        completeAction.backgroundColor = .systemBlue
        
        return [deleteAction, completeAction]
    }
    
    func transferTasks(taskIndex: NSManagedObject) {
        self.todaysTasks.append(taskIndex)
        self.tableView.reloadData()
    }
    
    // reset the daily task
    func dailyTaskReset() {
        var count = 0
        for tasks in taskList{
            if tasks.value(forKey: "daily") as! String == "Yes" && todaysTasks.contains(tasks) == false{
                dailyTaskList.append(tasks)
                let newIndex = storeTaskIndex(index: count)
                self.todaysTasks.append(newIndex)
            }
            count += 1
        }
        tableView.reloadData()
    }
    
    // checks if the day has changed since the user last logged in
    func newDay() {
        // fetch specific user
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let get = NSFetchRequest<NSManagedObject>(entityName: "User")
        let predicate = NSPredicate(format: "email == %@", userEmail)
        get.predicate = predicate
        user = try! contextTask.fetch(get).first
        let startDate = user!.value(forKey: "startDate")
        let startDateFinal = dateFormatter.string(from: startDate as! Date)
        let currentDate = dateFormatter.string(from: Date())
        if startDateFinal == currentDate {
            hasNewDayStarted = false
        } else {
            hasNewDayStarted = true
            user!.setValue(Date(), forKey: "startDate")
        }
    }
}
