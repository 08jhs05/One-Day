//
//  MainMenuCell.swift
//  One Day
//
//  Created by Jae Ho Shin on 2020-01-11.
//  Copyright © 2020 Jae Ho Shin. All rights reserved.
//

import Foundation
import UIKit

class MainMenuCell: UITableViewCell{
    
    @IBOutlet weak var thumbnail: CirclePieView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
