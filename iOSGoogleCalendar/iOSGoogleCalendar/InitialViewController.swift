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
import NVActivityIndicatorView


class InitialViewController: UIViewController , GIDSignInDelegate, GIDSignInUIDelegate, NVActivityIndicatorViewable,GoogleCalendarProtocol{
    
    // MARK:
    // MARK: constants
    
    let kGoogleAPIKeychainItemName = "Google Calendar API";
    let kGoogleAPIClientID = "307980938621-11gdeu8334c6umga443iic3bgq58u2cb.apps.googleusercontent.com";

    
    // MARK:
    // MARK: properties
    
    //var service : GTLRCalendarService!
    var calendarUser : CalendarUser!
    var googleCalendar : GoogleCalendar!
    let signInButton = GIDSignInButton()
    private let scopes = ["https://www.googleapis.com/auth/userinfo.email","https://www.googleapis.com/auth/calendar"]
    
    
    // MARK:
    // MARK: initialize methods
    
    private func initialize(){
        
        //spinner
        
        let width = view.frame.size.width / 3
        let size = CGSize(width: width, height: width)
        startAnimating(size, message: Constants.kLoadingTextLogin, type: .ballScaleRipple)
        
        
        //service
        googleCalendar = GoogleCalendar.shared
        googleCalendar.service.authorizer = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychain(forName: kGoogleAPIKeychainItemName, clientID: kGoogleAPIClientID, clientSecret: nil)
        
        signInButton.center = view.center
        signInButton.isHidden = true
        view.addSubview(signInButton)
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        
        //properties
        calendarUser = CalendarUser.shared
        googleCalendar.delegate = self

    }
    
    
    
    // MARK:
    // MARK: override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GIDSignIn.sharedInstance().signInSilently()
        googleCalendar.delegate = self
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK:
    // MARK: delegate methods
    
    //MARK: sign in google
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            self.signInButton.isHidden = false
            self.googleCalendar.service.authorizer = nil
            stopAnimating()
        } else {
            self.signInButton.isHidden = true
            self.googleCalendar.service.authorizer = user.authentication.fetcherAuthorizer()
            calendarUser.userEmail = user.profile.email
            goToEventsTableViewController()
        }
        
        
    }
    

    
    // MARK:
    // MARK: private methods
    
    private func goToEventsTableViewController() {
        //stop spinner
        stopAnimating()
        
        let eventsTableViewController : EventsTableViewController = storyboard?.instantiateViewController(withIdentifier: "EventsTableViewController") as! EventsTableViewController
        eventsTableViewController.events = GTLRCalendar_Events.init()
        navigationController?.pushViewController(eventsTableViewController, animated: true)
    }
}
