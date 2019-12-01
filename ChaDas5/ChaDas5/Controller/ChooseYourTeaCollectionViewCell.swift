//
//  ChooseYourTeaCollectionViewCell.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 13/12/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit

// MARK: -  Declaration
class ChooseYourTeaCollectionViewCell: UICollectionViewCell {
    
    // MARK: -  Outlets
    @IBOutlet weak var chooseYourteaImage: UIImageView!
    @IBOutlet weak var chooseYourTeaLabel: UILabel!
    
    static let shared = ChooseYourTeaCollectionViewCell()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
