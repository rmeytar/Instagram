//
//  HomeTableViewCell.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 19/12/2020.
//

import UIKit
import AVFoundation
import KILabel

protocol HomeTableViewCellDelegate {
    func goToCommentVC(postId: String)
    func goToProfileUserVC(userId: String)
    func goToHashTag(tag: String)
}

class HomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: KILabel!
    @IBOutlet weak var heightConstraintPhoto: NSLayoutConstraint!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var volumeButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var delegate: HomeTableViewCellDelegate?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    var user: User? {
        didSet {
            setupUserInfo()
        }
    }
    
    var isMuted = true
    
    func updateView() {
        
        //hashtag
        captionLabel.text = post?.caption
        captionLabel.hashtagLinkTapHandler = { label, string, range in
            print(string)
            let tag = String(string.dropFirst())
            self.delegate?.goToHashTag(tag: tag)
        }

        //user name hashtag
        captionLabel.userHandleLinkTapHandler = { label, string, range in
            print(string)
            let mention = String(string.dropFirst())
            print(mention)
            Api.User.observeUserByUsername(username: mention.lowercased(), completion: { (user) in
                self.delegate?.goToProfileUserVC(userId: user.id!)
            })
        }

        if let ratio = post?.ratio {
            heightConstraintPhoto.constant = UIScreen.main.bounds.size.width / ratio
            layoutIfNeeded()
        }
        
        if let photoUrlString = post?.photoUrl {
            let photoUrl = URL(string: photoUrlString)
            postImageView.sd_setImage(with: photoUrl)
        }
        
        if let videoUrlString = post?.videoUrl , let videoUrl = URL(string: videoUrlString) {
            print("videoUrlString: \(videoUrlString)")
            
            self.volumeView.isHidden = false
            player = AVPlayer(url: videoUrl)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = postImageView.frame
            playerLayer?.frame.size.width = UIScreen.main.bounds.width
            self.contentView.layer.addSublayer(playerLayer!)
            self.volumeView.layer.zPosition = 1
            
            player?.play()
            player?.isMuted = isMuted
        }
        
        if let timestamp = post?.timestamp {
            print(timestamp)
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            
            var timeText = ""
            if diff.second! <= 0 {
                timeText = "Now"
            }
            if diff.second! > 0 && diff.minute! == 0 {
                timeText = (diff.second == 1) ? "\(diff.second!) second ago" : "\(diff.second!) seconds ago"
            }
            if diff.minute! > 0 && diff.hour! == 0 {
                timeText = (diff.minute == 1) ? "\(diff.minute!) minute ago" : "\(diff.minute!) minutes ago"
            }
            if diff.hour! > 0 && diff.day! == 0 {
                timeText = (diff.hour == 1) ? "\(diff.hour!) hour ago" : "\(diff.hour!) hours ago"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0 {
                timeText = (diff.day == 1) ? "\(diff.day!) day ago" : "\(diff.day!) days ago"
            }
            if diff.weekOfMonth! > 0 {
                timeText = (diff.weekOfMonth == 1) ? "\(diff.weekOfMonth!) week ago" : "\(diff.weekOfMonth!) weeks ago"
            }
            
            timeLabel.text = timeText
        }
        
        self.updateLike(post: self.post!)
    }
    
    @IBAction func volumeBtn_TouchUpInside(_ sender: UIButton) {
        if isMuted {
            isMuted = !isMuted
            volumeButton.setImage(UIImage(named: "Icon_Volume"), for: UIControl.State.normal)
        } else {
            isMuted = !isMuted
            volumeButton.setImage(UIImage(named: "Icon_Mute"), for: UIControl.State.normal)
        }
        player?.isMuted = isMuted
    }    
    
    func updateLike(post: Post) {
        let imageName = post.likes == nil || !post.isLiked! ? "like" : "likeSelected"
        likeImageView.image = UIImage(named: imageName)
        guard let count = post.likeCount else {
            return
        }
        if count != 0 {
            likeCountButton.setTitle("\(count) likes", for: UIControl.State.normal)
        } else {
            likeCountButton.setTitle("Be the first to like this", for: UIControl.State.normal)
        }
    }
    
    func setupUserInfo() {
        nameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.text = ""
        captionLabel.text = ""
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.commentImageView_TouchUpInside))
        commentImageView.addGestureRecognizer(tapGesture)
        commentImageView.isUserInteractionEnabled = true
        
        let tapGestureForLikeImageView = UITapGestureRecognizer(target: self, action: #selector(self.likeImageView_TouchUpInside))
        likeImageView.addGestureRecognizer(tapGestureForLikeImageView)
        likeImageView.isUserInteractionEnabled = true
        
        let tapGestureForNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_TouchUpInside))
        nameLabel.addGestureRecognizer(tapGestureForNameLabel)
        nameLabel.isUserInteractionEnabled = true
        
    }
    
    @objc func nameLabel_TouchUpInside() {
        if let id = user?.id {
            delegate?.goToProfileUserVC(userId: id)
        }
    }
    
    //performs the like action
    @objc func likeImageView_TouchUpInside() {
        Api.Post.incrementLikes(postId: post!.id!, onSuccess: { (post) in
            self.updateLike(post: post)
            self.post?.likes = post.likes
            self.post?.isLiked = post.isLiked
            self.post?.likeCount = post.likeCount
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
       // incrementLikes(forRef: postRef)
    }
    
    //display the comments
    @objc func commentImageView_TouchUpInside() {
        print("commentImageView_TouchUpInside")
        if let id = post?.id {
            delegate?.goToCommentVC(postId: id)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("1111")
        volumeView.isHidden = true
        profileImageView.image = UIImage(named: "placeholderImg")
        playerLayer?.removeFromSuperlayer()
        player?.pause()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}


