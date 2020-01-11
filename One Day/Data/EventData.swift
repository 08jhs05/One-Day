//
//  ScheduleData.swift
//  One Day
//
//  Created by Jae Ho Shin on 2020-01-05.
//  Copyright © 2020 Jae Ho Shin. All rights reserved.
//

import Foundation
import UIKit

class EventData {
    var eventName: String?
    var startTimeHr: Int16?
    var startTimeMin: Int16?
    var endTimeHr: Int16?
    var endTimeMin: Int16?
    var pieColor: UIColor?
    
    init(name: String, startTimeHr: Int16, startTimeMin: Int16, endTimeHr: Int16, endTimeMin: Int16, pieColor: UIColor){
        self.eventName = name
        self.startTimeHr = startTimeHr
        self.startTimeMin = startTimeMin
        self.endTimeHr = endTimeHr
        self.endTimeMin = endTimeMin
        self.pieColor = pieColor
    }
    
}
