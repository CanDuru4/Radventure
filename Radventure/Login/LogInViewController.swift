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
    var provider = OAuthProvider(providerID: "microsoft.com")
    let loadingVC = LoadingViewController()
    //let gameNameArray: [String] = []
    
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
        
        //MARK: Login Button Features
        loginButton.backgroundColor = UIColor(named: "AppColor2")
        loginButton.setTitle("Log in with Microsoft", for: .normal)
        loginButton.setTitleColor(UIColor(named: "AppColor1"), for: .normal)
        loginButton.layer.cornerRadius = 5
        loginButton.clipsToBounds = true
        loginButton.setImage(UIImage(named: "Microsoft")?.withRenderingMode(.alwaysOriginal).resized(to: CGSize(width: 30, height: 30)), for: .normal)
        view.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(logIn), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        //MARK: Varibles Constraints
        NSLayoutConstraint.activate([
            
            
            //MARK: Image Constraints
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -40),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            //MARK: Login Button Constraints
            loginButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 35),
        ])
        
        //MARK: Log In Button Image Attributions
        loginButton.moveImageLeftTextCenter()
    }

    
    
//MARK: Log In Function
    let kGraphURI = "https://graph.microsoft.com/v1.0/me/"
    @objc func logIn() {
        //MARK: Valid   ate All Fields Filled
        account_check = 0
        provider.customParameters = [
            "prompt": "consent",
            "tenant": "d4bc61be-6893-44c0-8f85-a6e62e5bebee"
        ]
        provider.scopes = ["user.read"]
        provider.getCredentialWith(nil) { credential, error in
          if error != nil {
              let alert = UIAlertController(title: "Unsuccessful Log In Attempt!", message: "Please try again. Use your Robert College organization account.", preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
              self.present(alert, animated: true, completion: nil)
          }
            if credential != nil {
                self.loadingVC.modalPresentationStyle = .overCurrentContext
                self.loadingVC.modalTransitionStyle = .crossDissolve
                self.present(self.loadingVC, animated: true, completion: nil)
                Auth.auth().signIn(with: credential!) { authResult, error in
                    if error != nil {
                        self.dismiss(animated: true)
                        let alert = UIAlertController(title: "Unsuccessful Log In Attempt!", message: "Please try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        guard let authResult = authResult else {
                            return
                        }
                    
                        
                        self.getUserData {
                            if self.isLoggedInOnAnotherDevice == true {
                                self.dismiss(animated: true)
                                do {
                                    try Auth.auth().signOut()
                                } catch let signOutError as NSError {
                                    print("Error signing out: %@", signOutError)
                                }
                                let alert = UIAlertController(title: "Logged in another device", message: "Please log out on another device. If you do not have access to your device, please get in contact with your administrator.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)

                            } else {
                                let removetext = "@robcol.k12.tr"
                                //var name = authResult.user.email
                                var name = authResult.user.displayName
                                if let range = name!.range(of: removetext) {
                                    name!.removeSubrange(range)
                                }
                                if self.account_check == 1 {
                                    self.dismiss(animated: true)
                                    self.navigateToTabBarViewController()
                                    self.updateUserDataLogIn() {}
                                } else if self.account_check == 0 {
                                    self.navigateToTabBarViewController()
                                    self.dismiss(animated: true)
                                    self.updateUserData(name: name ?? "User") {}
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
            "login": 1,
            //"gameName": self.gameNameArray
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

//MARK: Hide Keyboard Extension
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



//MARK: UIButton Image Extension
extension UIButton {
    func moveImageLeftTextCenter(imagePadding: CGFloat = 20.0){
        guard let imageViewWidth = self.imageView?.frame.width else{return}
        guard let titleLabelWidth = self.titleLabel?.intrinsicContentSize.width else{return}
        self.contentHorizontalAlignment = .left
        imageEdgeInsets = UIEdgeInsets(top: 0.0, left: imagePadding - imageViewWidth / 2, bottom: 0.0, right: 0.0)
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: (bounds.width - titleLabelWidth) / 2 - imageViewWidth, bottom: 0.0, right: 0.0)
    }
}
