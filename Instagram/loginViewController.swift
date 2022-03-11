//
//  loginViewController.swift
//  Instagram
//
//  Created by Brian Velecela on 3/10/22.
//

import UIKit
import Parse

class loginViewController: UIViewController {

    //outlets
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //sign in action
    @IBAction func onSignIn(_ sender: Any) {
        //we are creating variables for username and password
        let username = usernameField.text!
        let passwaord = passwordField.text!
        
        //if there is a username and password
        PFUser.logInWithUsername(inBackground: username, password: passwaord) { (user, error) in
            //if usrer is not empty
            if user != nil{
                //move on to the next screen
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }else{
                print ("Error: \(error?.localizedDescription)")
            }
        }
    }
    
    //sign up action
    @IBAction func onSignUp(_ sender: Any) {
        //look through parse ios documentation in google and look over users.
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
        
        //attempting to sign up
        user.signUpInBackground { (success, error) in
            //if success, move on
            if success{
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                
            }else{
                print ("Error: \(error?.localizedDescription)")
            }
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
