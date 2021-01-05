//
//  ActivityViewController.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 08/12/2020.
//

import UIKit

class ActivityViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
}

extension ActivityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as! ActivityTableViewCell
        cell.nameLabel.text = "Helen"
        cell.profileImage.image = UIImage(named: "placeholderImg")
        return cell
    }
}
