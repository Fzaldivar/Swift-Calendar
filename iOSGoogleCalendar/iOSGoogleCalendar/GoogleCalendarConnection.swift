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
//    @objc optional func readUser(code: Int, session : String?)
//    @objc optional func readMessage(messages : NSMutableArray?, newContext: NSDictionary?)
    @objc optional func readEvents(events : GTLRCalendar_Events?)
}

class GoogleCalendar: NSObject {

    // MARK:
    // MARK: properties
    
    static let shared = GoogleCalendar()
    weak var delegate : GoogleCalendarProtocol?
    
    
    // MARK:
    // MARK: initialize methods
    
    private override init(){
    }
    
    
    // MARK:
    // MARK: public methods
    
    func loadEvents(service : GTLRCalendarService!){
        
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
}
