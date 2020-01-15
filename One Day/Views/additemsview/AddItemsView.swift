//
//  AddItemsView.swift
//  One Day
//
//  Created by Jae Ho Shin on 2020-01-04.
//  Copyright © 2020 Jae Ho Shin. All rights reserved.
//

import Foundation
import UIKit

class AddItemsView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var hideBar: UIView!
    @IBOutlet weak var collapseBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var expandBtn: UIButton!
    @IBOutlet weak var eventsTable: UITableView!
    
    let originalViewWidth:CGFloat = 350
    let originalViewHeight:CGFloat = 240
    let collapsedViewHeight:CGFloat = 40
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    func initSubviews() {
        // standard initialization logic
        
        let nib = UINib(nibName: "AddItemsView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        contentView.layer.cornerRadius = 15

    }
    
    @IBAction func CollapseBtn(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            self.contentView.frame = CGRect( x: self.contentView.frame.origin.x, y: self.contentView.frame.origin.y - self.originalViewHeight + self.collapsedViewHeight, width: self.originalViewWidth, height: self.originalViewHeight)
        }
        collapseBtn.isHidden = false
        addBtn.isHidden = false
        expandBtn.isHidden = true
    }
    
    @IBAction func CloseBtn(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            self.contentView.frame = CGRect( x: self.contentView.frame.origin.x, y: self.contentView.frame.origin.y + self.contentView.frame.height, width: self.originalViewWidth, height: -self.collapsedViewHeight)
        }
        collapseBtn.isHidden = true
        addBtn.isHidden = true
        expandBtn.isHidden = false
    }
    
    @IBAction func addNewEvent(_ sender: Any) {
 
    }
    
}

//extension UIView{
//    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
//         let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//         let mask = CAShapeLayer()
//         mask.path = path.cgPath
//         self.layer.mask = mask
//    }
//}
