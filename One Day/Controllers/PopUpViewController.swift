//
//  PopUpViewController.swift
//  One Day
//
//  Created by Jae Ho Shin on 2020-01-06.
//  Copyright © 2020 Jae Ho Shin. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import PopupDialog

class PopUpViewController: UIViewController{
    
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var AddEventTitle: UILabel!
    
    @IBOutlet weak var nameTxtField: UITextField!
    
    @IBOutlet weak var redBtn: UIButton!
    @IBOutlet weak var orangeBtn: UIButton!
    @IBOutlet weak var yellowBtn: UIButton!
    @IBOutlet weak var greenBtn: UIButton!
    @IBOutlet weak var tealBtn: UIButton!
    @IBOutlet weak var blueBtn: UIButton!
    @IBOutlet weak var indigoBtn: UIButton!
    @IBOutlet weak var purpleBtn: UIButton!
    
    var startTimeHr: Int16?
    var startTimeMin: Int16?
    var endTimeHr: Int16?
    var endTimeMin: Int16?
    var eventName: String = ""
    var pieColor: UIColor = UIColor.red
    
    var delegate: ModalDelegate?
    var scheduleDelegate: ScheduleDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startTimePicker.datePickerMode = UIDatePicker.Mode.time
        endTimePicker.datePickerMode = UIDatePicker.Mode.time
        
