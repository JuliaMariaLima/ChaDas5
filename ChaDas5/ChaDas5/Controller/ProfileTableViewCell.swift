//
//  ProfileTableViewCell.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 11/12/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit
import CloudKit

class ProfileTableViewCell: UITableViewCell {

    //outlets
    @IBOutlet weak var profileCellTextField: UITextView!
    @IBOutlet weak var deleteButton: UIButton!

    var selectedStory:Story?
    
    var dao = DAOManager.instance?.ckMyStories


    //actions
    @IBAction func deleteButton(_ sender: Any) {

        guard let selected = myIndexPath?.row else {
            return
        }

        if myProfileView?.currentSegment == 0 {

            self.selectedStory = Story(from: (dao?.nonActiveStories[selected])!, completion: { (story, error) in
                if error == nil && story != nil {
                    print("success")
                }
            })

        }

        else{

            self.selectedStory = Story(from: (dao?.activeStories[selected])!, completion: { (story, error) in
                if error == nil && story != nil {
                    print("success")
                }
            })

        }

        let alert = UIAlertController(title: "Deseja mesmo excluir esse relato?", message: "Essa ação não poderá ser desfeita.", preferredStyle: .alert)

        let cancelar = UIAlertAction(title: "Cancelar", style: .default ) { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
//        alert.addAction(excluir)
        alert.addAction(cancelar)
        myProfileView!.present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor.buttonOrange


}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileCellTextField.isEditable = false
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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




extension UIResponder {
    public var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}
