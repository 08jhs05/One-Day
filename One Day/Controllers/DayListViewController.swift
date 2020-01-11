//
//  ListViewController.swift
//  One Day
//
//  Created by Jae Ho Shin on 2020-01-03.
//  Copyright © 2020 Jae Ho Shin. All rights reserved.
//

import UIKit
import Foundation

class DayListViewController: UITableViewController{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath)

        cell.textLabel?.text = "first cell"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        performSegue(withIdentifier: "goToSchedule", sender: self)
    }
    
    @IBAction func AddBtnPressed(_ sender: UIBarButtonItem) {
        
    }
}
