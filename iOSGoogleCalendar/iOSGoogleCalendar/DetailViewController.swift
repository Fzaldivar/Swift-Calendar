//
//  DetailViewController.swift
//  iOSGoogleCalendar
//
//  Created by Zaldivar Coto, F. on 8/7/17.
//  Copyright © 2017 Zaldivar Coto, F. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import NVActivityIndicatorView

class DetailViewController: UIViewController, LocalCalendarProtocol, NVActivityIndicatorViewable {
    
    
    //MARK:
    //MARK: properties
    var mainEvent : GTLRCalendar_Event!
    var attendee : GTLRCalendar_EventAttendee!
    var localCalendar : LocalCalendar!
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var changeStatusButton: UIButton!
    
    var calendarUserEmail : String!
    
    //MARK:
    //MARK: initialize methods
    
    func initialize(){
        //properties
        title = mainEvent.summary
        calendarUserEmail = CalendarUser.shared.userEmail
        attendee = getGTLCalendar_EventAttendee()
        localCalendar = LocalCalendar.shared
        localCalendar.delegate = self
        
        startDateLabel.text = getTextForDate(date: mainEvent.start?.dateTime?.date)
        endDateLabel.text = getTextForDate(date: mainEvent.end?.dateTime?.date)
        statusLabel.text = getStatusForLabel()
        statusLabel.textColor = getColorStatusLabel()
        
        if attendee == nil{
            changeStatusButton.setTitle(Constants.kEventUpdateButtonWithoutAttendee, for: .normal)
        }
        
        
    }
    
    //MARK:
    //MARK: override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:
    //MARK: delegate methods
    
    func updateEventWithAttendee(success : Bool){
        stopAnimating()
        
        let message : String!
        
        if success {
            message = Constants.kEventUpdateSuccess
            changeStatusLabel()
            
        }else{
            message = Constants.kEventUpdateError
        }
        
        let alertController = getResponseAlert(message: message)
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK:
    //MARK: private methods
    
    private func getTextForDate(date : Date!) -> String{
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return String(format: "%@", dateFormatter.string(from: date))
    }
    
    private func getStatusForLabel() -> String{
        guard (mainEvent.attendees != nil) else{
            return mainEvent.status!.capitalized
        }
        
        return getStatusFromAttendee()
    }
    
    //get attendee
    private func getGTLCalendar_EventAttendee() -> GTLRCalendar_EventAttendee?{
        
        if mainEvent.attendees != nil && mainEvent.attendees?.count != 0 {
            
            for attendee in mainEvent.attendees!{
                //if the email of the user is equal to the attendee...
                if(attendee.email! == calendarUserEmail){
                    return attendee
                }
            }
        }
        
        return nil
    }
    
    //get status from event for Alert title
    private func getStatusFromAttendee() -> String{
        
        guard let status = attendee?.responseStatus else {
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
    
    //set color for status label
    private func getColorStatusLabel() -> UIColor {
        
        guard let text = statusLabel.text else{
            return UIColor.black
        }
        
        switch text {
        case Constants.kEventStatusAcceptedTitle:
            return UIColor.green
        case Constants.kEventStatusTentativeTitle:
            return UIColor.yellow
        case Constants.kEventStatusNeedsActionTitle:
            return UIColor.purple
        case Constants.kEventStatusDeclinedTitle:
            return UIColor.red
        default:
            return UIColor.black
        }
    }
    
    
    //change status alert view
    
    private func getAlertChangeStatusAttendee() -> UIAlertController{
        
        let alertController = UIAlertController(title: mainEvent.summary, message: String(format:"Current status %@",getStatusFromAttendee()), preferredStyle: .alert)
        return alertController
        
    }
    
    //delete event
    
    private func getAlertDeleteEvent() -> UIAlertController{
        let alertController = UIAlertController(title: mainEvent.summary, message: String(format:"Current status %@",statusLabel.text!), preferredStyle: .alert)
        return alertController
    }
    
    
    //get all the actions for an attendee
    
    private func setAlertActionsAttendee(alertController : UIAlertController) {
        
        
        //create actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            alertController.dismiss(animated:true, completion: nil)
        }
        let acceptedAction =  UIAlertAction(title: Constants.kEventStatusAcceptedTitle, style: .default) { action in
            self.updateEvent(newStatus: Constants.kEventStatusAccepted, hasAttendee: true)
        }
        let declinedAction =  UIAlertAction(title: Constants.kEventStatusDeclinedTitle, style: .default) { action in
            self.updateEvent(newStatus: Constants.kEventStatusDeclined, hasAttendee: true)
        }
        
        let tentativeAction =  UIAlertAction(title: Constants.kEventStatusTentativeTitle, style: .default) { action in
            self.updateEvent(newStatus: Constants.kEventStatusTentative, hasAttendee: true)
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
    
    
    //get all the actions for an attendee
    
    private func setAlertActionsEvent(alertController : UIAlertController) {
        //create actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            alertController.dismiss(animated:true, completion: nil)
        }
        
        let declinedAction =  UIAlertAction(title: Constants.kEventStatusDeclinedTitle, style: .default) { action in
            self.updateEvent(newStatus: Constants.kEventStatusCancelled, hasAttendee: false)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(declinedAction)
    }
    
    
    //response alert controller for update
    private func getResponseAlert(message : String) -> UIAlertController{
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let okAction : UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: { action in
            self.navigationController?.popViewController(animated: true)
        })
        
        alertController.addAction(okAction)
        return alertController
    }
    
    //update event
    private func updateEvent(newStatus : String , hasAttendee : Bool){
        
        let width = view.frame.size.width / 3
        let size = CGSize(width: width, height: width)
        startAnimating(size, message: Constants.kLoadingTextLogin, type: .ballScaleRipple)
        
        if hasAttendee{
            attendee.responseStatus = newStatus
        }else{
            mainEvent.status = newStatus
        }
        localCalendar.updateEventWithAttendee(event: mainEvent)
    }
    
    
    //change status label
    private func changeStatusLabel(){
        UIView.transition(with: statusLabel,
                          duration: 1.25,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
                            self?.statusLabel.text = self?.getStatusForLabel()
                            self?.statusLabel.textColor = self?.getColorStatusLabel()
            }, completion: nil)
    }
    
    //MARK:
    //MARK: events methods
    
    @IBAction func changeStatusAction(_ sender: UIButton) {
        
        var alertController : UIAlertController
        
        if attendee != nil{
            alertController = getAlertChangeStatusAttendee()
            setAlertActionsAttendee(alertController: alertController)
        }else{
            alertController = getAlertDeleteEvent()
            setAlertActionsEvent(alertController: alertController)
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
}
