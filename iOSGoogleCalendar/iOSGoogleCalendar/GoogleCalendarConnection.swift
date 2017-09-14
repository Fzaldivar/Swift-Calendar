//
//  GoogleCalendarConnection.swift
//  iOSGoogleCalendar
//
//  Created by Zaldivar Coto, F. on 8/3/17.
//  Copyright © 2017 Zaldivar Coto, F. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import EventKit


@objc protocol GoogleCalendarProtocol : class {
    @objc optional func finishingLoadEventsFromGoogle(events : GTLRCalendar_Events?)
    @objc optional func finishingLoadEventsFromGoogleWithEvent(events : GTLRCalendar_Events?, event : GTLRCalendar_Event)
    @objc optional func finishingAddingNewEventFromGoogle(success : Bool)
    @objc optional func finishingUpdateEventWithAttendeeFromGoogle(success : Bool)
    @objc optional func finishingLoadSingleEvent(event : GTLRCalendar_Event?, newStatus : String!)
}

class GoogleCalendar: NSObject {
    
    // MARK:
    // MARK: properties
    
    static let shared = GoogleCalendar()
    var service : GTLRCalendarService!
    weak var delegate : GoogleCalendarProtocol?
    
    struct Notification{
        static let identifier = "googleCalendarIndentifier"
        static let categoryIdentifier = "googleCalendarCategoryIndentifier"
    }
    
    // MARK:
    // MARK: initialize methods
    
    private override init(){
        service = GTLRCalendarService.init()
    }
    
    
    // MARK:
    // MARK: public methods
    
    //load events
    func loadEventsFromGoogle(){
        
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        query.maxResults = 10
        query.timeMin = GTLRDateTime(date: Date())
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        
        service.executeQuery(query, completionHandler: { (ticket, response , error) -> Void in
            let events : GTLRCalendar_Events = response as! GTLRCalendar_Events
            self.delegate?.finishingLoadEventsFromGoogle!(events: events)
        })
    }
    
    
    //check if an event conflicts with other
    func loadEventsFromGoogleWithEvent(event : GTLRCalendar_Event!){
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        query.timeMin = event.start?.dateTime
        query.timeMax = event.end?.dateTime
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        
        service.executeQuery(query, completionHandler: { (ticket, response , error) -> Void in
            let events : GTLRCalendar_Events = response as! GTLRCalendar_Events
            self.delegate?.finishingLoadEventsFromGoogleWithEvent!(events: events, event: event)
        })
    }
    
    //load single event
    func loadSingleEvent(event : GTLRCalendar_Event!, newStatus : String!){
        let query = GTLRCalendarQuery_EventsGet.query(withCalendarId: "primary", eventId: event.identifier!)
        service.executeQuery(query, completionHandler: { (ticket, response , error) -> Void in
            
            let event : GTLRCalendar_Event = response as! GTLRCalendar_Event
            self.delegate?.finishingLoadSingleEvent!(event: event, newStatus: newStatus)
        })
        
    }
    
    //create event
    func createEventInGoogleCalendar(event : GTLRCalendar_Event!){
        //query
        let insertQuery : GTLRCalendarQuery_EventsInsert = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: "primary")
        
        
        service.executeQuery(insertQuery, completionHandler: { (ticket, person , error) -> Void in
            if (error == nil) {
                self.delegate?.finishingAddingNewEventFromGoogle!(success: true)
            }else{
                self.delegate?.finishingAddingNewEventFromGoogle!(success: false)
            }
        })
    }
    
    //update event with attendee
    func updateEventWithAttendeeInGoogleCalendar(event : GTLRCalendar_Event!){
        //update query
        let updateQuery : GTLRCalendarQuery_EventsUpdate = GTLRCalendarQuery_EventsUpdate.query(withObject: event, calendarId: "primary", eventId: event.identifier!)
        updateQuery.sendNotifications = true
        
        //execute query
        service.executeQuery(updateQuery, completionHandler: { (ticket, person , error) -> Void in
            if (error == nil) {
                let delayInSeconds = 2.0
                DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                    self.delegate?.finishingUpdateEventWithAttendeeFromGoogle!(success: true)
                }
            }else{
                self.delegate?.finishingUpdateEventWithAttendeeFromGoogle!(success: false)
            }
        })
    }
    
    
}
