//
//  CalendarUser.swift
//  iOSGoogleCalendar
//
//  Created by Zaldivar Coto, F. on 8/1/17.
//  Copyright © 2017 Zaldivar Coto, F. All rights reserved.
//

import UIKit

class CalendarUser: NSObject {
    
    
    // MARK:
    // MARK: properties
    
    var userEmail : String!
    static let shared : CalendarUser = CalendarUser()
    
    // MARK:
    // MARK: initialize methods
    
    private override init(){
        userEmail = ""
    }

}
