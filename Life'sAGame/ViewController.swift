//  ViewController.swift
//  Life'sAGame
//
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import CoreData
import CoreMotion
import AVFoundation

var userEmail: String  = "###nothing###"
var usernameGlobal: String = ""
var user:NSManagedObject?
var player: AVAudioPlayer?

var viewControllerDelegate: UIViewController!

class ViewController: UIViewController {

    // outlets for where username password typed
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var appTitle: UILabel!
    var manager = CMMotionManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sets custom background image
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background.PNG")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        
        // Give username and password textfields background text
        emailTF.placeholder = "Enter your Email"
        passwordTF.placeholder = "Enter your password"
        // make it so you cant read password
        passwordTF.isSecureTextEntry = true
        
        // restarts animation
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressRecognizer(recognizer:)))
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // title fades in
        self.appTitle.alpha = 0.0
        UIView.animate (withDuration: 3.0, animations: {self.appTitle.alpha = 1.0})
        let urlString = Bundle.main.path(forResource: "audio", ofType: "mp3")
        
        // audio starts
        do{
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            guard let urlString = urlString else {
                return
            }
            
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlString))
            
            guard let player = player else{
                return
            }
            player.play()
        } catch{
            print("something went wrong")
        }
    }
    
    func registered(email:String, password:String) {
        emailTF.text = email
        passwordTF.text = password
    }
    
    // login path
    @IBAction func loginButtonPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTF.text!, password: passwordTF.text!) {
            authResult, error in
            if let error = error as NSError? {
                self.errorMessage.text = "\(error.localizedDescription)"
                self.errorMessage.textColor = UIColor.red
            } else {
                let users = self.retrieveUser()
                let emailInputLowered = self.emailTF.text!.lowercased()
                userEmail = emailInputLowered
                for possibleUser in users {
                    if possibleUser.value(forKey: "email") as! String == userEmail {
                        user = possibleUser
                        break
                    }
                }
                if user != nil {
                    self.emailTF.text = ""
                    self.passwordTF.text = ""
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                } else {
                    
                    self.errorMessage.text = "There is no user record corresponding to this identifier. The user may have been deleted"
                    self.errorMessage.textColor = UIColor.red
                    do {
                        try Auth.auth().signOut()
                        self.dismiss(animated: true)
                    } catch {
                        print("Sign out error")
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registerSegue",
           let registerVC = segue.destination as? RegisterViewController {
            registerVC.delegate = self
            errorMessage.text = ""
        }
        
        if segue.identifier == "loginSegue"{
            viewControllerDelegate = self
        }
    }
    
    @IBAction func longPressRecognizer(recognizer: UILongPressGestureRecognizer) {
        self.appTitle.alpha = 0.0
        UIView.animate (withDuration: 3.0, animations: {self.appTitle.alpha = 1.0})
    }
}
