//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by admin on 06/01/2019.
//  Copyright © 2019 Rima. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController,MKMapViewDelegate{

    //The location that has been succesfully added
    //Passed from the previous view controller
    var addedLocation: StudentInformation?
    
    
    @IBOutlet weak var addedLocationMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Add the passed location to the map, by extracting each value
        let lat = CLLocationDegrees(addedLocation!.latitude!)
        let long = CLLocationDegrees(addedLocation!.longitude!)
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        //create an annotation with the passed locaton info
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = addedLocation!.mapString
        
        //add annotation to the map
        addedLocationMapView.addAnnotation(annotation)
        
        // center the map view to the newly added annotation area
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
        //center the map to the area
        addedLocationMapView.setRegion(region, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //Set the  current view  controller to view Alerts in it
        UdacityClient.callinViewController = self

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
    
    
    @IBAction func finishButtonPressed(_ sender: Any) {
         let activityIndicator = UdacityClient.sharedInstance().createActivityIndicator()
        
        UdacityClient.sharedInstance().postStudenttLocation(self.addedLocation!) { (success,errorString) in
            
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                
                if success {
                    print("SUCCESS POST STUDENT LOCATION")
                    //successfully posted, dismiss this view controller
                    //show Map/Tableview tabbed screen
                  
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "NavigateTabView")
                    self.present(viewController!,animated: true,completion: nil)
                }
                else{
                    print("FAIL POST STUDENT LOCATION")
                    
                }
            }
            
            
    }
    }
    
    
    // MARK: - Navigation

 


}
