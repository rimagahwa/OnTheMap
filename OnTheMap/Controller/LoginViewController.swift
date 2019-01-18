//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by admin on 29/12/2018.
//  Copyright © 2018 Rima. All rights reserved.
//

import UIKit

//Perform network logic in UdacityClient ,use LoginViewContorller for UI
class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpTextView: UITextView!
    @IBOutlet weak var loginButton: UIButton!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Set the  current view  controller to view Alerts in it
        UdacityClient.callinViewController = self
        
        setUpUIProperties()
    }
    
    
    @IBAction func loginPressed(_ sender: Any) {
        //Authenticate user for login
        //Successfull login, move user to mapview
        UdacityClient.sharedInstance().loginUser(self.emailTextField.text!,self.passwordTextField.text!) { (success, errorString) in
            DispatchQueue.main.async {
                if success{
                    print("SUCCESS LOGIN")
                    self.navigateToTabView()
                }else{
                    print("FAIL LOGIN")
                    
                }
            }
                        
        }


    }
    
    
    func navigateToTabView(){
        let viewController = storyboard?.instantiateViewController(withIdentifier: "NavigateTabView")
        
        present(viewController!,animated: true,completion: nil)
      
    }
    
    // MARK: Set UI properties before the view is displayed
    func setUpUIProperties() {
        hyperTextOpenInBrowser(textView: self.signUpTextView, linktext: "https://auth.udacity.com/sign-up")
        
        self.emailTextField.layer.borderColor = UIColor.lightGray.cgColor
        self.passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        self.loginButton.layer.cornerRadius = 5
        self.loginButton.layer.borderWidth = 0.1
        self.loginButton.layer.borderColor = UIColor.clear.cgColor

    }
    
    //MARK: Make sign up link clickable
    private func hyperTextOpenInBrowser(textView: UITextView, linktext: String){
        let attributedString = NSMutableAttributedString(string: "Don't have an account? Sign Up")
        let url = URL(string: linktext)!
        
        //change 'Sign Up' text to be the link
        attributedString.setAttributes([.link: url], range: NSRange(location: 23, length: 7))
        
        textView.attributedText = attributedString
        textView.isUserInteractionEnabled = true//can be set in the Interface builder also
        textView.isEditable = false //can be set in the Interface builder also
        
        //make link blue
        textView.linkTextAttributes = [.foregroundColor: UIColor.blue]
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
