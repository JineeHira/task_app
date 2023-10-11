//
//  SettingsViewController.swift
//  Life'sAGame
//
//  Created by Jinee Hira on 10/26/22.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import AVFoundation

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var delegate: UIViewController!
    var hasEditProfileBeenClicked = false
    
    @IBOutlet weak var soundMode: UISwitch!
    @IBOutlet weak var hapticsMode: UISwitch!
    @IBOutlet weak var notifications: UISwitch!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var editProfileButton: UIButton!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        firstName.text = user?.value(forKey: "firstName") as? String
        lastName.text = user?.value(forKey: "lastName") as? String
        userName.text = user?.value(forKey: "userName") as? String
        if firstName.text! == "" {
            firstName.text = "First Name"
        }
        if lastName.text! == "" {
            lastName.text = "Last Name"
        }
        if userName.text! == "" {
            userName.text = "User Name"
        }

        if user?.value(forKey: "doesPlaySound") as! Bool {
            soundMode.setOn(true, animated: true)
        }
        else {
            soundMode.setOn(false, animated: true)
        }
        notifications.setOn(false, animated: false)
        hapticsMode.setOn(false, animated: false)
        
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.black.cgColor
        
        //This will change with corners of image and height/2 will make this circle shape
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
    
        firstNameTF.text = firstName.text
        lastNameTF.text = lastName.text
        userNameTF.text = userName.text
        
        firstNameTF.isHidden = true
        lastNameTF.isHidden = true
        userNameTF.isHidden = true
        imageView.image = UIImage(named: "Default User Image.jpeg")
        if user?.value(forKey: "profilePhoto") != nil {
            guard let image = UIImage(data: user?.value(forKey: "profilePhoto") as! Data) else {
                return
            }
            imageView.image = image
        }
    }
    
    // turns on and off sound
    @IBAction func soundSwitch(_ sender: Any) {
        if soundMode.isOn == false {
            player!.stop()
            user?.setValue(false, forKey: "doesPlaySound")
        } else {
            player!.play()
            user?.setValue(true, forKey: "doesPlaySound")
        }
    }
    
    // turns on and off local notifications
    @IBAction func notificationsSwitch(_ sender: Any) {
        // permission for local notifications
        UNUserNotificationCenter.current().requestAuthorization(options:
                                                                    [.alert]) {
            granted, error in
            if granted {
                print("All set!")
                
            }
            else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Complete some tasks today!"
        content.body = "Complete a task to redeem a reward!"
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "myNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
        
    }
    
    // turns on and off haptics
    @IBAction func hapticsModeSwitch(_ sender: Any) {
        if hapticsMode.isOn == false {
            hapticBool = false
        } else {
            hapticBool = true
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            user = nil
            self.dismiss(animated: true,  completion: { () in
                let homeVC = viewControllerDelegate as! ViewController
                homeVC.appTitle.alpha = 0.0
                UIView.animate (withDuration: 3.0, animations: {homeVC.appTitle.alpha = 1.0})
            })
        } catch {
            print("Sign out error")
        }
    }
    
    @IBAction func takeNewPhotoButtonPressed(_ sender: Any) {
        showActionSheet()
    }
    
    @IBAction func editProfileButtonPressed(_ sender: Any) {
        if hasEditProfileBeenClicked == false {
            
            firstNameTF.isHidden = false
            lastNameTF.isHidden = false
            userNameTF.isHidden = false
            firstName.isHidden = true
            lastName.isHidden = true
            userName.isHidden = true
            
            editProfileButton.setTitle("Save Profile", for: .normal)
            hasEditProfileBeenClicked = true
        }
        else if hasEditProfileBeenClicked == true {
            // Set label texts
            firstName.text = firstNameTF.text
            lastName.text = lastNameTF.text
            userName.text = userNameTF.text
            
            firstNameTF.isHidden = true
            lastNameTF.isHidden = true
            userNameTF.isHidden = true
            firstName.isHidden = false
            lastName.isHidden = false
            userName.isHidden = false
            
            // store value to core data
            user?.setValue(firstNameTF.text!, forKey: "firstName")
            user?.setValue(lastNameTF.text!, forKey: "lastName")
            user?.setValue(userNameTF.text!, forKey: "userName")
            
            editProfileButton.setTitle("Edit Profile", for: .normal)
            hasEditProfileBeenClicked = false
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[.originalImage] as! UIImage

        imageView.image = chosenImage
        user?.setValue(chosenImage.jpegData(compressionQuality: 1.0), forKey: "profilePhoto")
        self.dismiss(animated: true)
    }
    
    func showActionSheet() {
        let alert = UIAlertController(title: "Image Options", message: "Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [self](action) in
            picker.allowsEditing = false
            picker.sourceType = .photoLibrary
            present(picker, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [self](action) in
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                // we have a rear camera
                switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .notDetermined:
                    AVCaptureDevice.requestAccess(for: .video) {
                        accessGranted in
                        guard accessGranted == true else { return }
                    }
                case .authorized:
                    break
                default:
                    print("Access Denied")
                    return
                }
                picker.allowsEditing = false
                picker.sourceType = .camera
                picker.cameraCaptureMode = .photo
                present(picker, animated: true)
            } else {
                // no camera is available
                let alertVC = UIAlertController(title: "No Camera",
                                                message: "Sorry, this device doesn't have a rear camera",
                                                preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK",
                                             style: .default)
                alertVC.addAction(okAction)
                present(alertVC, animated: true)
            }
        }))
        present(alert, animated: true)
    }
    
    @IBAction func deleteAccountButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Do you want to delete this account?",
            message: "You cannot undo this action",
            preferredStyle: .alert)
        controller.addAction(UIAlertAction(
            title: "Cancel",
            style: .default
        ))
        controller.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: { (action) in
                self.clearTaskCoreDataforGivenUserEmail(email: Auth.auth().currentUser?.value(forKey: "email") as! String)
                self.clearTaskIndexCoreDataForGivenUserEmail(email: Auth.auth().currentUser?.value(forKey: "email") as! String)
                self.clearRewardCoreDataForGivenUserEmail(email: Auth.auth().currentUser?.value(forKey: "email") as! String)
                self.clearUserCoreDataForGivenEmail(email: Auth.auth().currentUser?.value(forKey: "email") as! String)
                Auth.auth().currentUser?.delete()
                user = nil
                self.dismiss(animated: true)
            }
        ))
        present(controller, animated: true)
    }
    
    @IBAction func changePasswordButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Change Password",
            message: "",
            preferredStyle: .alert)
        controller.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel))
        controller.addTextField(configurationHandler: {
            (textField:UITextField!) in
            textField.placeholder = "Enter Current Password"
        })
        controller.addTextField(configurationHandler: {
            (textField:UITextField!) in
            textField.placeholder = "Enter New Password"
        })
        controller.addTextField(configurationHandler: {
            (textField:UITextField!) in
            textField.placeholder = "Confirm New Password"
        })
        controller.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: {
                error in
                if let textFieldArray = controller.textFields {
                    let textFields = textFieldArray as [UITextField]
                    let oldPasswrod = textFields[0].text
                    let newPassword:String
                    
                    if oldPasswrod == (user?.value(forKey: "password") as! String) {
                        if textFields[1].text != nil {
                            if textFields[1].text == textFields[2].text {
                                newPassword = textFields[1].text!
                                Auth.auth().currentUser?.updatePassword(to: newPassword, completion:  { (error) in
                                    if let error = error as NSError? {
                                        self.present(controller, animated: true)
                                        controller.message = "\(error.localizedDescription)"
                                    } else {
                                        user?.setValue(newPassword, forKey: "password")
                                    }
                                })
                            } else {
                                self.present(controller, animated: true)
                                controller.message = "Passwords are not the same"
                            }
                        } else {
                            self.present(controller, animated: true)
                            controller.message = "Password is empty"
                        }
                    } else {
                        self.present(controller, animated: true)
                        controller.message = "Incorrect current password"
                    }
                }
            }))
        present(controller, animated: true)
    }
}
