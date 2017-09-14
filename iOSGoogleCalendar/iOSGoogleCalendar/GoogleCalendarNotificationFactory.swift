//
//  GoogleCalendarNotificationFactory.swift
//  iOSGoogleCalendar
//
//  Created by Zaldivar Coto, F. on 9/2/17.
//  Copyright © 2017 Zaldivar Coto, F. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import UserNotifications

class GoogleCalendarNotificationFactory: NSObject {
    
    
    // MARK:
    // MARK: properties
    
    var event : GTLRCalendar_Event!
    
    
    // MARK:
    // MARK: initializer
    
    init(event : GTLRCalendar_Event!){
        self.event = event
    }
    
    
    //MARK:
    //MARK: public methods
    
    func createContent() -> UNMutableNotificationContent{
        
        let content = UNMutableNotificationContent()
        content.title = event.summary!
        content.body = Constants.kEventNotificationBody
        content.sound = UNNotificationSound.default()
        
        
        return content
    }
    
    func createCategories(events: GTLRCalendar_Events?) -> UNNotificationCategory{
        
        let countEvents : Int = (events?.items?.count)!
        var actions : [UNNotificationAction] = []
        
        let declineAction = UNNotificationAction(identifier: Constants.kEventNotificationDeclineIdentifier,
                                                 title: Constants.kEventNotificationDecline, options: [.destructive/*,.foreground*/])
        actions.append(declineAction)
        
        //if there is no other event, the user can accept the new event
        if countEvents < 2 {
            let acceptAction = UNNotificationAction(identifier: Constants.kEventNotificationAcceptIdentifier,
                                                    title: Constants.kEventNotificationAccept, options: [/*.foreground*/])
            actions.append(acceptAction)
        }else{
            
        }
        
        
        let category = UNNotificationCategory(identifier: GoogleCalendar.Notification.categoryIdentifier,
                                              actions: actions,
                                              intentIdentifiers: [], options: [])
        
        return category
    }
}
