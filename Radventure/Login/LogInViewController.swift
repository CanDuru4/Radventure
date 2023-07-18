//
//  LogInViewController.swift
//  Radventure
//
//  Created by Can Duru on 17.07.2023.
//

//MARK: Import
import UIKit
import FirebaseAuth

class LogInViewController: UIViewController {
    
    //MARK: Set Up
    
    
    
    //MARK: Set Variables
    var emailField = UITextField()
    var passwordField = UITextField()
    var loginButton = UIButton()
    
    
    
    //MARK: Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppColor2")
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
               self.navigationController?.pushViewController(TabBarViewController(), animated: true)
               self.navigationController?.setNavigationBarHidden(true, animated: true)
           } else {
           }
        }
        self.setLabels()
        
        //MARK: Hide Keyboard
        self.hideKeyboardWhenTappedAround()
    }
    
    
    
    //MARK: Variable Features
    func setLabels(){
        
        
        //MARK: Image Features
        let imageLogo = UIImage(named: "Logo")
        let imageView = UIImageView(image: imageLogo)
        imageView.clipsToBounds = true
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        //MARK: Email Field Features
        emailField.placeholder = "Email"
        emailField.borderStyle = .roundedRect
        emailField.layer.borderColor = CGColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1)
        emailField.layer.borderWidth = CGFloat(1)
        emailField.autocorrectionType = .no
        emailField.autocapitalizationType = .none
        view.addSubview(emailField)
        emailField.translatesAutoresizingMaskIntoConstraints = false
        
        //MARK: Password Field Features
        passwordField.placeholder = "Password"
        passwordField.borderStyle = .roundedRect
        passwordField.layer.borderColor = CGColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1)
        passwordField.layer.borderWidth = CGFloat(1)
        view.addSubview(passwordField)
        passwordField.isSecureTextEntry = true
        passwordField.autocorrectionType = .no
        passwordField.autocapitalizationType = .none
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        
        //MARK: Login Button Features
        loginButton.backgroundColor = UIColor(named: "AppColor1")
        loginButton.setTitle("Login", for: .normal)
        loginButton.tintColor = .white
        loginButton.layer.cornerRadius = 5
        loginButton.clipsToBounds = true
        view.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(logIn), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        //MARK: Varibles Constraints
        NSLayoutConstraint.activate([
            
            
            //MARK: Image Constraints
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: emailField.topAnchor, constant: 75),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 150),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -150),
            
            //MARK: Email Field Constraints
            emailField.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emailField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emailField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            emailField.heightAnchor.constraint(equalToConstant: 35),
            
            //MARK: Password Field Constraints
            passwordField.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 5),
            passwordField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            passwordField.heightAnchor.constraint(equalToConstant: 35),
            
            
            //MARK: Login Button Constraints
            loginButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 5),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 35),
        ])
    }
    
    
    
    //MARK: Log In Button Action
    @objc func logIn(){
        
        
        //MARK: Validate All Fields Filled
        let error = validateFields()
        
        
        //MARK: Not Filled
        if error != nil {
            let alert = UIAlertController(title: "Please fill the all fields.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            //MARK: Filled
        } else {
            let email = emailField.text?.lowercased()
            let password = passwordField.text
            Auth.auth().signIn(withEmail: email ?? "", password: password ?? "") { [weak self] authResult, error in
              guard let strongSelf = self else { return }
                //MARK: Wrong User Credentials
                if error != nil {
                    let alert = UIAlertController(title: "Credentials are not correct. Check your email and password.", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    strongSelf.present(alert, animated: true, completion: nil)

                //MARK: Correct User Credentials
                } else {
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    
    
    //MARK: Validate All Fields
    func validateFields() -> String? {
        if emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        return nil
    }
}

//MARK: Hide Keyboard
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
