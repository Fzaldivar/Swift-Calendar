//
//  Constants.swift
//  iOSGoogleCalendar
//
//  Created by Zaldivar Coto, F. on 8/1/17.
//  Copyright © 2017 Zaldivar Coto, F. All rights reserved.
//

import Foundation
import UIKit

struct Constants{
    
    //Loading titles
    static let kLoadingTextLogin : String = "Loading..."
    static let kLoadingTextChangeStatus : String = "Sending..."
    
    
    //Event Status
    static let kEventStatusAccepted : String = "accepted"
    static let kEventStatusTentative : String = "tentative"
    static let kEventStatusDeclined : String = "declined"
    static let kEventStatusNeedsAction : String = "needsAction"
    static let kEventStatusCancelled : String = "cancelled"
    
    //Event Status title
    static let kEventStatusAcceptedTitle : String = "Accepted"
    static let kEventStatusTentativeTitle : String = "Tentative"
    static let kEventStatusDeclinedTitle : String = "Declined"
    static let kEventStatusNeedsActionTitle : String = "Needs Action"
    static let kEventStatusCancelledTitle : String = "Cancelled"
    static let kEventsNoStatus : String = "No status"


    //EventTableViewController
    static let kEventTableViewHeight : CGFloat = 60.0
    static let kEventTableViewCellIdentifier : String = "EventTableViewCell"
    
    //Event Update
    static let kEventUpdateButtonWithAttendee : String = "Change status"
    static let kEventUpdateButtonWithoutAttendee : String = "Delete"
    static let kEventUpdateSuccess : String = "The event has changed."
    static let kEventUpdateError : String = "There was an error during the transaction."
    
    //Google Calendar Notification Factory
    static let kEventNotificationBody = "This needs an answer"
    static let kEventNotificationDeclineIdentifier = "declined"
    static let kEventNotificationDecline = "Decline"
    static let kEventNotificationAcceptIdentifier = "accepted"
    static let kEventNotificationAccept = "Accept"
}
