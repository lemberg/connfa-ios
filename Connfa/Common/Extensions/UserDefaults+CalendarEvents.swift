//
//  UserDefaults+CalendarEvents.swift
//  Connfa
//
//  Created by Hellen Soloviy on 11/14/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import Foundation

extension UserDefaults {
    private var eventCalendarKey: String {
        return "com.connfa.eventCalendarKey"
    }
    
    var eventCalendarIdentifier: String? {
        get {
            return value(forKey: eventCalendarKey) as? String
        }
        set {
            setValue(newValue, forKey: eventCalendarKey)
            synchronize()
        }
    }
}
