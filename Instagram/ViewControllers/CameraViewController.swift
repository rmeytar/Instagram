//
//  CameraViewController.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 08/12/2020.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class CameraViewController: UIViewController {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var removeButton: UIBarButtonItem!
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPhoto))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handlePost()
    }
    
    //disable the share button if photo is not picked
    func handlePost() {
        if selectedImage != nil {
            self.shareButton.isEnabled = true
            self.removeButton.isEnabled = true
            self.shareButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }else {
            self.shareButton.isEnabled = false
            self.removeButton.isEnabled = false
            self.shareButton.backgroundColor = .lightGray
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func handleSelectPhoto() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
 
    @IBAction func shareButton_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show("Waiting...", interaction: false)
        if let profileImg = self.selectedImage, let imageData = profileImg.jpegData(compressionQuality: 0.1) {
            let photoIdString = NSUUID().uuidString
            print(photoIdString)
            let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(photoIdString)
            storageRef.putData(imageData, metadata: nil, completion: {(metadata, error) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                storageRef.downloadURL(completion: { (url,error) in
                    let photoUrl = url?.absoluteString
                    self.sendDataToDatabase(photoUrl: photoUrl!)
                })
            })
        } else {
            ProgressHUD.showError("profile Image can't be empty")
        }
    }
    
    @IBAction func remove_TouchUpInside(_ sender: Any) {
        clean()
        handlePost()
    }
    
    
    func sendDataToDatabase(photoUrl: String) {
        let ref = Database.database().reference()
        let postsReference = ref.child("posts")
        let newPostId = postsReference.childByAutoId().key
        let newPostReference = postsReference.child(newPostId!)
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let currentUserId = currentUser.uid
        newPostReference.setValue(["uid": currentUserId, "photoUrl": photoUrl, "caption": captionTextView.text!], withCompletionBlock: {
            (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            ProgressHUD.showSuccess("Success")
            
            //clear the text box - after successfully uploading a photo
            //clear the photo - after successfully uploading a photo
            //showing the home tab after successfully uploading a photo
            self.clean()
            self.tabBarController?.selectedIndex = 0
            
        })
    }
    
    func clean() {
        self.captionTextView.text = ""
        self.photo.image = UIImage(named: "placeholder-photo")
        self.selectedImage = nil
    }
    
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("did finish picking media")
        
        if let image = info[UIImagePickerController.InfoKey.originalImage.self] as? UIImage {
            selectedImage = image
            photo.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}
