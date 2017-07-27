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
    
    // MARK:
    // MARK: initialize methods
    
    private func initialize(){
        addEventButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addEventView))
        navigationItem.rightBarButtonItem = addEventButton
        navigationItem.setHidesBackButton(true, animated:true);
        title = titleEvents
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
    // MARK: public methods
    
    func addEventView(){
        let newEventViewController : NewEventViewController = storyboard?.instantiateViewController(withIdentifier: "NewEventViewController") as! NewEventViewController
        newEventViewController.service = service
        navigationController?.pushViewController(newEventViewController, animated: true)
    }
    
    
}
