//
//  ProfileTableViewCell.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 11/12/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit
import CloudKit

// MARK: -  Declaration
class ProfileTableViewCell: UITableViewCell {

    // MARK: -  Outlets
    @IBOutlet weak var profileCellTextField: UITextView!
    @IBOutlet weak var dots: UILabel!
    
    var selectedStory:Story?
    var dao = DAOManager.instance?.ckMyStories


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileCellTextField.isEditable = false
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }


    var myIndexPath:IndexPath? {
        guard let superView = self.superview as? UITableView else {
            debugPrint("superview is not a UITableView - getIndexPath")
            return nil
        }
        let indexPath = superView.indexPath(for: self)
        return indexPath
    }

    var myProfileView:Profile? {
        guard let superView = self.superview as? UITableView else {
            debugPrint("superview is not a UITableView")
            return nil
        }
        guard let profileView = superView.superview?.parentViewController as? Profile else {
            debugPrint("not a profile descendant")
            return nil
        }
        return profileView
    }

}

// MARK: -  Extension
extension UIResponder {
    public var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}
