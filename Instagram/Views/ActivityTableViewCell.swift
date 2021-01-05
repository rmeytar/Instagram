//
//  ActivityTableViewCell.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 04/01/2021.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//    }

}
