//
//  SettingTableViewController.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 31/12/2020.
//

import UIKit

protocol SettingTableViewControllerDelegate {
    func updateUserInfo()
}

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var delegate: SettingTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Edit Profile"
        usernameTextField.delegate = self
        emailTextField.delegate = self
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        Api.User.observeCurrentUser { (user) in
            self.usernameTextField.text = user.username
            self.emailTextField.text = user.email
            if let profileUrl = URL(string: user.profileImageUrl!) {
                self.profileImageView.sd_setImage(with: profileUrl)
            }
        }
    }
    
    @IBAction func saveBtn_TouchUpInside(_ sender: Any) {
        if let profileImg = self.profileImageView.image, let imageData = profileImg.jpegData(compressionQuality: 0.1) {
            ProgressHUD.show("Waiting...")
            AuthService.updateUserInfo(username: usernameTextField.text!, email: emailTextField.text!, imageData: imageData, onSuccess: {
                ProgressHUD.showSuccess("Success")
                self.delegate?.updateUserInfo()
            }, onError: { (errorMessage) in
                ProgressHUD.showError(errorMessage)
            })
        }
    }
    
    @IBAction func logoutBtn_TouchUpInside(_ sender: Any) {
        AuthService.logOut(onSuccess: {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let  signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
    
    @IBAction func chaneProfileBtn_TouchUpInside(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
}

extension SettingTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("did finish picking media")
        
        if let image = info[UIImagePickerController.InfoKey.originalImage.self] as? UIImage {
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

extension SettingTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("return")
        textField.resignFirstResponder()
        return true
    }
}
