//
//  CreateScheduleViewController.swift
//  One Day
//
//  Created by Jae Ho Shin on 2020-01-03.
//  Copyright © 2020 Jae Ho Shin. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol ModalDelegate{
    func load()
    func deleteEventByDeletage()
    var eventnamePassbyDelegate: String? {
        get 
    }
    var isEditPopup: Bool {
        get
    }
    var selectedEventStartTime: String? {
        get
    }
    var selectedEventEndTime: String? {
        get
    }
}

class CreateScheduleViewController: UIViewController, ModalDelegate{

    var delegate: ScheduleDelegate?
    
    var eventnamePassbyDelegate: String? = ""

    @IBOutlet weak var scheduleList: UIView!
    @IBOutlet weak var scheduleListInner: UIView!
    @IBOutlet weak var eventList: UITableView!
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var expandBtn: UIButton!
    @IBOutlet weak var collapseBtn: UIButton!
    @IBOutlet weak var removeItemBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var titletextfield: UITextField!
    @IBOutlet weak var circleView: CirclePieView!
    @IBOutlet weak var clockView: UIView!
    
    //constraints
    
    @IBOutlet weak var clockviewtop: NSLayoutConstraint!
    //============
    
    var titleText:String?
    
    var events: [NSManagedObject] = []
    var eventsData: [EventData] = []
    var isEditPopup = false

    var currentCellFocus = 999
    
    var colorBeforeClicked:UIColor? = nil
    var isPieClicked = false
    
    var selectedEventStartTime: String?
    var selectedEventEndTime: String?
    
    var isAlarmTurnedOn = false
    @IBOutlet weak var alarmBtn: UIBarButtonItem!
    
    var originalscheduleListHeight:CGFloat?
    let collapsedscheduleListHeight:CGFloat = 40.0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        originalscheduleListHeight = scheduleListInner.frame.height
        
        scheduleListInner.layer.cornerRadius = 15
        eventList.delegate = self
        eventList.dataSource = self
        eventList.register(UINib(nibName: "eventItemCell", bundle: nil), forCellReuseIdentifier: "eventItemCell")
        
        load()
        titleText = delegate?.parentTitle

