//
//  NewEventViewController.swift
//  iOSGoogleCalendar
//
//  Created by Zaldivar Coto, F. on 7/25/17.
//  Copyright © 2017 Zaldivar Coto, F. All rights reserved.
//

import UIKit
import DateTimePicker
import GoogleAPIClientForREST

class NewEventViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UITextFieldDelegate,LocalCalendarProtocol {

    // MARK:
    // MARK: constants
    let pickerComponents : Int = 1
    let pickerData : [String] = ["Hours","0.5","1","1.5","2","2.5","3","3.5","4"]
    let titleNewEvent : String = "New Event"
    let textViewDescriptionPlaceholder = "Description"
    
    
    
    // MARK:
    // MARK: properties
    
    @IBOutlet weak var hoursPickerView: UIPickerView!
    @IBOutlet weak var textViewDescription: UITextView!
    @IBOutlet weak var textFieldSummary: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    
    var calendarButton : UIBarButtonItem!
    var pickerDate :DateTimePicker!
    var selectedDate : Date!
    var localCalendar : LocalCalendar!
    
    
    // MARK:
    // MARK: initialize methods
    
    private func initialize(){
        
        title = titleNewEvent
        
        textViewDescription.text = textViewDescriptionPlaceholder
        textViewDescription.textColor = UIColor.lightGray
        
        calendarButton = UIBarButtonItem(image: UIImage.init(named: "calendar"), style: .plain, target: self, action: #selector(showDatePicker))
        navigationItem.rightBarButtonItem = calendarButton
        
        //properties
        selectedDate = nil
        dateLabel.text = "Choose a date"
        initializeDatePicker()
        localCalendar = LocalCalendar.shared
        localCalendar.delegate = self

    }
    
    
    private func initializeDatePicker(){
        let min = Date()
        let max = Date().addingTimeInterval(60 * 60 * 24 * 30)
        pickerDate = DateTimePicker.show(minimumDate: min, maximumDate: max)
        pickerDate.highlightColor = UIColor(red: 22.0/255.0, green: 127.0/255.0, blue: 251.0/255.0, alpha: 1)
        pickerDate.darkColor = UIColor.darkGray
        pickerDate.doneButtonTitle = "DONE"
        pickerDate.todayButtonTitle = "Today"
        pickerDate.is12HourFormat = true
        pickerDate.dateFormat = "hh:mm aa dd/MM/YYYY"
        
        pickerDate.completionHandler = { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
            self.selectedDate = self.pickerDate.selectedDate
            self.dateLabel.text = formatter.string(from: date)
        }
        
    }
    
    
    // MARK:
    // MARK: override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK:
    // MARK: delegate methods
    
    //MARK: picker data source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerComponents;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //MARK: picker delegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    //MARK: textview delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textViewDescriptionPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    //MARK: textfield delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: LocalCalendarProtocol
    func createEvent(success: Bool) {
        if success{
            navigationController?.popToRootViewController(animated: true)
        }else{
            print("No se agregó")
        }
    }
    
    // MARK:
    // MARK: private methods
    
    //check if textFieldSummary is ready to create an event
    private func isTextFieldSummaryReady () -> Bool{
        return !textFieldSummary.text!.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    //check if textViewDescription is ready to create an event
    private func isTextViewDescriptionReady() -> Bool{
        return !textViewDescription.text!.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    //check if hoursPickerView is ready to create an event
    private func isHoursPickerViewReady() -> Bool{
        return hoursPickerView.selectedRow(inComponent: pickerComponents - 1) != 0
    }
    
    private func addEvent(){
        let newEvent : GTLRCalendar_Event = GTLRCalendar_Event.init()
        
        //details
        newEvent.summary = textFieldSummary.text
        newEvent.descriptionProperty = textViewDescription.text
        
        let duration : Double = Double(pickerData[hoursPickerView.selectedRow(inComponent: 0)])!
        
        
        //dates
        let newStartDate : Date = selectedDate
        let newEndDate : Date = newStartDate.addingTimeInterval((60 * 60) * duration)
        
        let startTime : GTLRDateTime = GTLRDateTime.init(date: newStartDate)
        let endTime : GTLRDateTime = GTLRDateTime.init(date: newEndDate)
        
        newEvent.start = GTLRCalendar_EventDateTime.init()
        newEvent.end = GTLRCalendar_EventDateTime.init()
        
        newEvent.start?.dateTime = startTime
        newEvent.end?.dateTime = endTime
        localCalendar.addingNewEvent(event: newEvent)
    }
    
    // MARK:
    // MARK: public methods
    
    func showDatePicker(){
        initializeDatePicker()
    }
    
    // MARK:
    // MARK: events methods
    
    @IBAction func createEvent(_ sender: UIButton) {
        if isTextFieldSummaryReady() && isTextViewDescriptionReady() && isHoursPickerViewReady() && selectedDate != nil{
            addEvent()
        }else{
            let alertController = UIAlertController(title: "Error", message: "Please complete the form", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel) { action in}
            alertController.addAction(cancelAction)
            present(alertController, animated: true) {}
        }
    }
    
}