        startTimePicker.addTarget(self, action: #selector(dismissKeyboard), for: .allEvents)
        //startTimePicker.addTarget(self, action: #selector(dateChangedStartTime), for: .allEvents)
        endTimePicker.addTarget(self, action: #selector(dismissKeyboard), for: .allEvents)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        nameTxtField.text = delegate?.eventnamePassbyDelegate
        if delegate!.isEditPopup{
            AddEventTitle.text = "Edit Event"
            
            let dateFormatter = DateFormatter() // set locale to reliable US_POSIX
            dateFormatter.dateFormat = "HH:mm"
            let startDate = dateFormatter.date(from:(delegate?.selectedEventStartTime)!)
            let endDate = dateFormatter.date(from:(delegate?.selectedEventEndTime)!)
            
            startTimePicker.setDate(startDate!, animated: false)
            endTimePicker.setDate(endDate!, animated: false)
        }
        //nameTxtField.addTarget(self, action: #selector(textFieldEditingDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        
        readCurrentTIme()
        eventName = nameTxtField.text!
        // Create the dialog

        if (nameTxtField.text == ""){
            
            let alert = UIAlertController(title: "Invalid Input", message: "Please enter a name for event.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        else if (startTimeHr == endTimeHr) && (startTimeMin == endTimeMin){
 
            let alert = UIAlertController(title: "Invalid Input", message: "Please enter valid time.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
            
        else{
        if delegate!.isEditPopup{
            delegate!.deleteEventByDeletage()
        }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Event", in: managedContext)!
        let newEvent = NSManagedObject(entity: entity, insertInto: managedContext)
        
        newEvent.setValue(eventName, forKey: "name")
        newEvent.setValue(startTimeHr, forKey: "startTimeHr")
        newEvent.setValue(startTimeMin, forKey: "startTimeMin")
        newEvent.setValue(endTimeHr, forKey: "endTimeHr")
        newEvent.setValue(endTimeMin, forKey: "endTimeMin")
        newEvent.setValue(pieColor.redValue, forKey: "pieColorR")
        newEvent.setValue(pieColor.greenValue, forKey: "pieColorG")
        newEvent.setValue(pieColor.blueValue, forKey: "pieColorB")
        newEvent.setValue(scheduleDelegate?.parentTitle, forKey: "parentScheduleTitle")
        newEvent.setValue(scheduleDelegate?.parentDate, forKey: "parentScheduleDate")
            
        do {
          try managedContext.save()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
        
        dismiss(animated: true){
            if let delegate = self.delegate {
                delegate.load()
            }
        }
        }
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func redBtnPressed(_ sender: UIButton) {
        dismissKeyboard()
        resetBtnColors()
        sender.tintColor = UIColor.systemRed.mixDarker()
        pieColor = UIColor.systemRed
    }
    @IBAction func orangeBtnPressed(_ sender: UIButton) {

        dismissKeyboard()
        resetBtnColors()
        sender.tintColor = UIColor.systemOrange.mixDarker()
        pieColor = UIColor.systemOrange
    }
    @IBAction func yellowBtnPressed(_ sender: UIButton) {

        dismissKeyboard()
        resetBtnColors()
        sender.tintColor = UIColor.systemYellow.mixDarker()
        pieColor = UIColor.systemYellow
    }
    @IBAction func greenBtnPressed(_ sender: UIButton) {
        
        dismissKeyboard()
        resetBtnColors()
        sender.tintColor = UIColor.systemGreen.mixDarker()
        pieColor = UIColor.systemGreen
    }
    @IBAction func tealBtnPressed(_ sender: UIButton) {
        resetBtnColors()
        sender.tintColor = UIColor.systemTeal.mixDarker()
        pieColor = UIColor.systemTeal
    }
    @IBAction func blueBtnPressed(_ sender: UIButton) {
        resetBtnColors()
        sender.tintColor = UIColor.systemBlue.mixDarker()
        pieColor = UIColor.systemBlue
    }
    @IBAction func indigoBtnPressed(_ sender: UIButton) {
        resetBtnColors()
        sender.tintColor = UIColor.systemIndigo.mixDarker()
        pieColor = UIColor.systemIndigo
    }
    @IBAction func purpleBtnPressed(_ sender: UIButton) {
        resetBtnColors()
        sender.tintColor = UIColor.systemPurple.mixDarker()
        pieColor = UIColor.systemPurple
    }
    
    func resetBtnColors(){
        redBtn.tintColor = UIColor.systemRed
        orangeBtn.tintColor = UIColor.systemOrange
        yellowBtn.tintColor = UIColor.systemYellow
        greenBtn.tintColor = UIColor.systemGreen
        tealBtn.tintColor = UIColor.systemTeal
        blueBtn.tintColor = UIColor.systemBlue
        indigoBtn.tintColor = UIColor.systemIndigo
        purpleBtn.tintColor = UIColor.systemPurple
    }
    
    func readCurrentTIme(){
        let userCalendar = Calendar.current
        let requestedComponents: Set<Calendar.Component> = [.hour, .minute,]
        let startTime = userCalendar.dateComponents(requestedComponents, from: startTimePicker.date)
        let endTime = userCalendar.dateComponents(requestedComponents, from: endTimePicker.date)
        
        startTimeHr = Int16(startTime.hour!)
        startTimeMin = Int16(startTime.minute!)
        endTimeHr = Int16(endTime.hour!)
        endTimeMin = Int16(endTime.minute!)
    }
    
    @objc func dateChangedStartTime(_ sender: UIDatePicker) {

//        let userCalendar = Calendar.current
//        let requestedComponents: Set<Calendar.Component> = [.hour, .minute,]
//        let dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: sender.date)
//
//        startTimeHr = Int16(dateTimeComponents.hour!)
//        startTimeMin = Int16(dateTimeComponents.minute!)
        //endTimePicker.minimumDate = sender.date
    }
//    @objc func dateChangedEndTime(_ sender: UIDatePicker) {
//
//        let userCalendar = Calendar.current
//        let requestedComponents: Set<Calendar.Component> = [.hour, .minute,]
//        let dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: sender.date)
//
//        endTimeHr = Int16(dateTimeComponents.hour!)
//        endTimeMin = Int16(dateTimeComponents.minute!)
//    }
    
    @objc func textFieldEditingDidChange(_ sender: UITextField) {
        eventName = sender.text!
    }
    
    @objc func dismissKeyboard() {
        eventName = nameTxtField.text!
        view.endEditing(true)
    }
}

extension UIColor {
    
    var redValue: CGFloat{ return CIColor(color: self).red }
    var greenValue: CGFloat{ return CIColor(color: self).green }
    var blueValue: CGFloat{ return CIColor(color: self).blue }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }

    func mixLighter (amount: CGFloat = 0.4) -> UIColor {
        return mixWithColor(UIColor.white, amount:amount)
    }

    func mixDarker (amount: CGFloat = 0.4) -> UIColor {
        return mixWithColor(UIColor.black, amount:amount)
    }

    func mixWithColor(_ color: UIColor, amount: CGFloat = 0.25) -> UIColor {
        var r1     : CGFloat = 0
        var g1     : CGFloat = 0
        var b1     : CGFloat = 0
        var alpha1 : CGFloat = 0
        var r2     : CGFloat = 0
        var g2     : CGFloat = 0
        var b2     : CGFloat = 0
        var alpha2 : CGFloat = 0

        self.getRed (&r1, green: &g1, blue: &b1, alpha: &alpha1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &alpha2)
        return UIColor( red:r1*(1.0-amount)+r2*amount,
                        green:g1*(1.0-amount)+g2*amount,
                        blue:b1*(1.0-amount)+b2*amount,
                        alpha: alpha1 )
    }
}
