//
//  MyMapViewController.swift
//  ExpenseTracker
//
//  Copyright © 2020 Conestoga IOS. All rights reserved.
//

import UIKit
import MapKit

// Controller for application map view
class AppMapViewController: UIViewController, MKMapViewDelegate {

    // reference to map object
    @IBOutlet weak var myMap: MKMapView!
    // reference to a segment control to change type of map
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    // set current location for controller
    var currentLocation : Location!
    // set value for selected annotaion when user clicks on map
    var selectedAnnotation : MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set delegate for the map
        myMap.delegate = self;
        // add the segment control as a subview of map
        myMap.addSubview(mySegmentedControl)
        
        // if current location has value, annotation will be set to map for user locating where current location is
        if !currentLocation.title.isEmpty {
            let initLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(currentLocation.latitude), longitude: CLLocationDegrees(currentLocation.longitude))

            let annotation = MKPointAnnotation()
            annotation.coordinate = initLocation
            annotation.title = NSLocalizedString(currentLocation.title, comment: "")
    
            myMap.addAnnotation(annotation)
        }
    }
    
    // Handle tapgesturerecogniez on the map
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        // remove the current
        myMap.removeAnnotations(myMap.annotations)
        
        // set new location based on user's selection
        let selectedLocation = sender.location(in: myMap)
        let coordinate = myMap.convert(selectedLocation, toCoordinateFrom: myMap)
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        // fetch city and country based on location - it's an extension at the end of this file
        location.fetchCityAndCountry { [self] city, country, error in
            guard let city = city, let country = country, error == nil else { return }
            // when the result is available, set it to the map
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = NSLocalizedString(city, comment: "")
            annotation.subtitle = NSLocalizedString(country, comment: "")
            
            self.selectedAnnotation = annotation
            self.myMap.addAnnotation(annotation)
        }
    }
    
    // Change the view's type of the map
    @IBAction func mapViewChanged(_ sender: UISegmentedControl) {
        switch (mySegmentedControl.selectedSegmentIndex) {
            case 0:
                myMap.mapType = .standard
            case 1:
                myMap.mapType = .hybrid
            case 2:
                myMap.mapType = .satellite
            default:
                break;
        }
        
    }
    // Done button handler, set value to current location and back to detail view
    @IBAction func doneSelection(_ sender: Any) {
        if let selected = selectedAnnotation {
            currentLocation.title =  NSLocalizedString(selected.title!, comment: "") 
            currentLocation.latitude = selected.coordinate.latitude
            currentLocation.longitude = selected.coordinate.longitude

        }
        navigationController?.popViewController(animated: true)
    }
    
    
}

// Extension to fetch city and country
extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
}


