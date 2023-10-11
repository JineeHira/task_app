//
//  GlobalFunctions.swift
//  Life'sAGame
//
//  Created by Shaheer Siddiqui on 11/19/22.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import CoreData

extension UIViewController {
    func clearAllCoreDataExceptUsers() {
        clearTaskCoreData()
        clearTaskIndexCoreData()
        clearRewardIndexCoreData()
        clearRewardCoreData()
    }
    
    func clearTaskCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        var fetchedResults:[NSManagedObject]
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                for result:AnyObject in fetchedResults {
                    context.delete(result as! NSManagedObject)
                }
            }
            saveContext()
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func clearTaskCoreDataforGivenUserEmail(email:String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        var fetchedResults:[NSManagedObject]
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                for result:AnyObject in fetchedResults {
                    if (result as! NSManagedObject).value(forKey: "userEmail") as! String == email {
                        context.delete(result as! NSManagedObject)
                    }
                }
            }
            saveContext()
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func clearTaskIndexCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskIndex")
        var fetchedResults:[NSManagedObject]
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                for result:AnyObject in fetchedResults {
                    context.delete(result as! NSManagedObject)
                }
            }
            saveContext()
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func clearTaskIndexCoreDataForGivenUserEmail(email: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskIndex")
        var fetchedResults:[NSManagedObject]
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                for result:AnyObject in fetchedResults {
                    if (result as! NSManagedObject).value(forKey: "userEmail") as! String == email {
                        context.delete(result as! NSManagedObject)
                    }
                }
            }
            saveContext()
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func clearRewardCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Reward")
        var fetchedResults:[NSManagedObject]
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                for result:AnyObject in fetchedResults {
                    context.delete(result as! NSManagedObject)
                }
            }
            saveContext()
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func clearRewardCoreDataForGivenUserEmail(email: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Reward")
        var fetchedResults:[NSManagedObject]
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                for result:AnyObject in fetchedResults {
                    if (result as! NSManagedObject).value(forKey: "userEmail") as! String == email {
                        context.delete(result as! NSManagedObject)
                    }
                }
            }
            saveContext()
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func clearRewardIndexCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RewardIndex")
        var fetchedResults:[NSManagedObject]
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                for result:AnyObject in fetchedResults {
                    context.delete(result as! NSManagedObject)
                }
            }
            saveContext()
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func clearUserCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        var fetchedResults:[NSManagedObject]
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                for result:AnyObject in fetchedResults {
                    context.delete(result as! NSManagedObject)
                }
            }
            saveContext()
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func clearUserCoreDataForGivenEmail(email: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        var fetchedResults:[NSManagedObject]
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                for result:AnyObject in fetchedResults {
                    if (result as! NSManagedObject).value(forKey: "email") as! String == email {
                        context.delete(result as! NSManagedObject)
                    }
                }
            }
            saveContext()
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func saveContext () {
        if contextTask.hasChanges {
            do {
                try contextTask.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func storeReward(nameR: String, pointValueR: Int32){
        let rewards = NSEntityDescription.insertNewObject(forEntityName: "Reward", into: contextReward)
        
        rewards.setValue(nameR, forKey: "rewardName")
        rewards.setValue(pointValueR, forKey: "rewardPointValue")
        rewards.setValue(userEmail, forKey: "userEmail")
        saveContext()
    }
    
    func retrieveRewards() -> [NSManagedObject]{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Reward")
        var fetchedResults:[NSManagedObject]? = nil
        do {
            try fetchedResults = contextReward.fetch(request) as? [NSManagedObject]
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return(fetchedResults!)
    }
    
    func storeTask(name: String, daily: String, pointValue: Int32){
        let task = NSEntityDescription.insertNewObject(forEntityName: "Task", into: contextTask)
        
        task.setValue(name, forKey: "name")
        task.setValue(daily, forKey: "daily")
        task.setValue(pointValue, forKey: "pointValue")
        task.setValue(userEmail, forKey: "userEmail")
        saveContext()
    }
    
    func retrieveTasks() -> [NSManagedObject]{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        var fetchedResults:[NSManagedObject]? = nil

        do {
            try fetchedResults = contextTask.fetch(request) as? [NSManagedObject]
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return(fetchedResults!)
    }
    
    func storeTaskIndex(index: Int) -> NSManagedObject{
        let indexStored = NSEntityDescription.insertNewObject(forEntityName: "TaskIndex", into: contextTask)
        indexStored.setValue(index, forKey: "index")
        indexStored.setValue(userEmail, forKey: "userEmail")
        saveContext()
        return indexStored
    }
    
    func retrieveTaskIndex() -> [NSManagedObject]{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskIndex")
        var fetchedResults:[NSManagedObject]? = nil

        do {
            try fetchedResults = contextTask.fetch(request) as? [NSManagedObject]
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return(fetchedResults!)
    }
    
    func storeRewardIndex(index: Int) -> NSManagedObject{
        let indexStored = NSEntityDescription.insertNewObject(forEntityName: "RewardIndex", into: contextTask)
        indexStored.setValue(index, forKey: "index")
        indexStored.setValue(userEmail, forKey: "userEmail")
        saveContext()
        return indexStored
    }
    
    func retrieveRewardIndex() -> [NSManagedObject]{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RewardIndex")
        var fetchedResults:[NSManagedObject]? = nil
        do {
            try fetchedResults = contextTask.fetch(request) as? [NSManagedObject]
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return(fetchedResults!)
    }
    
    func storeUser(firstName: String, lastName: String, email: String, userName: String, password: String, profilePhoto: UIImage){
        let newUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: contextTask)
        
        newUser.setValue(firstName, forKey: "firstName")
        newUser.setValue(lastName, forKey: "lastName")
        let lowerCaseEmail = email.lowercased()
        newUser.setValue(lowerCaseEmail, forKey: "email")
        newUser.setValue(userName, forKey: "userName")
        newUser.setValue(0, forKey: "currentPoints")
        newUser.setValue(Date(), forKey: "startDate")
        newUser.setValue(password, forKey: "password")
        newUser.setValue(true, forKey: "doesPlaySound")
        newUser.setValue(profilePhoto.jpegData(compressionQuality: 1.0), forKey: "profilePhoto")
        saveContext()
    }
    
    func storeUserNoPhoto(firstName: String, lastName: String, email: String, userName: String, password: String){
        let newUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: contextTask)
        
        newUser.setValue(firstName, forKey: "firstName")
        newUser.setValue(lastName, forKey: "lastName")
        newUser.setValue(email, forKey: "email")
        newUser.setValue(userName, forKey: "userName")
        newUser.setValue(0, forKey: "currentPoints")
        newUser.setValue(Date(), forKey: "startDate")
        newUser.setValue(password, forKey: "password")
        newUser.setValue(true, forKey: "doesPlaySound")
        saveContext()
    }
    
    func retrieveUser() -> [NSManagedObject]{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        var fetchedResults:[NSManagedObject]? = nil
        do {
            try fetchedResults = contextTask.fetch(request) as? [NSManagedObject]
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return(fetchedResults!)
    }
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
