//
//  ListViewController.swift
//  One Day
//
//  Created by Jae Ho Shin on 2020-01-03.
//  Copyright © 2020 Jae Ho Shin. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol ScheduleDelegate{
    var parentTitle: String?{
        get
    }
    var parentDate: String?{
        get
    }
}

class DayListViewController: UITableViewController, ScheduleDelegate{
    
    var parentTitle: String?
    var parentDate: String?
    
    var schedules: [NSManagedObject] = []
    var events: [[NSManagedObject]] = [[]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems![1] = editButtonItem
        tableView.register(UINib(nibName: "MainMenuCell", bundle: nil), forCellReuseIdentifier: "MainMenuCell")
        load()
        if schedules.count == 0 { createNewData(title: "MY DAY") }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        load()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainMenuCell") as! MainMenuCell

        cell.title.text = schedules[indexPath.row].value(forKey: "title") as? String
        cell.date.text = schedules[indexPath.row].value(forKey: "dateCreated") as? String
//=======
        
        cell.thumbnail.reset()
        
        for eventNSObj in events[indexPath.row]{
                cell.thumbnail.addNewSchedule(startTimeHrParam: 0,
                                              startTime: nsObjectToParameter(eventFromCoredata: eventNSObj).0,
                                              endTime: nsObjectToParameter(eventFromCoredata:eventNSObj).1,
                                              pieColor: nsObjectToParameter(eventFromCoredata: eventNSObj).2, name: "")
        }
        
//=======

        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return schedules.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        parentTitle = schedules[indexPath.row].value(forKey: "title") as? String
        parentDate = schedules[indexPath.row].value(forKey: "dateCreated") as? String
        
        performSegue(withIdentifier: "goToSchedule", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! CreateScheduleViewController
        destinationVC.delegate = self
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            let scheduleToDelete = schedules[indexPath.row]
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext

            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Schedule")
            
            fetchRequest.predicate = NSPredicate(format:"(dateCreated == %@) AND (title == %@)",
                                                 scheduleToDelete.value(forKey: "dateCreated") as! String,
                                                 scheduleToDelete.value(forKey: "title") as! String
            )
            
            let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "Event")
            
            fetchRequest2.predicate = NSPredicate(format:"(parentScheduleDate == %@) AND (parentScheduleTitle == %@)", scheduleToDelete.value(forKey: "dateCreated") as! String, scheduleToDelete.value(forKey: "title") as! String)
            
            let result = try? context.fetch(fetchRequest)
            let resultData = result as! [NSManagedObject]
            
            let resultEvent = try? context.fetch(fetchRequest2)
            let resultEventData = resultEvent!

            for object in resultData {
                context.delete(object)
            }
            
            for object in resultEventData {
                context.delete(object)
            }

            do {
                try context.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            load()
            // =====================================
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    @IBAction func AddBtnPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Schedule", message: "Enter a name for your schedule:", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {alertinput -> Void in
            
            let newTitle = alert.textFields![0].text!
            
            if newTitle != ""{
                self.createNewData(title: newTitle)
                self.load()
                self.tableView.reloadData()
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func createNewData(title: String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let scheduleEntity = NSEntityDescription.entity(forEntityName: "Schedule", in: managedContext)!
        let defaultSchedule = NSManagedObject(entity: scheduleEntity, insertInto: managedContext)
        
        let eventEntity = NSEntityDescription.entity(forEntityName: "Event", in: managedContext)!
        let defaultEvent = NSManagedObject(entity: eventEntity, insertInto: managedContext)
        
        defaultEvent.setValue("sleep", forKey: "name")
        defaultEvent.setValue(21, forKey: "startTimeHr")
        defaultEvent.setValue(30, forKey: "startTimeMin")
        defaultEvent.setValue(6, forKey: "endTimeHr")
        defaultEvent.setValue(30, forKey: "endTimeMin")
        defaultEvent.setValue(0.0, forKey: "pieColorR")
        defaultEvent.setValue(122.0/255.0, forKey: "pieColorG")
        defaultEvent.setValue(1.0, forKey: "pieColorB")
        defaultEvent.setValue(title, forKey: "parentScheduleTitle")
        
        
        defaultSchedule.setValue(title, forKey: "title")
        defaultSchedule.setValue(false, forKey: "isAlarmTurnedOn")
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let searchKeyword = formatter.string(from: date)
        defaultSchedule.setValue(searchKeyword, forKey: "dateCreated")
        defaultEvent.setValue(searchKeyword, forKey: "parentScheduleDate")
        
        do {
          try managedContext.save()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func load(){

         guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
             return
         }
        events.removeAll()
        
         let managedContext = appDelegate.persistentContainer.viewContext
         
         let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Schedule")
         
         do {
           schedules = try managedContext.fetch(fetchRequest)
         } catch let error as NSError {
           print("Could not fetch. \(error), \(error.userInfo)")
         }
        
         let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")

        for index in 0..<schedules.count {

            let dateloaded = schedules[index].value(forKey: "dateCreated") as! String
            let title = schedules[index].value(forKey: "title") as! String

            fetchRequest2.predicate = NSPredicate(format:"(parentScheduleDate == %@) AND (parentScheduleTitle == %@)", dateloaded, title)
            
            do {
                try events.append(managedContext.fetch(fetchRequest2) as! [NSManagedObject])
            } catch let error as NSError {
              print("Could not fetch. \(error), \(error.userInfo)")
            }

        }
        
        tableView.reloadData()
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
