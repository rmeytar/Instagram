//
//  HomeViewController.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 08/12/2020.
//

import UIKit
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
        Api.Feed.observeFeed(withId: Api.User.CURRENT_USER!.uid) { (post) in
            guard let postUid = post.uid else {
                return
            }
            self.fetchUser(uid: postUid, completed: {
                self.posts.insert(post, at: 0)
                self.tableView.reloadData()
            })
        }
        
        //remove photos from the home view of people i unfollowd
        Api.Feed.observeFeedRemoved(withId: Api.User.CURRENT_USER!.uid) { (post) in
            self.posts = self.posts.filter { $0.id != post.id }
            self.users = self.users.filter { $0.id != post.id }
            self.tableView.reloadData()
        }
    }

    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        Api.User.observeUser(withId: uid, completion: {
            user in
            self.users.insert(user, at: 0)
            completed()
        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        if segue.identifier == "Home_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
        if segue.identifier == "Home_HashTagSegue" {
            let hashTagVC = segue.destination as! HashTagViewController
            let tag = sender as! String
            hashTagVC.tag = tag
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
        cell.delegate = self
        return cell
    }
}

extension HomeViewController: HomeTableViewCellDelegate {
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "CommentSegue", sender: postId)
    }
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Home_ProfileSegue", sender: userId)
    }
    func goToHashTag(tag: String) {
        performSegue(withIdentifier: "Home_HashTagSegue", sender: tag)
    }
}

