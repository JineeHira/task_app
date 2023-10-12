//
//  AddTaskViewController.swift
//  Life'sAGame
//
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth

class AddTaskViewController: UIViewController {
    
    var delegate: UIViewController!
    var daily = "Yes"
    var rewardName: String = ""
    var rewardPoint: String = ""
    var selectedRowAt: Int = 0
    var wasSentByEditing = false
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var pointValueField: UITextField!
    @IBOutlet weak var dailySelector: UISegmentedControl!
    @IBOutlet weak var username: UILabel!
    
    override func viewDidLoad() {
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background.PNG")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        
        super.viewDidLoad()
        pointsLabel.text = String(points)
        taskNameField.text = rewardName
        pointValueField.text = rewardPoint
    }
    
    @IBAction func dailySelection(_ sender: Any) {
        switch dailySelector.selectedSegmentIndex {
        case 0:
            daily = "Yes"
        case 1:
            daily = "No"
        default:
            daily = "Yes"
        }
    }
    
    @IBAction func addPressed(_ sender: Any) {
        // check to make sure all items are selected
        if taskNameField.text == "" {
            let controller = UIAlertController(
                title: "Missing Name",
                message: "Please enter a name.",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                title: "OK",
                style: .default))
            present(controller, animated: true)
        } else if daily == "" {
            let controller = UIAlertController(
                title: "Repeating Choice Missing",
                message: "Please choose whether the task repeats daily.",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                title: "OK",
                style: .default))
            present(controller, animated: true)
        } else if pointValueField.text == nil {
            let controller = UIAlertController(
                title: "Point Value is 0",
                message: "Do you want the point value to be zero?",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                title: "Yes",
                style: .default))
            controller.addAction(UIAlertAction(
                title: "No",
                style: .default))
            present(controller, animated: true)
        } else {
            let otherVC = delegate as! TaskPageViewController
            if wasSentByEditing {
                taskList[selectedRowAt].setValue(taskNameField.text!, forKey: "name")
                taskList[selectedRowAt].setValue(Int32(pointValueField.text!), forKey: "pointValue")
                otherVC.wasSentByEditing = false
            } else {
                otherVC.storeTask(name: taskNameField.text!, daily: daily, pointValue: Int32(pointValueField.text!)!)
                otherVC.taskTableView.reloadData()
            }
        } 
    }
}
