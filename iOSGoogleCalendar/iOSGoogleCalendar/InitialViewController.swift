//
//  InitialViewController.swift
//  iOSGoogleCalendar
//
//  Created by Zaldivar Coto, F. on 7/24/17.
//  Copyright © 2017 Zaldivar Coto, F. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn
import GTMOAuth2


class InitialViewController: UIViewController , GIDSignInDelegate, GIDSignInUIDelegate{
    
    
    let kGoogleAPIKeychainItemName = "Google Calendar API";
    let kGoogleAPIClientID = "307980938621-11gdeu8334c6umga443iic3bgq58u2cb.apps.googleusercontent.com";
    
    // MARK:
    // MARK: properties
    
    var service : GTLRCalendarService!
    let signInButton = GIDSignInButton()
    private let scopes = ["https://www.googleapis.com/auth/calendar"]
    
    
    // MARK:
    // MARK: initialize methods
    
    private func initialize(){
        
        service = GTLRCalendarService.init()
        service.authorizer = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychain(forName: kGoogleAPIKeychainItemName, clientID: kGoogleAPIClientID, clientSecret: nil)
        
        signInButton.center = view.center
        view.addSubview(signInButton)
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
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
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            fetchEvents()
        }
    }
    
    
    // MARK:
    // MARK: public methods
    
    func displayResultWithTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Events,
        error : NSError?) {
        
        let eventsTableViewController : EventsTableViewController = storyboard?.instantiateViewController(withIdentifier: "EventsTableViewController") as! EventsTableViewController
        eventsTableViewController.events = response
        eventsTableViewController.service = service
        navigationController?.pushViewController(eventsTableViewController, animated: true)
        
    }
    
    // MARK:
    // MARK: private methods
    
    // Helper for showing an alert
    private func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    private func fetchEvents() {
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        query.maxResults = 10
        query.timeMin = GTLRDateTime(date: Date())
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        service.executeQuery(
            query,
            delegate: self,
            didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
}
