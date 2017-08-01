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


class EventsTableViewController: UITableViewController {
    
    // MARK:
    // MARK: constants
    let eventsSections : Int = 1
    let titleEvents : String = "Events"
    
    
    // MARK:
    // MARK: properties
    var events : GTLRCalendar_Events!
    var service : GTLRCalendarService!
    var addEventButton : UIBarButtonItem!
    var calendarUserEmail : String!
    
    // MARK:
    // MARK: initialize methods
    
    private func initialize(){
        addEventButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addEventView))
        navigationItem.rightBarButtonItem = addEventButton
        navigationItem.setHidesBackButton(true, animated:true);
        title = titleEvents
        calendarUserEmail = CalendarUser.shared.userEmail
    }
    
    // MARK:
    // MARK: override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        
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
        return (events.items?.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
        let event : GTLRCalendar_Event = (events.items?[indexPath.row])!
        cell.textLabel?.text = event.summary
        
        let attendee = getGTLCalendar_EventAttendee(event: event)
        cell.backgroundColor = colorOfCell(attendee: attendee)
        
        return cell
    }
    
    
    //MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let event : GTLRCalendar_Event = (events.items?[indexPath.row])!
        
        if event.attendees != nil && event.attendees?.count != 0 {
            event.attendees?[0].responseStatus = "accepted"
            
            
            let updateQuery : GTLRCalendarQuery_EventsUpdate = GTLRCalendarQuery_EventsUpdate.query(withObject: event, calendarId: "primary", eventId: event.identifier!)
            
            service.executeQuery(updateQuery, completionHandler: { (ticket, person , error) -> Void in
                if (error == nil) {
                    self.navigationController?.popToRootViewController(animated: true)
                }else{
                    print("No se actualizó")
                }
            })
            print("has attendees")
        }
        
        
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
                return UIColor.white
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
            return UIColor.white
            
        }
        
    }
    
    
    
    
    // MARK:
    // MARK: public methods
    
    func addEventView(){
        let newEventViewController : NewEventViewController = storyboard?.instantiateViewController(withIdentifier: "NewEventViewController") as! NewEventViewController
        newEventViewController.service = service
        navigationController?.pushViewController(newEventViewController, animated: true)
    }
    
    
}
