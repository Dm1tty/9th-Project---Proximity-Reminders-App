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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Do any additional setup after loading the view.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
                    
                    
                    let reminderToAdd = Reminder(remindTo: description, longitude: longitude, latitude: latitude, locationName: locationName, whenEnter: whenEnter)
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
    // TODO: FOLLOW THE LOGIC TO MAKE ALERTS

    func checkLocation(currentLocation: CLLocationCoordinate2D, reminderLocationToCheck compareTo: CLLocation){

        let location = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        let distanceThreshold = 20.0 // meters
        
        if location.distance(from: CLLocation.init(latitude: compareTo.coordinate.latitude,
                                                   longitude: compareTo.coordinate.longitude)) < distanceThreshold
        {
            // do a
            print("You are inside")
        } else {
            print("You are outside")
            // do b
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        for reminder in reminders{
            print("Checking:\(reminder.remindTo)")
            let location : CLLocation = CLLocation(latitude: reminder.latitude, longitude: reminder.longitude)
        checkLocation(currentLocation: locValue, reminderLocationToCheck: location)
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
}

