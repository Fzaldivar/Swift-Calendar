//
//  LocalCalendarConnection.swift
//  iOSGoogleCalendar
//
//  Created by Zaldivar Coto, F. on 8/12/17.
//  Copyright © 2017 Zaldivar Coto, F. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import EventKit

@objc protocol LocalCalendarProtocol : class {
    @objc optional func readEvents(events : GTLRCalendar_Events?)
    @objc optional func createEvent(success : Bool)
    @objc optional func updateEventWithAttendee(success : Bool)
}

class LocalCalendar: NSObject, GoogleCalendarProtocol {
    
    
    // MARK:
    // MARK: properties
    
    static let shared = LocalCalendar()
    var googleCalendar : GoogleCalendar!
    weak var delegate : LocalCalendarProtocol?
    
    
    // MARK:
    // MARK: initialize methods
    
    private override init() {
        googleCalendar = GoogleCalendar.shared
    }
    
    
    // MARK:
    // MARK: public methods
    
    
    //adding new event
    func addingNewEvent(event : GTLRCalendar_Event!){
        
        googleCalendar.delegate = self
        
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let localEvent : EKEvent = EKEvent(event: event, eventStore :eventStore)
                do{
                    try eventStore.save(localEvent, span: .thisEvent, commit: true)
                    self.googleCalendar.createEventInGoogleCalendar(event: event)
                }catch{
                    self.delegate?.createEvent!(success : false)
                }
            } else {
                self.delegate?.createEvent!(success : false)
            }
        })
    }
    
    
    //update event
    func updateEventWithAttendee(event: GTLRCalendar_Event!){
        googleCalendar.delegate = self
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                self.googleCalendar.updateEventWithAttendeeInGoogleCalendar(event: event)
            } else {
                self.delegate?.updateEventWithAttendee!(success: false)
            }
        })
    }
    
    
    //load events
    func loadEvents(){
        googleCalendar.delegate = self
        self.googleCalendar.loadEventsFromGoogle()
    }
    
    
    // MARK:
    // MARK: delegate methods
    
    //finishing adding new event
    func finishingAddingNewEventFromGoogle(success : Bool){
        delegate?.createEvent!(success: success)
    }
    
    //finishing updating event
    func finishingUpdateEventWithAttendeeFromGoogle(success : Bool){
        delegate?.updateEventWithAttendee!(success: success)
    }
    
    //finishing load events
    func finishingLoadEventsFromGoogle(events : GTLRCalendar_Events?){
        delegate?.readEvents!(events: events)
    }
}
