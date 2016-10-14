//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Mahmoud Tawfik on 10/10/16.
//
//

import UIKit

class LoginViewController: UIViewController {

    //MARK: Variables
    let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    //MARK: IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK: IBActions
    
    @IBAction func login() {
        
        // Make sure the user enterd a valid email
        guard let email = emailTextField.text, email.isValidEmail else {
            showAlert(parameters: ["message":Constants.Alert.InvalidEmailAlert])
            return
        }
        
        // Make sure the user enterd a password
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(parameters: ["message":Constants.Alert.InvalidPasswordAlert])
            return
        }
        
        setUIEnabled(enabled: false)
        loadingIndicator.startAnimating()

        Udacity.login(email: email, password: password) { success, error in
            if error == nil {
                self.performSegue(withIdentifier: "Login successful", sender: self)
            } else {
                let message = (error as! NSError).code == 1 ? Constants.Alert.NoNetwork : Constants.Alert.IncorrectEmailPassword
                self.showAlert(parameters: ["message":message])
            }
            self.setUIEnabled(enabled: true)
            self.loadingIndicator.stopAnimating()
        }
        
    }
    
    @IBAction func signup() {
        if let url = URL(string: "https://www.udacity.com/account/auth#!/signup"){
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    //MARK: View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
    }
    
    //MARK: Show Alert method
    func showAlert(parameters: [String: String]) {
        let alert = UIAlertController(title: parameters["title"],
                                      message: parameters["message"],
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: parameters["action"] ?? "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: LoginViewController extension - Configure UI
extension LoginViewController{
    func setUIEnabled(enabled: Bool) {
        loginButton.isEnabled = enabled
        loginButton.alpha = enabled ? 1.0 : 0.5
    }
}

// MARK: LoginViewController extension - TextField / Keyboard

extension LoginViewController: UITextFieldDelegate{

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordTextField.resignFirstResponder()
            login()
        default:
            break
        }
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
