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
    
    
    // MARK:
    // MARK: properties
    var events : GTLRCalendar_Events!
    var service : GTLRCalendarService!
    
    // MARK:
    // MARK: initialize methods
    
    private func initialize(){
        
        //addEvent()
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
        
        return cell
    }
    
    // MARK:
    // MARK: private methods
    
    private func addEvent(){
        let myEvent : GTLRCalendar_Event = GTLRCalendar_Event.init()
        
        //details
        myEvent.summary = "Mi nuevo evento desde el app"
        myEvent.descriptionProperty = "Creando un nuevo evento desde mi app en Swift"
        
        //dates
        let myStartDate : Date = Date.init()
        let myEndDate : Date = myStartDate.addingTimeInterval((60 * 60))
        
        let startTime : GTLRDateTime = GTLRDateTime.init(date: myStartDate)
        let endTime : GTLRDateTime = GTLRDateTime.init(date: myEndDate)
        
        myEvent.start = GTLRCalendar_EventDateTime.init()
        myEvent.end = GTLRCalendar_EventDateTime.init()
        
        myEvent.start?.dateTime = startTime
        myEvent.end?.dateTime = endTime
        
        //query
        let insertQuery : GTLRCalendarQuery_EventsInsert = GTLRCalendarQuery_EventsInsert.query(withObject: myEvent, calendarId: "primary")
        
        
        service.executeQuery(insertQuery, completionHandler: { (ticket, person , error) -> Void in
            if (error == nil) {
                print("Se agregó")
            }else{
                print("No se agregó")
            }
        })
    }
    
    
}
