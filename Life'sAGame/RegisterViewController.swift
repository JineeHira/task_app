//
//  RegisterViewController.swift
//  Life'sAGame
//
//  Created by Shaheer Siddiqui on 10/15/22.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import CoreData
import AVFoundation

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    // label normally invisible but if user messed up in registration changes
    @IBOutlet weak var passwordNotMatchLabel: UILabel!
    // button to change whether password text is secure or not
    @IBOutlet weak var passwordIsVisible: UIButton!
    // all required fields not filled out
    @IBOutlet weak var somethingMissingLabel: UILabel!
    
    var delegate: UIViewController!
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // makes password and confirm password not visible
        passwordTF.isSecureTextEntry = true
        confirmPasswordTF.isSecureTextEntry = true
        // give outline to button to change password visibility
        passwordIsVisible.layer.borderColor = UIColor.black.cgColor
        passwordIsVisible.backgroundColor = UIColor.white
        
        // make image view a circle
        profilePhotoImageView.layer.borderWidth = 1
        profilePhotoImageView.layer.masksToBounds = false
        profilePhotoImageView.layer.borderColor = UIColor.black.cgColor
        
        // This will change with corners of image and height/2 will make this circle shape
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.frame.height/2
        profilePhotoImageView.clipsToBounds = true
        
        picker.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
         view.addGestureRecognizer(tapGesture)
        profilePhotoImageView.image = UIImage(named: "Default User Image.jpeg")
    }
        
    @IBAction func registerButtonPressed(_ sender: Any) {
        if passwordTF.text! != confirmPasswordTF.text!{
            somethingMissingLabel.text = "Password does not match"
            somethingMissingLabel.textColor = UIColor.red
            return
        }
        else if emailTF.text == "" || passwordTF.text == nil || confirmPasswordTF.text == nil {
            somethingMissingLabel.text = "All required fields have not been filled"
            somethingMissingLabel.textColor = UIColor.red
            return
        }
        else {
            let mainVC = delegate as! ViewController
            mainVC.registered(email: emailTF.text!, password: passwordTF.text!)

            Auth.auth().createUser(withEmail: emailTF.text!, password: passwordTF.text!) {
                authResult, error in
                if let error = error as NSError? {
                    self.somethingMissingLabel.text = "\(error.localizedDescription)"
                    self.somethingMissingLabel.textColor = UIColor.red
                } else {
                    self.somethingMissingLabel.text = ""
                    if self.profilePhotoImageView.image != UIImage(named: "Default User Image.jpeg") {
                        self.storeUser(firstName: self.firstNameTF.text!, lastName: self.lastNameTF.text!, email: self.emailTF.text!, userName: self.usernameTF.text!, password: self.passwordTF.text!, profilePhoto: self.profilePhotoImageView.image!)
                    } else {
                        self.storeUserNoPhoto(firstName: self.firstNameTF.text!, lastName: self.lastNameTF.text!, email: self.emailTF.text!, userName: self.usernameTF.text!, password: self.passwordTF.text!)
                    }
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    // if cancel button clicked go back to login screen
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func passwordIsVisibleButtonPressed(_ sender: Any) {
        // if password is secure make it unsecure and vice versa
        if passwordIsVisible.backgroundColor == UIColor.blue {
            passwordTF.isSecureTextEntry = true
            confirmPasswordTF.isSecureTextEntry = true
            passwordIsVisible.backgroundColor = UIColor.white
        }
        else if passwordIsVisible.backgroundColor == UIColor.white {
            passwordTF.isSecureTextEntry = false
            confirmPasswordTF.isSecureTextEntry = false
            passwordIsVisible.backgroundColor = UIColor.blue
        }
    }
    
    @IBAction func addPhotoButtonPressed(_ sender: Any) {
        showActionSheet()
    }
    
    // picks image from library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[.originalImage] as! UIImage
        profilePhotoImageView.image = chosenImage
        self.dismiss(animated: true)
    }
    
    // choosing a profile picture
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
}
