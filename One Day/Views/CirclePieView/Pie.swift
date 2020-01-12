//
//  Pie.swift
//  One Day
//
//  Created by Jae Ho Shin on 2020-01-05.
//  Copyright © 2020 Jae Ho Shin. All rights reserved.
//

import Foundation
import UIKit

class Pie: UIView{
    var startTimeHr: Int16?
    var radius: CGFloat?
    var startAngle: CGFloat?
    var endAngle: CGFloat?
    var centerPoint: CGPoint?
    var color: UIColor?
    var name: String?
    
    var nameLabel: UILabel?
    
    init(frameSuper: CGRect, startTimeHr:Int16, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, centerPoint: CGPoint, color: UIColor, name: String) {
        
        super.init(frame: frameSuper)
        
        self.startTimeHr = startTimeHr
        self.radius = radius
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.centerPoint = centerPoint
        self.color = color
        self.name = name
        
        var midAngle:CGFloat = 0.0
        
        if(endAngle < startAngle){

            midAngle = ((startAngle - 360.0) + endAngle)/2.0
        }
        else{
            midAngle = startAngle + (endAngle - startAngle)/2.0}
        
        let labelAnglePosition = 90.0 - midAngle + 360.0
//        print(name)
//        print(self.frame.width)
//        print(self.frame.height)
        let lablePositionX = centerPoint.x + (radius*2.0/3.0) * cos(labelAnglePosition.degreesToRadians)
        let lablePositionY = centerPoint.y - (radius*2.0/3.0) * sin(labelAnglePosition.degreesToRadians)
        
        let nameLabel = UILabel(frame: CGRect(x: lablePositionX - frameSuper.width/4.0, y: lablePositionY - frameSuper.height/10.0, width: frameSuper.width/2.0, height: frameSuper.height/5.0))
        nameLabel.text = name
        nameLabel.textAlignment = .center
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont(name: "DIN Alternate", size: 24)
        
        self.addSubview(nameLabel)
        self.backgroundColor = UIColor.clear
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        color?.setFill()
        
        let midPath = UIBezierPath()
        midPath.move(to: centerPoint!)
        midPath.addArc(withCenter: centerPoint!, radius: radius!, startAngle: (startAngle! - 90).degreesToRadians, endAngle: (endAngle! - 90).degreesToRadians, clockwise: true)
        midPath.close()
        midPath.fill()
        
    }

}

extension CGFloat {
    var degreesToRadians: Self { return self * .pi / 180.0 }
    var radiansToDegrees: Self { return self * 180.0 / .pi }
}
