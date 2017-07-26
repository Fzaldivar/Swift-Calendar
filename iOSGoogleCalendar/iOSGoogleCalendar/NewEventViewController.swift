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
    
    // MARK:
    // MARK: initialize methods
    
    private func initialize(){
        
        title = titleNewEvent
        
        textViewDescription.text = textViewDescriptionPlaceholder
        textViewDescription.textColor = UIColor.lightGray
        
//        let min = Date()
//        let max = Date().addingTimeInterval(60 * 60 * 24 * 4)
//        let picker = DateTimePicker.show(minimumDate: min, maximumDate: max)
//        picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
//        picker.darkColor = UIColor.darkGray
//        picker.doneButtonTitle = "!! DONE DONE !!"
//        picker.todayButtonTitle = "Today"
//        picker.is12HourFormat = true
//        picker.dateFormat = "hh:mm aa dd/MM/YYYY"
//        //        picker.isDatePickerOnly = true
//        picker.completionHandler = { date in
//            let formatter = DateFormatter()
//            formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
//            //self.item.title = formatter.string(from: date)
//        }
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
}
