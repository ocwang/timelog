//
//  TimeInterval+Utility.swift
//  Time Log
//
//  Created by Chase Wang on 1/15/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import Foundation

extension TimeInterval {
    var toFormattedString: String {
        let interval = Int(self)
        
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
