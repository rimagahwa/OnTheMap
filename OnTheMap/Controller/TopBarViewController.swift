//
//  TopBarViewController.swift
//  OnTheMap
//
//  Created by admin on 04/01/2019.
//  Copyright © 2019 Rima. All rights reserved.
//

import UIKit

//Add this class to the other UIViewController class that want to have the same top bar
class TopBarViewController: UIViewController {

    var locationsData: LocationsData?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUIProperties()
        refreshStudentLocations()

    }
    
    func setUpUIProperties() {
        navigationItem.title = "On The Map"
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addLocation(_:)))
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshLocations(_:)))
        
        let logoutButton = UIBarButtonItem(title: "LOGOUT", style: .plain, target: self, action: #selector(self.logout(_:)))
        
        navigationItem.rightBarButtonItems = [addButton, refreshButton]
        navigationItem.leftBarButtonItem = logoutButton
    }
    
    @objc private func addLocation(_ sender: Any) {
        let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InformationPostingNavigationController") as! UINavigationController
        
        present(navController, animated: true, completion: nil)
        
    }
    
    @objc private func refreshLocations(_ sender: Any) {
       refreshStudentLocations()
    }
    
    //MARK: download student locations Array,
    //Reassign the value of the array with new data (in the getStudentLocations method)
    private func refreshStudentLocations() {
        
        let activityIndicator = UdacityClient.sharedInstance().createActivityIndicator()

        UdacityClient.sharedInstance().getStudentLocations(){
            (success,locations,errorString) in
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                if success {
                    print("Refresh SUCCESS GET STUDENT LOCATIONS")
                    self.locationsData = locations
                }
                else{
                    print("Refresh FAIL GET STUDENT LOCATIONS")
                    
                }
            }
        }
    }
    
    @objc private func logout(_ sender: Any) {
        UdacityClient.sharedInstance().logoutUser { (success, errorString) in
            DispatchQueue.main.async {
                if success{
                    print("SUCCESS LOGOUT")
                    //Just remove the current view (LoginView is already in the stack)
                    self.dismiss(animated: true, completion: nil)
                }else{
                    print("FAIL LOGOUT")
                    
                }
            }
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
