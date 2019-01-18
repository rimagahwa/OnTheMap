//
//  SecondViewController.swift
//  OnTheMap
//
//  Created by admin on 29/12/2018.
//  Copyright © 2018 Rima. All rights reserved.
//

import UIKit

class ListViewController: TopBarViewController,UITableViewDelegate, UITableViewDataSource {

    override var locationsData: LocationsData? {
        didSet {
        getLocations()

        }
    }
    var locations: [StudentInformation] = [] {
        didSet {
            
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    let cellIdentified = "tabelCell"

    var pinList : [StudentInformation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Set delegate and datasource
        tableView?.delegate = self
        tableView?.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Set the  current view  controller to view Alerts in it
        UdacityClient.callinViewController = self

    }
    
    private func getLocations(){
        
        
           let activityIndicator = UdacityClient.sharedInstance().createActivityIndicator()
        
        UdacityClient.sharedInstance().getStudentLocations(){
            (success,locations,errorString) in

            DispatchQueue.main.async {
                activityIndicator.stopAnimating()

                if success {
                    print("SUCCESS GET STUDENT LOCATIONS")
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

        var locationsConverted = [StudentInformation]()
        
        var index = 0
        
        //Access each object, get the values of each object
        for object in locations {
            
            //Default values, in case the object doesn't have them the app wont crash
            var first = "Jane"
            var last = "Doe"
            var mediaURL = ""
            var updated = ""
            
            //Check if values exists, otherwise leave the value as the Default value

            if( object.firstName != nil ){
                first = object.firstName ?? "Jane"
            }
            
            if(object.lastName != nil){
                last = object.lastName ?? "Doe"
            }
            
            if(object.mediaURL != nil){
                mediaURL = object.mediaURL!
            }
            
            if(object.updatedAt != nil){
                updated = object.updatedAt!
            }
            
            // Create the pin and set its properties
            var pinInfo = StudentInformation()
            pinInfo.firstName = first
            pinInfo.lastName = last
            pinInfo.mediaURL = mediaURL
            pinInfo.updatedAt = updated
            
            // Add each pin to the locations array, starting with the last index
            locationsConverted.insert(pinInfo, at: index)
            //move the index by one, for the next object
            index = index + 1

        }
 
        pinList=locationsConverted
        
        //Table must be reloaded otherwise it will not be updated with the latest data
        self.tableView?.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pinList.count //Use class property

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentified) as! AnnotationsTableViewCell
        
        let pinInfo = self.pinList[(indexPath as NSIndexPath).row]
        
        cell.pinStudentName.text = pinInfo.firstName! + " " + pinInfo.lastName!
        cell.pinMedia.text = pinInfo.mediaURL
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pinInfo = self.pinList[(indexPath as NSIndexPath).row]
        //Check if the pin has a MediaURL property
        if let pinURL = pinInfo.mediaURL {
            UIApplication.shared.open(URL(string: pinURL)!)
        }
    }

}

