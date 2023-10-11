//
//  AddRewardViewController.swift
//  Life'sAGame
//
//  Created by Jinee Hira on 11/2/22.
//

import UIKit
let identifier = String(describing: AddRewardViewController.self)
class AddRewardViewController: UIViewController {

    var delegate: UIViewController!
    @IBOutlet weak var rewardTextField: UITextField!
    @IBOutlet weak var pointValueTextField: UITextField!
    
    var rewardName: String = ""
    var rewardPoint: String = ""
    var selectedRowAt: Int = 0
    var wasSentByEditing = false
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background.PNG")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        
        pointLabel.text = String(points)
        rewardTextField.text = rewardName
        pointValueTextField.text = rewardPoint
    }
    
    @IBAction func addButton(_ sender: Any) {
        // check to make sure all items are selected
        if rewardTextField.text == "" {
            let controller = UIAlertController(
                title: "Missing Name",
                message: "Please enter a name.",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                title: "OK",
                style: .default))
            present(controller, animated: true)
        } else if pointValueTextField.text == nil {
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
            let rewardVC = delegate as! RewardsPageViewController
            if wasSentByEditing {
                rewardList[selectedRowAt].setValue(rewardTextField.text!, forKey: "rewardName")
                rewardList[selectedRowAt].setValue(Int32(pointValueTextField.text!), forKey: "rewardPointValue")
                rewardVC.wasSentByEditing = false
            } else {
                rewardVC.storeReward(nameR: rewardTextField.text!, pointValueR: Int32(pointValueTextField.text!)!)
                rewardVC.wasSentByEditing = false
            }
            rewardVC.rewardsTableView.reloadData()
        }
    }
}
