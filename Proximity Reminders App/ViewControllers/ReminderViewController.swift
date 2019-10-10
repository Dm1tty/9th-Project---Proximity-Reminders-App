//
//  ReminderViewController.swift
//  Proximity Reminders App
//
//  Created by Dzmitry Matsiulka on 10/2/19.
//  Copyright © 2019 Dzmitry M. All rights reserved.
//

import UIKit
import LocationPicker
import CoreData
import MapKit

class ReminderViewController: UIViewController {

    @IBOutlet weak var reminderTextField: UITextField!
    @IBOutlet weak var remindWhen: UISegmentedControl!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var addLocatioButton: UIButton!
    
    let locationPicker = LocationPickerViewController()
     let regionRadius: CLLocationDistance = 1000
    
    var reminderText = ""
    var chosenLocation: Location?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    

    @IBAction func addGeolocationButtonPressed(_ sender: Any) {
        getLocation()
        addLocatioButton.isEnabled = false
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        var remindWhenEnter = false
        reminderText = reminderTextField.text!
        print(reminderText)
        print(chosenLocation!.coordinate)
        
        if remindWhen.selectedSegmentIndex == 1{
            remindWhenEnter = true
        }
    
        let reminder = Reminder(remindTo: reminderText, longitude: chosenLocation!.coordinate.longitude, latitude: chosenLocation!.coordinate.latitude, locationName: chosenLocation?.name ?? "", whenEnter: remindWhenEnter)
        saveData(reminderToSave: reminder)
    }
    
    
   
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    func getLocation(){
        
        
        // button placed on right bottom corner
        locationPicker.showCurrentLocationButton = true // default: true
        
        // default: navigation bar's `barTintColor` or `.whiteColor()`
        locationPicker.currentLocationButtonBackground = UIColor.blue
        
        // ignored if initial location is given, shows that location instead
        locationPicker.showCurrentLocationInitially = true // default: true
        locationPicker.mapType = .standard // default: .Hybrid
        
        // for searching, see `MKLocalSearchRequest`'s `region` property
        locationPicker.useCurrentLocationAsHint = true // default: false
        
        locationPicker.searchBarPlaceholder = "Search places" // default: "Search or enter an address"
        
        locationPicker.searchHistoryLabel = "Previously searched" // default: "Search History"
        
        // optional region distance to be used for creation region when user selects place from search results
        locationPicker.resultRegionDistance = 500 // default: 600
        
        locationPicker.completion = { location in
            // do some awesome stuff with location
            self.locationLabel.text = "Latitude: \(location!.location.coordinate.latitude) Longitude: \(location!.location.coordinate.longitude)"
            self.chosenLocation = location!
            self.centerMapOnLocation(location: location!.location)
        
            // ANNOTATION FOR THE MAP 
            let myAnnotation: MKPointAnnotation = MKPointAnnotation()
            myAnnotation.coordinate = CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude);
            self.mapView.addAnnotation(myAnnotation)
           
        }
        
        navigationController?.pushViewController(locationPicker, animated: true)
    }
    
    func saveData(reminderToSave: Reminder){
        //reference to appDelegate container
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        //context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Reminders",
                                       in: managedContext)!
        
        let newMemory = NSManagedObject(entity: entity, insertInto: managedContext)
        
        
        newMemory.setValue(reminderToSave.remindTo, forKey: "reminderDescription")
        newMemory.setValue(reminderToSave.latitude, forKey: "reminderLatitude")
        newMemory.setValue(reminderToSave.longitude, forKey: "reminderLongitude")
        newMemory.setValue(reminderToSave.whenEnter, forKey: "whenEnter")
        newMemory.setValue(reminderToSave.locationName, forKey: "reminderLocationName")
        
        do {
            try managedContext.save()
            print("Saved")
            let saveCompletion = UIAlertController(title: "Saved", message: "Your reminder has been saved", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Main Menu", style: .default) { (action:UIAlertAction) in
                print("You've pressed default")
                
                self.navigationController?.popViewController(animated: true)
                
            }
            saveCompletion.addAction(action1)
            self.present(saveCompletion, animated: true, completion: nil)
            
        } catch {
            print("Failed saving")
        }
    }
}
