//
//  Reminder.swift
//  Proximity Reminders App
//
//  Created by Dzmitry Matsiulka on 10/4/19.
//  Copyright © 2019 Dzmitry M. All rights reserved.
//

import Foundation


class Reminder{
    var remindTo : String
    var longitude: Double
    var latitude: Double
    var locationName: String
    var whenEnter: Bool
    var isInNow: Bool
    
    init(remindTo: String, longitude: Double, latitude: Double, locationName: String, whenEnter: Bool, isInNow: Bool) {
        self.remindTo = remindTo
        self.longitude = longitude
        self.latitude = latitude
        self.locationName = locationName
        self.whenEnter  = whenEnter
        self.isInNow = isInNow
    }
}
