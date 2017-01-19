//
//  TimeInterval+Utility.swift
//  Time Log
//
//  Created by Chase Wang on 1/15/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import Foundation

extension TimeInterval {
    var toTimerString: String {
        let (hours, minutes, seconds) = intervalComponents
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    var toDurationString: String {
        switch intervalComponents {
        case (0, 0, 0):                                 return "0s"
        case (0, 0, let seconds):                       return String(format: "%ds", seconds)
        case (0, let minutes, let seconds):             return String(format: "%dm %ds", minutes, seconds)
        case (let hours, let minutes, let seconds):     return String(format: "%dh %dm %ds", hours, minutes, seconds)
        }
    }
    
    var intervalComponents: (Int, Int, Int) {
        let interval = Int(self)
        
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        
        return (hours: hours, minutes: minutes, seconds: seconds)
    }
}
