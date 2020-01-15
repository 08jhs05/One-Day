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
    
    var events: [Pie] = []
    var initialframe: CGRect?
    
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
//        let nib = UINib(nibName: "CirclePieView", bundle: nil)
//        nib.instantiate(withOwner: self, options: nil)
        
        initialframe = CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height)
        self.frame = initialframe!
    }
    
    func addNewSchedule(startTimeHrParam: Int16, startTime: Float, endTime: Float, pieColor: UIColor, name: String){
        
        //self.frame = CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height)
        
        let newSchedule = Pie(frameSuper: initialframe!, startTimeHr: startTimeHrParam, radius: initialframe!.width/2.0, startAngle: CGFloat(360.0*startTime/24.0), endAngle: CGFloat(360.0*endTime/24.0), centerPoint: CGPoint(x: initialframe!.width/2.0, y: initialframe!.height/2.0), color: pieColor, name: name)

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
        let path = UIBezierPath(ovalIn: initialframe!)
        
        UIColor(red: 246.0/255.0, green: 114.0/255.0, blue: 128.0/255.0, alpha: 1.0).setFill()
        path.fill()
    }
}
