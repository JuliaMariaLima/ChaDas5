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
    
    
    enum CellType {
        case yourStory
        case otherStory
    }
    
    
    var user: User? = nil
    var type: CellType = .otherStory
    
    
    func myStory() {
        if let user = user,
            type == .yourStory {
            feedTableViewTextField.backgroundColor = UIColor.middleOrange
        }
    }
    
    func otherStory() {
        if let user = user,
            type == .yourStory {
            feedTableViewTextField.backgroundColor = UIColor.baseOrange
        }
    }

    

    
    
    

}