        titletextfield.addTarget(self, action: #selector(textFieldEditingDidChange(_:)), for: UIControl.Event.editingChanged)
        titletextfield.addTarget(self, action: #selector(textFieldEditingDidEnd(_:)), for: UIControl.Event.editingDidEnd)
        titletextfield.text = titleText
        
        let dismisskeyboardTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismisskeyboardTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismisskeyboardTap)
        self.circleView.addGestureRecognizer(dismisskeyboardTap)
        
        if isAlarmTurnedOn == true{
            alarmBtn.image = UIImage(systemName: "bell.slash")
        }
        else {
            alarmBtn.image = UIImage(systemName: "bell")
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        load()
    }
    
// MARK: button action methods
    
    @IBAction func collapseBtnPressed(_ sender: Any) {
        
        //clockviewtop.isActive = false
        //schedulelisttop.isActive = false
        //clockviewtop.isActive = false
        
        clockView.translatesAutoresizingMaskIntoConstraints = true
        scheduleListInner.translatesAutoresizingMaskIntoConstraints = true
        scheduleList.translatesAutoresizingMaskIntoConstraints = true
        
        UIView.animate(withDuration: 0.5) {
            
            self.clockView.frame = CGRect(x: self.clockView.frame.origin.x, y: self.clockView.frame.origin.y + 80, width: self.clockView.frame.width, height: self.clockView.frame.height)
            
            self.scheduleListInner.frame = CGRect( x: self.scheduleListInner.frame.origin.x, y: self.scheduleListInner.frame.origin.y + self.scheduleListInner.frame.height, width: self.scheduleListInner.frame.width, height: -self.collapsedscheduleListHeight)

        }
        
        collapseBtn.isHidden = true
        addBtn.isHidden = true
        expandBtn.isHidden = false
        removeItemBtn.isHidden = true
        editBtn.isHidden = true
        
        disselectCell()
    }
    
    @IBAction func ExpandBtnPressed(_ sender: Any) {
        
        
        UIView.animate(withDuration: 0.5) {
            
            self.clockView.frame = CGRect(x: self.clockView.frame.origin.x, y: self.clockView.frame.origin.y - 80, width: self.clockView.frame.width, height: self.clockView.frame.height)
            
            self.scheduleListInner.frame = CGRect( x: self.scheduleListInner.frame.origin.x, y: self.scheduleListInner.frame.origin.y - self.originalscheduleListHeight! + self.collapsedscheduleListHeight, width: self.scheduleListInner.frame.width, height: self.originalscheduleListHeight!)
        }
        collapseBtn.isHidden = false
        addBtn.isHidden = false
        expandBtn.isHidden = true
        
        clockView.translatesAutoresizingMaskIntoConstraints = false
        scheduleListInner.translatesAutoresizingMaskIntoConstraints = false
        scheduleList.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //shows popup and let user enter new event data
    @IBAction func saveBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Saved!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(alert: UIAlertAction!) in self.navigationController?.popViewController(animated: true)}))
        self.present(alert, animated: true, completion: nil)

    }

    @IBAction func alarmBtnPressed(_ sender: UIBarButtonItem) {
        
        let center = UNUserNotificationCenter.current()
        
        if isAlarmTurnedOn == false {

        center.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
            if granted {
                
            } else {
                print("Notification permissions not granted")
            }
        })
        
        for event in eventsData{
            
            let components = DateComponents(hour: Int(event.startTimeHr!), minute: Int(event.startTimeMin!)) // Set the date here when you want Notification
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

            let content = UNMutableNotificationContent()
            content.title = titleText!
            content.body = event.eventName!
            content.sound = UNNotificationSound.default

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { (error : Error?) in
                if let theError = error {
                    print(theError.localizedDescription)
                }
            }
        }
        sender.image = UIImage(systemName: "bell.slash")
            
        let alert = UIAlertController(title: "Alarm turned on", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
            
            isAlarmTurnedOn = true
        }
            
        else {
            
            center.removeAllDeliveredNotifications()
            center.removeAllPendingNotificationRequests()
            sender.image = UIImage(systemName: "bell")
                
            let alert = UIAlertController(title: "Alarm turned off", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            isAlarmTurnedOn = false
        }
        
        // ===========================
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                         return
                       }
                       let managedContext = appDelegate.persistentContainer.viewContext

                       let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Schedule")

                       fetchRequest.predicate = NSPredicate(format:"(dateCreated == %@) AND (title == %@)", (delegate?.parentDate)!, (delegate?.parentTitle)!)

                       do {
                           let fetchedData = try managedContext.fetch(fetchRequest)
                           fetchedData[0].setValue(isAlarmTurnedOn, forKey: "isAlarmTurnedOn")
                       } catch let error as NSError {
                         print("Could not fetch. \(error), \(error.userInfo)")
                       }
                
        // ===========================
    }
    
    @IBAction func AddBtnPressed(_ sender: Any) {
        disselectCell()
        eventnamePassbyDelegate = ""
        isEditPopup = false
        performSegue(withIdentifier: "addNewItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! PopUpViewController
        destinationVC.delegate = self
        destinationVC.scheduleDelegate = delegate
        
        if isEditPopup{
            eventnamePassbyDelegate = eventsData[currentCellFocus].eventName
        }
        if currentCellFocus != 999{
            self.selectedEventStartTime = String(format:"%d:%d", eventsData[currentCellFocus].startTimeHr!, eventsData[currentCellFocus].startTimeMin!)
            self.selectedEventEndTime = String(format:"%d:%d", eventsData[currentCellFocus].endTimeHr!, eventsData[currentCellFocus].endTimeMin!)
    
        }
    }
    
    @IBAction func removeBtnPressed(_ sender: Any) {
        
        if currentCellFocus != 999{
            deleteEvent(eventsToDelete: eventsData[currentCellFocus])
            eventsData.remove(at: currentCellFocus)
            load()
        }
        currentCellFocus = 999
    }
    
    func deleteEventByDeletage() {
        if currentCellFocus != 999{
            deleteEvent(eventsToDelete: eventsData[currentCellFocus])
            eventsData.remove(at: currentCellFocus)
            load()
        }
        currentCellFocus = 999
    }
    
    @IBAction func editBtnPressed(_ sender: Any) {
        disselectCell()
        removeItemBtn.isHidden = true
        editBtn.isHidden = true
        
        isEditPopup = true
        performSegue(withIdentifier: "addNewItem", sender: self)
    }

    
// MARK: Coredata Methods
    
    func load(){

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")

        fetchRequest.predicate = NSPredicate(format:"(parentScheduleDate == %@) AND (parentScheduleTitle == %@)", (delegate?.parentDate)!, (delegate?.parentTitle)!)
        
        let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "Schedule")

        fetchRequest2.predicate = NSPredicate(format:"(dateCreated == %@) AND (title == %@)", (delegate?.parentDate)!, (delegate?.parentTitle)!)
        
        do {
            events = try managedContext.fetch(fetchRequest)
            let fetchedData = try managedContext.fetch(fetchRequest2)
            isAlarmTurnedOn = fetchedData[0].value(forKey: "isAlarmTurnedOn") as? Bool ?? false
            
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        eventList.reloadData()
        
        if events.count != circleView.events.count{
            
            circleView.reset()
            eventsData.removeAll()
            
            for event in events{
                
                let newEvent = nsObjectToUsableVariable(event: event)
                eventsData.append(newEvent)
                circleView.addNewSchedule(startTimeHrParam: newEvent.startTimeHr!,
                                          startTime: nsObjectToParameter(eventFromCoredata: event).0,
                                          endTime: nsObjectToParameter(eventFromCoredata: event).1,
                                          pieColor: nsObjectToParameter(eventFromCoredata: event).2, name: newEvent.eventName!)
            }
            
            //sorts events in ascending order
            eventsData = eventsData.sorted(by: {$0.startTimeHr! < $1.startTimeHr!})
        }
        
    }
    
    func deleteEvent(eventsToDelete: EventData){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        
        fetchRequest.predicate = NSPredicate(format:"(startTimeHr == %d) AND (startTimeMin == %d) AND (endTimeHr == %d) AND (endTimeMin == %d) AND (parentScheduleDate == %@) AND (parentScheduleTitle == %@)", eventsToDelete.startTimeHr!, eventsToDelete.startTimeMin!, eventsToDelete.endTimeHr!, eventsToDelete.endTimeMin! , (delegate?.parentDate)!, (delegate?.parentTitle)!)
        
        let result = try? context.fetch(fetchRequest)
        let resultData = result as! [NSManagedObject]

        for object in resultData {
            context.delete(object)
        }

        do {
            try context.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
}

// MARK: tableview delegate methods

extension CreateScheduleViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let event = eventsData[indexPath.row]
        let cell = self.eventList.dequeueReusableCell(withIdentifier: "eventItemCell") as! EventItemCell
        
        cell.fillContents(
            piecolor: event.pieColor!,
            startTimeHr: Int(event.startTimeHr!),
            startTimeMin: Int(event.startTimeMin!),
            endTimeHr: Int(event.endTimeHr!),
            endTimeMin: Int(event.endTimeMin!),
            eventName: event.eventName!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return events.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        removeItemBtn.isHidden = false
        editBtn.isHidden = false
        currentCellFocus = indexPath.row
        
        if (isPieClicked == false){
        for pie in circleView.events{
            if (pie.startTimeHr == eventsData[currentCellFocus].startTimeHr) && (pie.name == eventsData[currentCellFocus].eventName){
                colorBeforeClicked = pie.color
                pie.color = pie.color?.mixDarker()
                pie.setNeedsDisplay()
                break
            }
            }
            isPieClicked = true
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        for pie in circleView.events{
            if (pie.startTimeHr == eventsData[currentCellFocus].startTimeHr) && (pie.name == eventsData[currentCellFocus].eventName){
                pie.color = colorBeforeClicked
                pie.setNeedsDisplay()
                break
            }
        }
        isPieClicked = false
    }
    
// MARK: Outlet action methods
    @objc func textFieldEditingDidChange(_ sender: UITextField) {
        titleText = sender.text!

    }
    @objc func textFieldEditingDidEnd(_ sender: UITextField){

        titleText = sender.text!
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                 return
               }
               let managedContext = appDelegate.persistentContainer.viewContext

               let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Schedule")

               fetchRequest.predicate = NSPredicate(format:"(dateCreated == %@) AND (title == %@)", (delegate?.parentDate)!, (delegate?.parentTitle)!)
        
                let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "Event")
        
                fetchRequest2.predicate = NSPredicate(format:"(parentScheduleDate == %@) AND (parentScheduleTitle == %@)", (delegate?.parentDate)!, (delegate?.parentTitle)!)

               do {
                   let fetchedData = try managedContext.fetch(fetchRequest)
                   fetchedData[0].setValue(titleText, forKey: "title")
                
                let fetchedData2 = try managedContext.fetch(fetchRequest2)
                for index in 0..<fetchedData2.count{
                    fetchedData2[index].setValue(titleText, forKey: "parentScheduleTitle")
                }
               } catch let error as NSError {
                 print("Could not fetch. \(error), \(error.userInfo)")
               }
    }

    @objc func dismissKeyboard() {
        titleText = titletextfield.text!
        view.endEditing(true)
        disselectCell()
    }
    
// MARK: helper methods

    func disselectCell(){
        if (currentCellFocus != 999){

        eventList.deselectRow(at: [0,currentCellFocus], animated: true)
        for pie in circleView.events{
            if (pie.startTimeHr == eventsData[currentCellFocus].startTimeHr) && (pie.name == eventsData[currentCellFocus].eventName){
                pie.color = colorBeforeClicked
                pie.setNeedsDisplay()
                break
            }
            }}
        isPieClicked = false
    }

    
    func nsObjectToUsableVariable(event: NSManagedObject) -> EventData{
        
        return EventData(name: event.value(forKey: "name") as! String,
                         startTimeHr: event.value(forKey: "startTimeHr") as! Int16,
                         startTimeMin: event.value(forKey: "startTimeMin") as! Int16,
                         endTimeHr: event.value(forKey: "endTimeHr") as! Int16,
                         endTimeMin: event.value(forKey: "endTimeMin") as! Int16,
                         pieColor: UIColor(
                         red: CGFloat(event.value(forKey: "pieColorR") as! Float),
                         green: CGFloat(event.value(forKey: "pieColorG") as! Float),
                         blue: CGFloat(event.value(forKey: "pieColorB") as! Float),
                         alpha: 1.0)
        )
    }
    
    func nsObjectToParameter(eventFromCoredata: NSManagedObject) -> (Float, Float, UIColor){
        
        let startTimeInFloat = Float(eventFromCoredata.value(forKey: "startTimeHr") as! Int) + Float(eventFromCoredata.value(forKey: "startTimeMin") as! Int)/60.0
        let endTimeInFloat = Float(eventFromCoredata.value(forKey: "endTimeHr") as! Int) + Float(eventFromCoredata.value(forKey: "endTimeMin") as! Int)/60.0
        
        let color = UIColor(
        red: CGFloat(eventFromCoredata.value(forKey: "pieColorR") as! Float),
        green: CGFloat(eventFromCoredata.value(forKey: "pieColorG") as! Float),
        blue: CGFloat(eventFromCoredata.value(forKey: "pieColorB") as! Float),
        alpha: 1.0)
        
        return(startTimeInFloat, endTimeInFloat, color)
    }
}

