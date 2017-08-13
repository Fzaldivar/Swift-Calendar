//
//  EKEvent+iOSGoogleCalendar.swift
//  iOSGoogleCalendar
//
//  Created by Zaldivar Coto, F. on 8/12/17.
//  Copyright © 2017 Zaldivar Coto, F. All rights reserved.
//

import Foundation
import EventKit
import GoogleAPIClientForREST

extension EKEvent{
    
    convenience init(event : GTLRCalendar_Event!, eventStore : EKEventStore){
        
        self.init(eventStore: eventStore)
        self.title = event.summary!
        self.startDate = (event.start?.dateTime?.date)!
        self.endDate = (event.end?.dateTime?.date)!
        self.notes = event.descriptionProperty!
        self.calendar = eventStore.defaultCalendarForNewEvents
    }
    
}
