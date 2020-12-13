//
//  SignInViewController.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 07/12/2020.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //רקע שקוף לתיבת הטקסט אימייל,רמת שקיפות של הגדרת הטקסט אימייל
        emailTextField.backgroundColor = UIColor.clear
        emailTextField.tintColor = UIColor.white
        emailTextField.textColor = UIColor.white
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        let bottomLayerEmail = CALayer()
        bottomLayerEmail.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        bottomLayerEmail.backgroundColor = UIColor(red: 55/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        emailTextField.layer.addSublayer(bottomLayerEmail)
        
        //רקע שקוף לתיבת הטקסט סיסמה,רמת שקיפות של הגדרת הטקסט סיסמה
       passwordTextField.backgroundColor = UIColor.clear
       passwordTextField.tintColor = UIColor.white
       passwordTextField.textColor = UIColor.white
       passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
       let bottomLayerPassword = CALayer()
       bottomLayerPassword.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
       bottomLayerPassword.backgroundColor = UIColor(red: 55/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
       passwordTextField.layer.addSublayer(bottomLayerPassword)
        
        handleTextField()
        
    }
    
    func handleTextField() {
        
        emailTextField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    //if one of this is empty - we disable the sign up button.
    @objc func textFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            signInButton.setTitleColor(.lightText, for: UIControl.State.normal)
            signInButton.isEnabled = false
            return
        }
        signInButton.setTitleColor(.white, for: UIControl.State.normal)
        signInButton.isEnabled = true
        
    }

    @IBAction func signInButton_TouchUpInside(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { authResult, error in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            self.performSegue(withIdentifier: "signInToTabbarVC", sender: nil)
        })
    }
}
