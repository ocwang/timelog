//
//  TimeLog.swift
//  Time Log
//
//  Created by Chase Wang on 1/15/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import Foundation

struct TimeLog {
    let startDate: Date
    let title: String
    
    init(title: String, startDate: Date) {
        self.title = title
        self.startDate = startDate
    }
}
