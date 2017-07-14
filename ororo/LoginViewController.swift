//
//  LoginViewController.swift
//  ororo
//
//  Created by Tcarevskii, Andrei on 7/14/17.
//  Copyright © 2017 Andrey Tsarevskiy. All rights reserved.
//

import Foundation
import UIKit

class LoginHandler: OroroAuthentificationProtocol {
    
    let viewController: LoginViewController
    let email: String
    let password: String
    
    init(email: String, password: String, viewController: LoginViewController) {
        self.viewController = viewController
        self.email = email
        self.password = password
    }
    
    func authSuccessful() {
        OroroAPI.setUpAuth(email: email, password: password)
        let targetStoryboardName = "Main"
        let targetStoryboard = UIStoryboard(name: targetStoryboardName, bundle: nil)
        if let targetViewController = targetStoryboard.instantiateInitialViewController() {
            viewController.present(targetViewController, animated: true)
        }
    }
    
    func authUnsuccessful() {
        let alert = UIAlertController(title: "Authentification", message: "Unsuccessful",
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func connectionError() {
        let alert = UIAlertController(title: "Authentification", message: "Connection error",
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginAction(_ sender: Any) {

        if let email = emailTextField?.text,
            let password = passwordTextField?.text {
            OroroAPI.testAuthentication(email: email, password: password,
                                        hadler: LoginHandler(email: email, password: password, viewController: self))
        }
    }

}
