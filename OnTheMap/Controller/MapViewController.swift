//
//  FirstViewController.swift
//  OnTheMap
//
//  Created by admin on 29/12/2018.
//  Copyright © 2018 Rima. All rights reserved.
//

import UIKit
import  MapKit

class MapViewController: TopBarViewController, MKMapViewDelegate {

    override var locationsData: LocationsData? {
        didSet {
            getLocations()
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Set the  current view  controller to view Alerts in it
        UdacityClient.callinViewController = self
        //getLocations()

    }
    
    //MARK: Get the locations array from Parse Udacity API
    func getLocations(){
    
       let activityIndicator = UdacityClient.sharedInstance().createActivityIndicator()
        
        UdacityClient.sharedInstance().getStudentLocations(){
            (success,locations,errorString) in
            
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                
                if success {
                    print("SUCCESS GET STUDENT LOCATIONS")
                    //Process the list of locations
                    self.processLocations()
                }
                else{
                    print("FAIL GET STUDENT LOCATIONS")
                    
                }
            }
        }
    }
    
    //MARK: Process the locations array into Map objects, then show them in the Map
    private func processLocations(){
        
        guard let locations = locationsData?.studentLocations else { return }

         // Store all Annotations in the array then add it to the map view.
        var annotations = [MKPointAnnotation]()
        
        //Access each object, get the values of each object
        for object in locations {
            
            //Default values, in case the object doesn't have them the app wont crash
            var lat = 0.0
            var long = 0.0
            var first = ""
            var last = ""
            var mediaURL = ""
            
            //Check if values exists, otherwise leave the value as the Default value
            if (object.latitude != nil){
                lat = CLLocationDegrees(object.latitude!)
            }
            
            if (object.longitude != nil) {
                long = CLLocationDegrees(object.longitude!)
            }
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            if(object.firstName != nil ){
                first = object.firstName ?? "Jane"
            }
            
            if(object.lastName != nil){
                last = object.lastName ?? "Doe"
            }
                
            if(object.mediaURL != nil){
                mediaURL = object.mediaURL ?? ""
            }
            
            // Create the annotation and set its properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Add each annotation to the annotations array
            annotations.append(annotation)
        }
        
        // Finally add all annotations to the map
        self.mapView.addAnnotations(annotations)

    }
    // MARK: - MKMapViewDelegate
    
    //Configuring the Annotation View
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) //the right button that has "i" icon
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    

    //MARK: Tells the delegate that the user tapped one of the annotation view’s accessory buttons
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView { //the right button that has "i" icon
            if let pinURL = view.annotation?.subtitle! {
                UIApplication.shared.open(URL(string: pinURL)!)
            }
        }
    }
}

