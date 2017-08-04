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


class EventsTableViewController: UITableViewController,NVActivityIndicatorViewable,GoogleCalendarProtocol {
    
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
    var googleCalendar : GoogleCalendar!
    
    // MARK:
    // MARK: initialize methods
    
    private func initialize(){
        addEventButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addEventView))
        navigationItem.rightBarButtonItem = addEventButton
        //navigationItem.setHidesBackButton(true, animated:true);
        title = titleEvents
        calendarUserEmail = CalendarUser.shared.userEmail
        googleCalendar = GoogleCalendar.shared
        googleCalendar.delegate = self
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
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    //MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let event : GTLRCalendar_Event = (events.items?[indexPath.row])!
        
        if event.attendees != nil && event.attendees?.count != 0 {
            
            let attendee = getGTLCalendar_EventAttendee(event: event)
            changeStatusAttendeeAlert(event: event, attendee: attendee!)
        }
        
        
    }
    
    
    //MARK: GoogleCalendarProtocol
    
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
    
    
    //change status alert view
    
    private func changeStatusAttendeeAlert(event : GTLRCalendar_Event, attendee : GTLRCalendar_EventAttendee){
        
        let alertController = UIAlertController(title: event.summary, message: String(format:"Current status %@",getStatusFromAttendee(attendee: attendee)), preferredStyle: .alert)
        setAlertActions(event: event, attendee: attendee, alertController: alertController)
        present(alertController, animated: true) {}
    }
    
    
    //get status from event for Alert title
    
    private func getStatusFromAttendee(attendee : GTLRCalendar_EventAttendee) -> String{
        
        guard let status = attendee.responseStatus else {
            return Constants.kEventsNoStatus
        }
        
        switch status {
        case Constants.kEventStatusAccepted:
            return Constants.kEventStatusAcceptedTitle
        case Constants.kEventStatusTentative:
            return  Constants.kEventStatusTentativeTitle
        case Constants.kEventStatusNeedsAction:
            return Constants.kEventStatusNeedsActionTitle
        case Constants.kEventStatusDeclined:
            return Constants.kEventStatusDeclinedTitle
        default :
            return Constants.kEventsNoStatus
        }
        
    }
    
    
    //get all the actions for an attendee
    
    private func setAlertActions(event: GTLRCalendar_Event, attendee : GTLRCalendar_EventAttendee, alertController : UIAlertController) {
        
        
        //create actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in}
        let acceptedAction =  UIAlertAction(title: Constants.kEventStatusAcceptedTitle, style: .default) { action in
            self.updateEventByAttendee(event: event, attendee: attendee, title: Constants.kEventStatusAccepted)
        }
        let declinedAction =  UIAlertAction(title: Constants.kEventStatusDeclinedTitle, style: .default) { action in
            self.updateEventByAttendee(event: event,attendee: attendee, title: Constants.kEventStatusDeclined)
        }
        
        let tentativeAction =  UIAlertAction(title: Constants.kEventStatusTentativeTitle, style: .default) { action in
            self.updateEventByAttendee(event: event,attendee: attendee, title: Constants.kEventStatusTentative)
        }
        
        alertController.addAction(cancelAction)
        
        guard let status = attendee.responseStatus else {
            return
        }
        
        //add the actions
        switch status {
        case Constants.kEventStatusAccepted:
            alertController.addAction(declinedAction)
            alertController.addAction(tentativeAction)
            break
        case Constants.kEventStatusTentative:
            alertController.addAction(declinedAction)
            alertController.addAction(acceptedAction)
            break
        case Constants.kEventStatusNeedsAction:
            alertController.addAction(declinedAction)
            alertController.addAction(acceptedAction)
            alertController.addAction(tentativeAction)
            break
        case Constants.kEventStatusDeclined:
            alertController.addAction(acceptedAction)
            alertController.addAction(tentativeAction)
            break
        default:
            break
        }
    }
    
    //change status attendee
    private func updateEventByAttendee(event : GTLRCalendar_Event, attendee : GTLRCalendar_EventAttendee, title : String){
        
        let width = self.view.frame.size.width / 3
        let size = CGSize(width: width, height: width)
        startAnimating(size, message: Constants.kLoadingTextChangeStatus, type: .ballScaleRipple)
        
        //change status
        attendee.responseStatus = title
        
        //update query
        let updateQuery : GTLRCalendarQuery_EventsUpdate = GTLRCalendarQuery_EventsUpdate.query(withObject: event, calendarId: "primary", eventId: event.identifier!)
        
        //execute query
        service.executeQuery(updateQuery, completionHandler: { (ticket, person , error) -> Void in
            if (error == nil) {
                let delayInSeconds = 2.0
                DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                    self.stopAnimating()
                    self.googleCalendar.loadEvents(service: self.service)
                }
            }else{
                self.stopAnimating()
                print("NOOOOOO")
            }
        })
    }
    
    // MARK:
    // MARK: public methods
    
    func addEventView(){
        let newEventViewController : NewEventViewController = storyboard?.instantiateViewController(withIdentifier: "NewEventViewController") as! NewEventViewController
        newEventViewController.service = service
        navigationController?.pushViewController(newEventViewController, animated: true)
    }
    
    
}
