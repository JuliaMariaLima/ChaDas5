//
//  FeedTableViewCell.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 08/12/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit
import CloudKit

class FeedTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var feedTableViewTextField: UITextView!
    @IBOutlet weak var sensitiveImage: UIImageView!
    @IBOutlet weak var sensitiveContentLabel: UILabel!
    @IBOutlet weak var sensitiveLabel: UILabel!
    @IBOutlet weak var seeStoryButton: UIButton!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var sensitiveView: UIView!
    
    @IBOutlet weak var dots: UILabel!
    
    
    enum CellType {
        case yourStory
        case otherStory
    }
    
    
    var user: User? = nil
    var type: CellType = .otherStory
    let dao = DAOManager.instance?.ckStories
    var isFlaged = false
    var storyID:String?
    var myAuthor:String?
    
    
    override func layoutSubviews() {
        sensitiveView.addSubview(sensitiveContentLabel)
        sensitiveView.addSubview(sensitiveImage)
        sensitiveView.addSubview(sensitiveLabel)
        sensitiveView.addSubview(seeStoryButton)
        sensitiveView.alpha = 1
        //dots.isHidden = true

    }
    
    func myStory() {
        if let _ = user,
            type == .yourStory {
            feedTableViewTextField.backgroundColor = UIColor.middleOrange
            
        }
    }
    
    func otherStory() {
        if let _ = user,
            type == .yourStory {
            feedTableViewTextField.backgroundColor = UIColor.baseOrange
            
        }
    }
    
    
    
    @IBAction func seeStory(_ sender: Any) {
        
        sensitiveView.isHidden = true
        
    }
    
}
