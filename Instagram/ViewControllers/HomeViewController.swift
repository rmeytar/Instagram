//
//  HomeViewController.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 08/12/2020.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var posts = [Post]()
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        loadPosts()
    }
    
    func loadPosts() {
        activityIndicatorView.startAnimating()
        Database.database().reference().child("posts").observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let newPost = Post.transformPostPhoto(dict: dict)
                self.fetchUser(uid: newPost.uid!, completed: {
                    self.posts.append(newPost)
                    self.activityIndicatorView.stopAnimating()
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict)
                self.users.append(user)
                completed()
            }
        })
    }
    
    @IBAction func logout_TouchUpInside(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let  signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)
        } catch let logoutError {
            print(logoutError)
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        cell.post = post
        cell.user = user
        return cell
    }
}











//    @IBAction func logout_TouchUpInside(_ sender: Any) {
//        do{
//            try Auth.auth().signOut()
//        } catch let logoutError {
//            print(logoutError)
//        }
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let  signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
//        self.present(signInVC, animated: true, completion: nil)
//    }

