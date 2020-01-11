//
//  eventItemCell.swift
//  One Day
//
//  Created by Jae Ho Shin on 2020-01-06.
//  Copyright © 2020 Jae Ho Shin. All rights reserved.
//

import UIKit

class EventItemCell: UITableViewCell{
    
    @IBOutlet weak var colorBox: UIView!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var eventName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func fillContents(piecolor: UIColor, startTimeHr:Int, startTimeMin:Int, endTimeHr:Int, endTimeMin:Int, eventName: String){
        
        var timeTxt = ""
        
        if startTimeHr<10{
            timeTxt = timeTxt + "0" + String(startTimeHr)
        } else {timeTxt =  timeTxt + String(startTimeHr)}
        
        if startTimeMin<10{
            timeTxt = timeTxt + ":0" + String(startTimeMin)
        } else {timeTxt =  timeTxt + ":" + String(startTimeMin)}
  
        timeTxt = timeTxt + " - "
        
        if endTimeHr<10{
            timeTxt = timeTxt + "0" + String(endTimeHr)
        } else {timeTxt =  timeTxt + String(endTimeHr)}
        
        if endTimeMin<10{
            timeTxt = timeTxt + ":0" + String(endTimeMin)
        } else {timeTxt =  timeTxt + ":" + String(endTimeMin)}
        
        self.startTime.text = timeTxt
        
        self.eventName.text = eventName
        
        self.colorBox.backgroundColor = piecolor
    }
}
