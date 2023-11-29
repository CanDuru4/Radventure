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
    var gameName = ""
    var score = ""
    var time = ""
    var date = ""
    var team = ""
    var profileInfo: [Info] = []
    var completionCheck = 1
    
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
    var keys: NSDictionary?
    let kGraphURI = "https://graph.microsoft.com/v1.0/me/"
    @objc func logIn() {
        
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
               keys = NSDictionary(contentsOfFile: path)
           }
        let tenantID = keys?["tenantID"] as? String ?? ""
        
        //MARK: Valid   ate All Fields Filled
        account_check = 0
        print("HI" + tenantID)
        provider.customParameters = [
            "prompt": "consent",
            "tenant": tenantID
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
                                var email = authResult.user.email
                                if let range = name!.range(of: removetext) {
                                    name!.removeSubrange(range)
                                }
                                if self.account_check == 1 {
                                    self.dismiss(animated: true)
                                    self.navigateToTabBarViewController()
                                    self.updateUserDataLogIn() {}
                                } else if self.account_check == 0 {
                                    self.updateUserData(name: name ?? "User", email: email ?? "user@robcol.k12.tr") {}
                                    self.navigateToTabBarViewController()
                                    self.dismiss(animated: true)
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
                print(error)
            }
            completion()
        }
    }

    
    
//MARK: Creating User Data (previously not logged in)
    func updateUserData(name: String, email: String, completion: @escaping () -> ()) {
        completionCheck(name: name, email: email){
            if self.completionCheck == 1 {
                self.db.collection("users").document(Auth.auth().currentUser!.uid).setData([
                    "name": name,
                    "email": email,
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
            } else {
                completion()
            }
        }
    }

    func completionCheck(name: String, email: String,completion: @escaping () -> ()) {
        self.db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var count = 0
                var check = 1
                
                if querySnapshot!.documents.count == 0 {
                    completion()
                }
                
                for document in querySnapshot!.documents {
                    count = count + 1
                    let scoreCheck = document.data()["score"] as? Int ?? -1
                    let nameCheck = document.data()["name"] as? String ?? ""
                    let emailCheck = document.data()["email"] as? String ?? ""
                    let gameCount = document.data()["gameCount"] as? Int ?? 0
                    
                    var name_removed = name
                    if let paranthesisRange = name_removed.range(of: ") ") {
                        name_removed.removeSubrange(name_removed.startIndex..<(paranthesisRange.upperBound))
                    }
                    
                    if scoreCheck == -1 && email.lowercased() == emailCheck.lowercased() {
                        if document.data()["gameName"] != nil {
                            let info = document.data()["gameName"] as? Dictionary<String, Any> ?? nil
                            if info != nil {
                                for (_, value) in info! {
                                    let info2 = value as! Dictionary<String, Any>
                                    for (key2, value2) in info2 {
                                        if key2 == "name" {
                                            self.gameName = value2 as! String
                                        } else if key2 == "score" {
                                            self.score = value2 as! String
                                        } else if key2 == "date" {
                                            self.date = value2 as! String
                                        } else if key2 == "remainingTime" {
                                            self.time = value2 as! String
                                        } else if key2 == "teamMembers" {
                                            self.team = value2 as! String
                                        }
                                    }
                                    self.profileInfo.append(Info(name: self.gameName, score: self.score, time_stamp: self.date, remainingTime: self.time, team: self.team))
                                    self.db.collection("users").document(Auth.auth().currentUser!.uid).setData([
                                        "name": name,
                                        "email": email,
                                        "score": 0,
                                        "login": 1,
                                    ]) { err in
                                        if let err = err {
                                            print("Error writing document: \(err)")
                                        } else {
                                            self.db.collection("users").document(Auth.auth().currentUser!.uid).updateData([
                                                "gameCount": (gameCount+1),
                                                "gameName.\((gameCount+1)).name": self.gameName,
                                                "gameName.\((gameCount+1)).score": String(self.score),
                                                "gameName.\((gameCount+1)).teamMembers": self.team,
                                                "gameName.\((gameCount+1)).date": self.date,
                                                "gameName.\((gameCount+1)).remainingTime": self.time
                                            ])
                                            self.completionCheck = 0
                                            check = 0
                                            self.db.collection("users").document(document.documentID).delete()
                                            completion()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if count == querySnapshot!.documents.count && check == 1 {
                        self.completionCheck = 1
                        completion()
                    }
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
