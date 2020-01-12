//
//  CirclePieView.swift
//  One Day
//
//  Created by Jae Ho Shin on 2020-01-05.
//  Copyright © 2020 Jae Ho Shin. All rights reserved.
//

import Foundation
import UIKit

class CirclePieView: UIView{
    
    @IBOutlet var viewFrame: UIView!
    var events: [Pie] = []
    
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
        let nib = UINib(nibName: "CirclePieView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        viewFrame.frame = bounds
        addSubview(viewFrame)

    }
    
    func addNewSchedule(startTimeHrParam: Int16, startTime: Float, endTime: Float, pieColor: UIColor, name: String){
        let newSchedule = Pie(frameSuper: viewFrame.frame, startTimeHr: startTimeHrParam, radius: viewFrame.frame.width/2, startAngle: CGFloat(360.0*startTime/24.0), endAngle: CGFloat(360.0*endTime/24.0), centerPoint: CGPoint(x: frame.width/2, y: frame.height/2), color: pieColor, name: name)
        
        //print(String(format:"float: %f  angle: %f", startTime, CGFloat(360.0*startTime/24.0)))
        
        events.append(newSchedule)
        self.addSubview(newSchedule)
        
    }
    
    func reset(){
        events.removeAll()
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: bounds.size.height, height: bounds.size.height))
        
        UIColor(red: 246.0/255.0, green: 114.0/255.0, blue: 128.0/255.0, alpha: 1.0).setFill()
        path.fill()

    }
}
