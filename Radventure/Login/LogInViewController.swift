//
//  LogInViewController.swift
//  Radventure
//
//  Created by Can Duru on 17.07.2023.
//

//MARK: Import
import UIKit
import FirebaseAuth
import FirebaseFirestore

class LogInViewController: UIViewController {
    
    //MARK: Set Up
    
    
    
    //MARK: Set Variables
    var emailField = UITextField()
    var passwordField = UITextField()
    var loginButton = UIButton()
    var db = Firestore.firestore()
    var loggedin = 0
    var account_check = 0
    var isLoggedInOnAnotherDevice = false
    
    //MARK: Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppColor1")
        if Auth.auth().currentUser?.uid != nil {
            self.navigationController?.pushViewController(TabBarViewController(), animated: true)
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }else{
             //user is not logged in
        }
        self.setLabels()
        
        //MARK: Hide Keyboard
        self.hideKeyboardWhenTappedAround()
    }
    
    
    
    //MARK: Variable Features
    func setLabels(){
        
        
        //MARK: Image Features
        let imageLogo = UIImage(named: "AppLogo")
        let imageView = UIImageView(image: imageLogo)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        //MARK: Email Field Features
        emailField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        emailField.borderStyle = .roundedRect
        emailField.backgroundColor = UIColor.clear
        emailField.layer.borderColor = UIColor.white.cgColor
        emailField.layer.borderWidth = CGFloat(1)
        emailField.placeholder = "Email"
        emailField.textColor = .white
        emailField.borderStyle = .roundedRect
        emailField.autocorrectionType = .no
        emailField.autocapitalizationType = .none
        view.addSubview(emailField)
        emailField.translatesAutoresizingMaskIntoConstraints = false
        
        //MARK: Password Field Features
        passwordField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        passwordField.borderStyle = .roundedRect
        passwordField.backgroundColor = UIColor.clear
        passwordField.layer.borderColor = UIColor.white.cgColor
        passwordField.textColor = .white
        passwordField.layer.borderWidth = CGFloat(1)
        view.addSubview(passwordField)
        passwordField.isSecureTextEntry = true
        passwordField.autocorrectionType = .no
        passwordField.autocapitalizationType = .none
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        
        //MARK: Login Button Features
        loginButton.backgroundColor = UIColor(named: "AppColor2")
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(UIColor(named: "AppColor1"), for: .normal)
        loginButton.layer.cornerRadius = 5
        loginButton.clipsToBounds = true
        view.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(logIn), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        //MARK: Varibles Constraints
        NSLayoutConstraint.activate([
            
            
            //MARK: Image Constraints
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            imageView.bottomAnchor.constraint(equalTo: emailField.topAnchor, constant: 40),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5),
            
            //MARK: Email Field Constraints
            emailField.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emailField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emailField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            emailField.heightAnchor.constraint(equalToConstant: 35),
            
            //MARK: Password Field Constraints
            passwordField.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 10),
            passwordField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            passwordField.heightAnchor.constraint(equalToConstant: 35),
            
            
            //MARK: Login Button Constraints
            loginButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 10),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 35),
        ])
    }
     
    //MARK: Log In Function
    @objc func logIn() {
        //MARK: Validate All Fields Filled
        let error = validateFields()
        account_check = 0
        
        //MARK: Not Filled
        if error != nil {
            let alert = UIAlertController(title: "Please fill in all fields.", message: "", preferredStyle: .alert)
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
                    let alert = UIAlertController(title: "Credentials are not correct.", message: "Check your email and/or password.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    strongSelf.present(alert, animated: true, completion: nil)
                    
                //MARK: Correct User Credentials
                } else {
                    //MARK: Create User
                    let removetext = "@robcol.k12.tr"
                    var name = email
                    if let range = name!.range(of: removetext) {
                        name!.removeSubrange(range)
                    }
                    self?.getUserData {
                        if self?.isLoggedInOnAnotherDevice == true {
                            let alert = UIAlertController(title: "Logged in another device", message: "Please log out on another device. If you do not have access to your device, please get in contact with your administrator.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                            self?.present(alert, animated: true, completion: nil)
                            
                        } else {
                            if self?.account_check == 1 {
                                self?.navigateToTabBarViewController()
                                self?.updateUserDataLogIn() {
                                }
                            } else if self?.account_check == 0 {
                                self?.navigateToTabBarViewController()
                                self?.updateUserData(name: name!) {
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    //MARK: Navigation to TabBarViewController
    func navigateToTabBarViewController() {
        self.navigationController?.pushViewController(TabBarViewController(), animated: true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    //MARK: Getting User Login Data
    func getUserData(completion: @escaping () -> ()) {
        let docRef = self.db.collection("users").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data_document = document.data()?["login"] as? Int ?? 0
                self.loggedin = data_document
                self.isLoggedInOnAnotherDevice = data_document == 1
                self.account_check = 1
            } else {
                self.account_check = 0
            }
            completion()
        }
    }

    //MARK: Updating User Data (previously logged in)
    func updateUserDataLogIn(completion: @escaping () -> ()) {
        db.collection("users").document(Auth.auth().currentUser!.uid).updateData(["login": 1]) { (error) in
            if error != nil {
                // Handle the error if needed
            }
            completion()
        }
    }

    //MARK: Creating User Data (previously not logged in)
    func updateUserData(name: String, completion: @escaping () -> ()) {
        db.collection("users").document(Auth.auth().currentUser!.uid).setData([
            "name": name,
            "score": 0,
            "login": 1
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                completion()
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
