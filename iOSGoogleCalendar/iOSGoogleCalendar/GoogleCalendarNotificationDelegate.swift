//
//  GoogleCalendarNotificationDelegate.swift
//  iOSGoogleCalendar
//
//  Created by Zaldivar Coto, F. on 9/2/17.
//  Copyright © 2017 Zaldivar Coto, F. All rights reserved.
//

import UIKit
import UserNotifications
import GoogleAPIClientForREST

class GoogleCalendarNotificationDelegate: NSObject, UNUserNotificationCenterDelegate,GoogleCalendarProtocol {
    
    
    // MARK:
    // MARK: override methods
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Play sound and show alert to the user
        completionHandler([.alert,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Determine the user action
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case Constants.kEventNotificationAcceptIdentifier,
             Constants.kEventNotificationDeclineIdentifier:
            
            guard let eventId : String = response.notification.request.content.userInfo["eventId"] as? String else{
                return
            }
            getEvent(identifier: eventId, newStatus: response.actionIdentifier)
            
        case Constants.kEventNotificationDeclineIdentifier:
            print("Decline")
        default:
            print("Unknown action")
        }
        completionHandler()
    }
    
    
    // MARK:
    // MARK: delegate methods
    
    func finishingLoadSingleEvent(event: GTLRCalendar_Event?, newStatus : String!) {
        
        let googleCalendar : GoogleCalendar = GoogleCalendar.shared
        googleCalendar.delegate = self
        
        if let attendee : GTLRCalendar_EventAttendee = getGTLCalendar_EventAttendee(event: event) {
            attendee.responseStatus = newStatus
            googleCalendar.updateEventWithAttendeeInGoogleCalendar(event: event)
        }
    }
    
    
    //finishing updating event
    func finishingUpdateEventWithAttendeeFromGoogle(success : Bool){
        print("terminé")
    }
    
    // MARK:
    // MARK: private methods
    
    private func getEvent(identifier : String!, newStatus : String!){
        
        let googleCalendar : GoogleCalendar = GoogleCalendar.shared
        googleCalendar.delegate = self
        
        let event = GTLRCalendar_Event.init()
        event.identifier = identifier
        
        
        googleCalendar.loadSingleEvent(event: event, newStatus : newStatus)
    }
    
    private func getGTLCalendar_EventAttendee(event : GTLRCalendar_Event!) -> GTLRCalendar_EventAttendee?{
        
        let calendarUserEmail : String = CalendarUser.shared.userEmail
        
        if event.attendees != nil && event.attendees?.count != 0 {
            
            for attendee in event.attendees!{
                //if the email of the user is equal to the attendee...
                if(attendee.email! == calendarUserEmail){
                    return attendee
                }
            }
        }
        
        return nil
    }
    
}
