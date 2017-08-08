//
//  GoogleCalendarConnection.swift
//  iOSGoogleCalendar
//
//  Created by Zaldivar Coto, F. on 8/3/17.
//  Copyright © 2017 Zaldivar Coto, F. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST


@objc protocol GoogleCalendarProtocol : class {
    @objc optional func readEvents(events : GTLRCalendar_Events?)
    @objc optional func createEvent(success : Bool)
    @objc optional func updateEventWithAttendee(success : Bool)
}

class GoogleCalendar: NSObject {
    
    // MARK:
    // MARK: properties
    
    static let shared = GoogleCalendar()
    var service : GTLRCalendarService!
    weak var delegate : GoogleCalendarProtocol?
    
    
    
    // MARK:
    // MARK: initialize methods
    
    private override init(){
        service = GTLRCalendarService.init()
    }
    
    
    // MARK:
    // MARK: public methods
    
    //load events
    func loadEvents(){
        
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        query.maxResults = 10
        query.timeMin = GTLRDateTime(date: Date())
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        
        service.executeQuery(query, completionHandler: { (ticket, response , error) -> Void in
            let events : GTLRCalendar_Events = response as! GTLRCalendar_Events
            self.delegate?.readEvents!(events: events)
        })
    }
    
    //create event
    func createEvent(event : GTLRCalendar_Event!){
        //query
        let insertQuery : GTLRCalendarQuery_EventsInsert = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: "primary")
        
        
        service.executeQuery(insertQuery, completionHandler: { (ticket, person , error) -> Void in
            if (error == nil) {
                self.delegate?.createEvent!(success: true)
            }else{
                self.delegate?.createEvent!(success: false)
            }
        })
    }
    
    //update event with attendee
    func updateEventWithAttendee(event : GTLRCalendar_Event!){
        //update query
        let updateQuery : GTLRCalendarQuery_EventsUpdate = GTLRCalendarQuery_EventsUpdate.query(withObject: event, calendarId: "primary", eventId: event.identifier!)
        
        //execute query
        service.executeQuery(updateQuery, completionHandler: { (ticket, person , error) -> Void in
            if (error == nil) {
                let delayInSeconds = 2.0
                DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                    self.delegate?.updateEventWithAttendee!(success: true)
                }
            }else{
                self.delegate?.updateEventWithAttendee!(success: false)
            }
        })
    }
    
    
}
