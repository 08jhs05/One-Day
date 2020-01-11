//
//  CreateScheduleViewController.swift
//  One Day
//
//  Created by Jae Ho Shin on 2020-01-03.
//  Copyright © 2020 Jae Ho Shin. All rights reserved.
//

import Foundation
import UIKit
import PopupDialog
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
}

class CreateScheduleViewController: UIViewController, ModalDelegate{

    
    var eventnamePassbyDelegate: String? = ""

    @IBOutlet weak var scheduleList: UIView!
    @IBOutlet weak var scheduleListInner: UIView!
    @IBOutlet weak var eventList: UITableView!
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var expandBtn: UIButton!
    @IBOutlet weak var collapseBtn: UIButton!
    @IBOutlet weak var removeItemBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var circleView: CirclePieView!
    
    var events: [NSManagedObject] = []
    var eventsData: [EventData] = []
    var isEditPopup = false
    
    var currentCellFocus = 999
    
    let originalscheduleListWidth:CGFloat = 350
    let originalscheduleListHeight:CGFloat = 240
    let collapsedscheduleListHeight:CGFloat = 40
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scheduleListInner.layer.cornerRadius = 15
        eventList.delegate = self
        eventList.dataSource = self
        eventList.register(UINib(nibName: "eventItemCell", bundle: nil), forCellReuseIdentifier: "eventItemCell")
        
        load()
        if events.count == 0 { makeDefaultData() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        load()
    }
    
// MARK: button action methods
    
    @IBAction func collapseBtnPressed(_ sender: Any) {
        
        UIView.animate(withDuration: 0.5) {
            self.scheduleListInner.frame = CGRect( x: self.scheduleListInner.frame.origin.x, y: self.scheduleListInner.frame.origin.y + self.scheduleListInner.frame.height, width: self.originalscheduleListWidth, height: -self.collapsedscheduleListHeight)
        }
        collapseBtn.isHidden = true
        addBtn.isHidden = true
        expandBtn.isHidden = false
        removeItemBtn.isHidden = true
        editBtn.isHidden = true
        
        eventList.deselectRow(at: [0,currentCellFocus], animated: true)
    }
    
    @IBAction func ExpandBtnPressed(_ sender: Any) {
        
        UIView.animate(withDuration: 0.5) {
            self.scheduleListInner.frame = CGRect( x: self.scheduleListInner.frame.origin.x, y: self.scheduleListInner.frame.origin.y - self.originalscheduleListHeight + self.collapsedscheduleListHeight, width: self.originalscheduleListWidth, height: self.originalscheduleListHeight)
        }
        collapseBtn.isHidden = false
        addBtn.isHidden = false
        expandBtn.isHidden = true
    }
    
    //shows popup and let user enter new event data
    
    @IBAction func AddBtnPressed(_ sender: Any) {
        
        eventnamePassbyDelegate = ""
        isEditPopup = false
        performSegue(withIdentifier: "addNewItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! PopUpViewController
        destinationVC.delegate = self
        
        if isEditPopup{
            eventnamePassbyDelegate = eventsData[currentCellFocus].eventName
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
        
        eventList.deselectRow(at: [0,currentCellFocus], animated: false)
        removeItemBtn.isHidden = true
        editBtn.isHidden = true
        
        isEditPopup = true
        performSegue(withIdentifier: "addNewItem", sender: self)
    }

    
// MARK: Coredata Methods
    
    func makeDefaultData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Event", in: managedContext)!
        let defaultEvent = NSManagedObject(entity: entity, insertInto: managedContext)
        
        defaultEvent.setValue("sleep", forKey: "name")
        defaultEvent.setValue(21, forKey: "startTimeHr")
        defaultEvent.setValue(30, forKey: "startTimeMin")
        defaultEvent.setValue(6, forKey: "endTimeHr")
        defaultEvent.setValue(30, forKey: "endTimeMin")
        defaultEvent.setValue(0.0, forKey: "pieColorR")
        defaultEvent.setValue(122.0/255.0, forKey: "pieColorG")
        defaultEvent.setValue(1.0, forKey: "pieColorB")
        
        do {
          try managedContext.save()
            events.append(defaultEvent)
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
        
        //circleView.addNewSchedule(startTime: 9.5, endTime: 12.5, pieColor: UIColor.yellow)
        
    }
    
    func load(){

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
        
        do {
          events = try managedContext.fetch(fetchRequest)
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
                circleView.addNewSchedule(startTime: nsObjectToParameter(eventFromCoredata: event).0,
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
        
        fetchRequest.predicate = NSPredicate(format:"(startTimeHr == %d) AND (startTimeMin == %d)", eventsToDelete.startTimeHr!, eventsToDelete.startTimeMin!)
        
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
        //print(currentCellFocus)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)

    }
    
// MARK: helper methods

    
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

