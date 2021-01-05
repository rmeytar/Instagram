//
//  ActivityViewController.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 08/12/2020.
//

import UIKit

class ActivityViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var notifications = [Notifications]()
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNotifications()
       
    }
    
    func loadNotifications() {
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        Api.Notifications.observeNotifications(withId: currentUser.uid, completion: {
            notifi in
            guard let uid = notifi.from else {
                return
            }
            
            self.fetchUser(uid: uid, completed: {
                self.notifications.insert(notifi, at: 0)
                self.tableView.reloadData()
            })
        })
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        Api.User.observeUser(withId: uid, completion: {
            user in
            self.users.insert(user, at: 0)
            completed()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Activity_DetailSegue" {
            let detailVC = segue.destination as! detailViewController
            let postId = sender as! String
            detailVC.postId = postId
        }
//        if segue.identifier == "Activity_ProfileSegue" {
//            let detailVC = segue.destination as! ProfileUserViewController
//            let postId = sender as! String
//            profileVC.userId = userId
//        }
//        if segue.identifier == "Activity_CommentSegue" {
//            let detailVC = segue.destination as! CommentViewController
//            let postId = sender as! String
//            commentVC.postId = postId
//        }
    }
}


extension ActivityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as! ActivityTableViewCell
        let notifi = notifications[indexPath.row]
        let user = users[indexPath.row]
        cell.notifi = notifi
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension ActivityViewController: ActivityTableViewCellDelegate {
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "Activity_DetailSegue", sender: postId)
    }
}
