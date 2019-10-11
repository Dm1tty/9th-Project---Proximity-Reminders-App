//
//  ViewController.swift
//  Proximity Reminders App
//
//  Created by Dzmitry Matsiulka on 10/1/19.
//  Copyright © 2019 Dzmitry M. All rights reserved.
//

import UIKit
import CoreData
import MapKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var reminders = [Reminder]()
    let locationManager = CLLocationManager()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        // Do any additional setup after loading the view.
        
        
    
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminders")
        
        request.returnsObjectsAsFaults = false
              do {
                  let result = try context.fetch(request)
                  for data in result as! [NSManagedObject] {
              
                     
                      let description = data.value(forKey: "reminderDescription") as! String
                    
                    let latitude = data.value(forKey: "reminderLatitude") as! Double
                    let longitude = data.value(forKey: "reminderLongitude") as! Double
                    let whenEnter = data.value(forKey: "whenEnter") as! Bool
                    let locationName = data.value(forKey: "reminderLocationName") as! String
                    
                    
                    let reminderToAdd = Reminder(remindTo: description, longitude: longitude, latitude: latitude, locationName: locationName, whenEnter: whenEnter, isInNow: false)
                    print(reminderToAdd)
                    reminders.append(reminderToAdd)
        }
                
            } catch {
                
                print("Failed")
            }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        }

  
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            do {
                        let context = appDelegate.persistentContainer.viewContext
                        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminders")
                       let result = try context.fetch(request)
                     let resultData = result as! [NSManagedObject]
                print("This is to be deleted: \(resultData[indexPath.row])")
                context.delete(resultData[indexPath.row])
                   }
                
                   catch{
                       print(error)
                   }
            reminders.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    

    func isInsideOfRemainder(currentLocation: CLLocationCoordinate2D, reminderLocationToCheck compareTo: CLLocation) -> Bool{

        let location = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        let distanceThreshold = 20.0 // meters
        
        if location.distance(from: CLLocation.init(latitude: compareTo.coordinate.latitude,
                                                   longitude: compareTo.coordinate.longitude)) < distanceThreshold
        {
            // executes if you are in 20 meters from your point
            return true
        } else {
            // executes if you are outside
            return false
                    }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
       
      
      
        
        
        
        for reminder in reminders{
            
            let location : CLLocation = CLLocation(latitude: reminder.latitude, longitude: reminder.longitude)
            
            // executes if you are inside of the chosen location
            if isInsideOfRemainder(currentLocation: locValue, reminderLocationToCheck: location) == true{
                
                // executes when you user enters location and remainder should pop out when one enters
                if reminder.isInNow == false && reminder.whenEnter == true{
                    
                    let reminderName = "You have entered and you have to:"
                    let remainderMessage = reminder.remindTo
                  let reminderAlert = UIAlertController.init(title: reminderName, message: remainderMessage, preferredStyle: .actionSheet)
                   let okayButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
                   reminderAlert.addAction(okayButton)
                    print("User entered needed location")
                    
                    self.present(reminderAlert, animated: true)
                }
                reminder.isInNow = true
                print("You are currently inside of \(reminder.remindTo)")
            }
                
            else{
                
                // this case executes when user leaves location and remainder should pop out when one exits
                if reminder.isInNow == true && reminder.whenEnter == false{
                    print("You left and have to \(reminder.remindTo)")
                    let reminderName = "You have left and you have to:"
                    let remainderMessage = reminder.remindTo
                    let reminderAlert = UIAlertController.init(title: reminderName, message: remainderMessage, preferredStyle: .actionSheet)
                    let okayButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    reminderAlert.addAction(okayButton)
                    self.present(reminderAlert, animated: true)
                reminder.isInNow = false
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return reminders.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath)
        cell.textLabel?.text = reminders[indexPath.row].remindTo
        cell.detailTextLabel?.text = reminders[indexPath.row].locationName
        return cell
       }
    
    // shows navigation bar
       override func viewWillAppear(_ animated: Bool) {
                 super.viewWillAppear(animated)
                 navigationController?.setNavigationBarHidden(false, animated: animated)
             }
}



