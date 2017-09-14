//
//  EventsTableViewController.swift
//  iOSGoogleCalendar
//
//  Created by Zaldivar Coto, F. on 7/24/17.
//  Copyright © 2017 Zaldivar Coto, F. All rights reserved.
//

import GoogleAPIClientForREST
import UIKit
import GTMOAuth2
import NVActivityIndicatorView
import UserNotifications


class EventsTableViewController: UITableViewController,NVActivityIndicatorViewable,LocalCalendarProtocol {
    
    // MARK:
    // MARK: constants
    let eventsSections : Int = 1
    let titleEvents : String = "Events"
    let center = UNUserNotificationCenter.current()
    let notificationDelegate = GoogleCalendarNotificationDelegate()
    
    
    // MARK:
    // MARK: properties
    var events : GTLRCalendar_Events!
    var addEventButton : UIBarButtonItem!
    var sendNotification : UIBarButtonItem!
    var calendarUserEmail : String!
    var localCalendar : LocalCalendar!
    
    // MARK:
    // MARK: initialize methods
    
    private func initialize(){
        addEventButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addEventView))
        sendNotification = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(sendInvite))
        navigationItem.rightBarButtonItem = addEventButton
        navigationItem.leftBarButtonItem = sendNotification
        navigationItem.setHidesBackButton(true, animated:true);
        title = titleEvents
        calendarUserEmail = CalendarUser.shared.userEmail
        localCalendar = LocalCalendar.shared
        initNotificationSetupCheck()
        center.delegate = notificationDelegate
    }
    
    // MARK:
    // MARK: override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localCalendar.delegate = self
        localCalendar.loadEvents()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:
    // MARK: delegate methods
    
    //MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return eventsSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard events.items != nil else {
            return 0;
        }
        
        return (events.items?.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
        let event : GTLRCalendar_Event = (events.items?[indexPath.row])!
        cell.textLabel?.text = event.summary
        
        let attendee = getGTLCalendar_EventAttendee(event: event)
        cell.backgroundColor = colorOfCell(attendee: attendee)
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    //MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let event : GTLRCalendar_Event = (events.items?[indexPath.row])!
        
        let detailViewController : DetailViewController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailViewController.mainEvent = event
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    
    //MARK: LocalCalendarProtocol
    
    func readEvents(events : GTLRCalendar_Events?){
        self.events = events
        UIView.transition(with: tableView,
                          duration: 1.0,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.tableView.reloadData()
        })
        stopAnimating()
    }
    
    
    func readEventsWithEvent(events: GTLRCalendar_Events?, event: GTLRCalendar_Event!) {

        let factory = GoogleCalendarNotificationFactory(event: event)
        let content = factory.createContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3,
                                                        repeats: false)
        let identifier = GoogleCalendar.Notification.identifier + event.summary!
        let category = factory.createCategories(events : events)
        
        content.categoryIdentifier = GoogleCalendar.Notification.categoryIdentifier
        content.userInfo = ["eventId" : event.identifier!]
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        
        center.setNotificationCategories([category])
        center.add(request, withCompletionHandler: { (error) in
        })
    }
    
    // MARK:
    // MARK: private methods
    
    //search the invite for the user
    private func getGTLCalendar_EventAttendee(event : GTLRCalendar_Event) -> GTLRCalendar_EventAttendee?{
        
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
    
    //get the color of each cell
    private func colorOfCell(attendee : GTLRCalendar_EventAttendee?) -> UIColor{
        
        
        guard let attendeeStatus = attendee?.responseStatus
            else{
                return UIColor.green
        }
        
        switch attendeeStatus {
        case Constants.kEventStatusAccepted:
            return UIColor.green
        case Constants.kEventStatusTentative:
            return  UIColor.yellow
        case Constants.kEventStatusNeedsAction:
            return UIColor.blue
        case Constants.kEventStatusDeclined:
            return UIColor.red
        default :
            return UIColor.green
            
        }
        
    }
    
    //set notifications
    private func initNotificationSetupCheck() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]){
            (success, error) in
            if success {
                print("Permission Granted")
            } else {
                print("There was a problem!")
            }
        }
    }
    
    
    //get all the invites that need an answer
    private func getTentativeInvites() -> [GTLRCalendar_Event]{
        
        var tentativeEvents :[GTLRCalendar_Event] = []
        
        for event in events.items!{
            
            let attendee = getGTLCalendar_EventAttendee(event: event)
            if(attendee != nil && attendee?.responseStatus == Constants.kEventStatusNeedsAction) {
                tentativeEvents.append(event)
            }
        }
        
        return tentativeEvents
    }
    
    //send single invite
    private func sendSingleInvite(event : GTLRCalendar_Event!){
        
        localCalendar.loadEvents(event: event)
        
    }
    
    
    // MARK:
    // MARK: public methods
    
    //go to NewEvent
    func addEventView(){
        let newEventViewController : NewEventViewController = storyboard?.instantiateViewController(withIdentifier: "NewEventViewController") as! NewEventViewController
        navigationController?.pushViewController(newEventViewController, animated: true)
    }
    
    //send notification
    func sendInvite(){
        
        let eventsWithPendingInvites = getTentativeInvites()
        
        print(eventsWithPendingInvites.count)
        
        for event in eventsWithPendingInvites{
            sendSingleInvite(event: event)
        }
        
    }
    
}


