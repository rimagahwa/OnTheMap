//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by admin on 06/01/2019.
//  Copyright © 2019 Rima. All rights reserved.
//

import UIKit
import CoreLocation

class InformationPostingViewController: UIViewController {

    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Set the  current view  controller to view Alerts in it
        UdacityClient.callinViewController = self
        
    }
    
    //Mark: Perform location search based
    @IBAction func findLocationPressed(_ sender: Any) {
        //Check if the fields are empty, if yes show an Alert
        guard let location = locationTextField.text,let link = linkTextField.text,
            location != "", link != "" else {
                
                //empty error, just to use the function
                let e = NSError(domain:"", code:0, userInfo:nil)

                UdacityClient.sharedInstance().showAlertToUser(e,"Empty Fields", "Sorry,please make sure to fill all fields","ok")
                
                return
        }
        
        //Creat a StudentInformation object
        let studentInformation = StudentInformation(mapString: location, mediaURL: link)
        proccessGeocode(studentInformation)
    }
    
    
    
    @IBAction func cancelUIBarButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
    }
    
    private func proccessGeocode(_ studentInformation: StudentInformation) {
        
        //Allow for one  geocodeAddressString request, show the indicator to prevent user from sending multiple requests
        let activityIndicator = UdacityClient.sharedInstance().createActivityIndicator()

        // convert the entered information to a location coordinates
        CLGeocoder().geocodeAddressString(studentInformation.mapString!) { (locationResponse, err) in
   
            activityIndicator.stopAnimating()
            //get the first location from the response
            guard let firstLocation = locationResponse?.first?.location
                else {
                    guard let firstLocation = locationResponse?.first?.location else {
                        
                        //Infrom user that geocoding failed
                        if let err = err{
                            UdacityClient.sharedInstance().showAlertToUser(err,"Invalid Location", "please make sure to fill a valid location","Ok")
                        }
                        return
                    }
                   return
            }

            //add the lat, long data to the existing studentInformation object's values
            var location = studentInformation
            location.latitude = firstLocation.coordinate.latitude
            location.longitude = firstLocation.coordinate.longitude
            
            self.performSegue(withIdentifier: "addLocationSegue", sender: location)
        }
        
        
    }
    
    //MARK: Move to the next viewcontroller and pass the loca
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Use storyboard to create a segue with an ID
        if segue.identifier == "addLocationSegue",
            let viewController = segue.destination as? AddLocationViewController {
            
            //Use a receiving viewcontroller's property, to pass data to it
            viewController.addedLocation = (sender as! StudentInformation)
            

        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
