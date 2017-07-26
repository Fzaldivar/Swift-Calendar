//
//  NewEventViewController.swift
//  iOSGoogleCalendar
//
//  Created by Zaldivar Coto, F. on 7/25/17.
//  Copyright © 2017 Zaldivar Coto, F. All rights reserved.
//

import UIKit
import DateTimePicker

class NewEventViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UITextFieldDelegate {

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
    // MARK:
    // MARK: initialize methods
    
    private func initialize(){
        
        title = titleNewEvent
        
        textViewDescription.text = textViewDescriptionPlaceholder
        textViewDescription.textColor = UIColor.lightGray
        
        calendarButton = UIBarButtonItem(image: UIImage.init(named: "calendar"), style: .plain, target: self, action: #selector(showDatePicker))
        navigationItem.rightBarButtonItem = calendarButton
        
        selectedDate = Date()
        initializeDatePicker()
        

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
        pickerDate.selectedDate = selectedDate
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
        // User finished typing (hit return): hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK:
    // MARK: public methods
    
    func showDatePicker(){
        initializeDatePicker()
    }
    
    
    
}
