//
//  SignUpViewController.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 07/12/2020.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //רקע שקוף לתיבת הטקסט שם משתמש,רמת שקיפות של הגדרת הטקסט שם משתמש
        usernameTextField.backgroundColor = UIColor.clear
        usernameTextField.tintColor = UIColor.white
        usernameTextField.textColor = UIColor.white
        usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        let bottomLayerUsername = CALayer()
        bottomLayerUsername.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        bottomLayerUsername.backgroundColor = UIColor(red: 55/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        usernameTextField.layer.addSublayer(bottomLayerUsername)
        
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
        
        //עיגול תמונת פרופיל
        profileImage.layer.cornerRadius = 40
        profileImage.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.handleSelectProfileImageView))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
    
      handleTextField()
        
    }
    
    func handleTextField() {
        usernameTextField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
        emailTextField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
     
    //if one of this is empty - we disable the sign up button.
    @objc func textFieldDidChange() {
        guard let username = usernameTextField.text, !username.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            signUpButton.setTitleColor(.lightText, for: UIControl.State.normal)
            signUpButton.isEnabled = false
            return
        }
        signUpButton.setTitleColor(.white, for: UIControl.State.normal)
        signUpButton.isEnabled = true
        
    }
    
    @objc func handleSelectProfileImageView() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    //מעבר מעמוד סיין אפ לעמוד סיין אין
    @IBAction func dismiss_onClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpBtn_touchUpInside(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { authResult, error in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            let uid = authResult?.user.uid
            let storageRef = Storage.storage().reference(forURL: "gs://instagram-f48fa.appspot.com").child("profile_image").child(uid!)
        
            if let profileImg = self.selectedImage, let imageData = profileImg.jpegData(compressionQuality: 0.1) {
                storageRef.putData(imageData, metadata: nil, completion: {(metadata, error) in
                    if error != nil {
                        return
                    }
                    storageRef.downloadURL(completion: { (url,error) in
                        let profileImageUrl = url?.absoluteString
                        self.setUserInformation(profileImageUrl: profileImageUrl!, username: self.usernameTextField.text!, email: self.usernameTextField.text!, uid: uid!)
                    })
                })
            }
        })
    }
    
    func setUserInformation(profileImageUrl: String, username: String, email: String, uid: String){
            let ref = Database.database().reference()
            let usersReference = ref.child("users")
        let newUserReference = usersReference.child(uid)
            newUserReference.setValue(["username": username, "email": email, "profileImageUrl": profileImageUrl ])
        self.performSegue(withIdentifier: "signUnToTabbarVC", sender: nil)
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("did finish picking media")
        
        if let image = info[UIImagePickerController.InfoKey.originalImage.self] as? UIImage {
            selectedImage = image
            profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}
