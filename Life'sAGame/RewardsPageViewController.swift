//
//  RewardsPageViewController.swift
//  Life'sAGame
//
//  Created by Jinee Hira on 11/2/22.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuth
import SwiftUI

let rewardIdentifier = "rewardIdentifier"

protocol addRewards {
    func storeReward(nameR: String, pointValueR: Int32)
}

let appDelegateReward = UIApplication.shared.delegate as! AppDelegate
let contextReward = appDelegate.persistentContainer.viewContext

var rewardList: [NSManagedObject] = []
var hapticBool = false

class RewardsPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, addRewards{
    
    @IBOutlet weak var username: UILabel!
    var delegate: UIViewController!
    var selectedIndex: Int = 0
    var wasSentByEditing = false

    @IBOutlet weak var newRewardButton: UIButton!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var rewardsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        newRewardButton.backgroundColor = UIColor.lightGray
        pointLabel.text = String(points)
        rewardsTableView.delegate = self
        rewardsTableView.dataSource = self
        
    }
    
    // reload core data when the table appears
    override func viewDidAppear(_ animated: Bool) {
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background.PNG")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        
        var allReward = retrieveRewards()
        rewardList = []
        for reward in allReward {
            if reward.value(forKey: "userEmail") as! String == userEmail {
                rewardList.append(reward)
            }
        }

        rewardsTableView.reloadData()
        let currentUser = user as! User
        pointLabel.text = String(currentUser.value(forKey: "currentPoints") as! Int)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rewardList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rewardIdentifier, for: indexPath)
        let row = indexPath.row

        // Configure Cell
        cell.textLabel?.text = "\(rewardList[row].value(forKey: "rewardName")!)"
        cell.detailTextLabel?.text = "\(rewardList[row].value(forKey: "rewardPointValue")!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let reward = rewardList[indexPath.row]
            contextReward.delete(reward)
            rewardList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveContext()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rewardSegueIdentifier",
           let nextVC = segue.destination as? AddRewardViewController {
            nextVC.delegate = self
            if wasSentByEditing {
                nextVC.rewardName = rewardList[selectedIndex].value(forKey: "rewardName") as! String
                nextVC.rewardPoint = String(rewardList[selectedIndex].value(forKey: "rewardPointValue") as! Int)
                nextVC.selectedRowAt = selectedIndex
                nextVC.wasSentByEditing = wasSentByEditing
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showActionSheet(indexPath: indexPath)
        selectedIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    func showActionSheet(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Reward Options", message: "Select an Option", preferredStyle: .actionSheet)
        
        // edit reward
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [self] action in
            wasSentByEditing = true
            self.performSegue(withIdentifier: "rewardSegueIdentifier", sender: self)
 
            }))
        
        // redeem reward
        alert.addAction(UIAlertAction(title: "Redeem Reward", style: .default, handler: { [self] action in
            let reward = rewardList[indexPath.row]
            let pointValueRewards = (rewardList[indexPath.row].value(forKey: "rewardPointValue")!) as! Int
            
            if points < pointValueRewards {
                let controller = UIAlertController(
                    title: "You do not have enough points",
                    message: "Reward not redeemed",
                    preferredStyle: .alert)
                controller.addAction(UIAlertAction(
                    title: "OK",
                    style: .default
                ))
                
                present(controller, animated: true)
                
            } else {
                
                var currentPoints = 0
                
                if user != nil
                {
                    currentPoints = user!.value(forKey: "currentPoints") as! Int
                }
                
                // if haptics in settings is turned on, play haptics
                if hapticBool == true {
                    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                    impactHeavy.impactOccurred()
                }

                user!.setValue(currentPoints - pointValueRewards, forKey: "currentPoints")
                points = user!.value(forKey: "currentPoints") as! Int
                pointLabel.text = String(points)
                context.delete(reward)
                rewardList.remove(at: indexPath.row)
                
                // you have redeemed reward alert
                createLayer()
                
                rewardsTableView.deleteRows(at: [indexPath], with: .fade)
                saveContext()}}))
            
        alert.addAction(UIAlertAction(title: "Delete Reward", style: .destructive, handler: { [self] action in
            
            let reward = rewardList[indexPath.row]
            context.delete(reward)
            rewardList.remove(at: indexPath.row)
            rewardsTableView.deleteRows(at: [indexPath], with: .fade)
            saveContext()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
        }))
        present(alert, animated: true)
    }
    
    // creates the confetti animation
    func createLayer () {
        let layer = CAEmitterLayer()
        layer.emitterPosition = CGPoint(x: view.center.x, y: -100)
        
        let colors: [UIColor] = [
            .systemRed,
            .systemBlue,
            .systemOrange,
            .systemGreen,
            .systemPink,
            .systemYellow,
            .systemPurple]
        
        let cells: [CAEmitterCell] = colors.compactMap {
            let cell = CAEmitterCell()
            cell.scale = 0.05
            cell.emissionRange = .pi * 2
            cell.lifetime = 15
            cell.birthRate = 100
            cell.velocity = 150
            cell.color = $0.cgColor
            cell.contents = UIImage(named: "whiteSquare")!.cgImage
            return cell
        }
        
        layer.emitterCells = cells
        
        view.layer.addSublayer(layer)
        
        // reward redeemed alert
        let controller = UIAlertController(
            title: "Congrats!!",
            message: "You have redeemed a reward!!",
            preferredStyle: .alert)
        controller.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: {action in layer.removeFromSuperlayer()}
        ))
        present(controller, animated: true)
    }
}
                                      
                                      
                                      
                                    
