//
//  ViewController.swift
//  Radventure
//
//  Created by Can Duru on 22.06.2023.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore
import FirebaseCore
import FirebaseDatabase
import AVFoundation
import AudioToolbox
import FirebaseAuth

struct PinLocationsStructure{
    let latitude, longitude: Double
    let name, question, answer: String
}

class HomeMapViewController: UIViewController {

//MARK: Set Up
    
    
    
    //MARK: Variable Setup
    var center_coordinate = CLLocationCoordinate2D(latitude: 41.066993155414536, longitude: 29.034859552149705)
    var place_name = ""
    var user_answer = ""
    var passwordKeyDatabase = ""
    var score = 0
    var alert_count = 1
    var timerLabel = UILabel()
    var startButton = UIButton(type: .custom)
    var startButtoncheck = 1
    var forceQuitButtonCheck = 0
    var forceQuitButton = UIButton(type: .custom)
    var forceQuitPassword = ""
    
    //MARK: Map Setup
    private let map: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    var pinlocationsdata:[PinLocationsStructure] = [] {
        didSet{
            //MARK: Annotate Pin Locations
            for PinAnnotation in self.map.annotations {
                self.map.removeAnnotation(PinAnnotation)
            }
            pinLocations()
            filteredpinlocationsdata = pinlocationsdata
            if pinlocationsdata.isEmpty{
                if alert_count != 0 {
                    self.alert_count = self.alert_count - 1
                } else {
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    AudioServicesPlaySystemSound(SystemSoundID(1304))
                    let alert = UIAlertController(title: "You finished the activity!", message: "Please return to the Maze.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    forceQuitButton.isHidden = true
                    startButton.isHidden = false
                    forceQuitButtonCheck = 0
                    startButtoncheck = 1
                    score = 0
                    timer_label.invalidate()
                    timer.invalidate()
                    timerLabel.text = "00:00"
                    for PinAnnotation in self.map.annotations {
                        self.map.removeAnnotation(PinAnnotation)
                    }
                }
            }
        }
    }
    
    var filteredpinlocationsdata:[PinLocationsStructure] = []
    
    
    
//MARK: Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: General Load
        view.backgroundColor = UIColor(named: "AppColor1")
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        //MARK: Map Load
        view.addSubview(map)
        setMapLayout()
        mapLocation()
        setButton()
        if (startButtoncheck == 0) {
            startButton.isHidden = true
            forceQuitButton.isHidden = false
        }
        forceQuitButton.isHidden = true
        map.delegate = self

        
        //MARK: Pin Location Data
        pinlocationsdata = []
        
        //MARK: Button Setup
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
   
    
    
//MARK: Map
    func mapLocation(){
        LocationManager.shared.getUserLocation { [weak self] location in DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
            strongSelf.map.setRegion(MKCoordinateRegion(center: self!.center_coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
                strongSelf.map.showsUserLocation = true
            }
        }
    }
    
    func setMapLayout(){
        map.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([map.topAnchor.constraint(equalTo: view.topAnchor), map.bottomAnchor.constraint(equalTo: view.bottomAnchor), map.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor), map.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)])
    }
    
    
    
    
//MARK: Buttons Setup
    func setButton(){
        
        
        //MARK: Current Location Button
        let currentlocationButton = UIButton(type: .custom)
        currentlocationButton.backgroundColor = UIColor(white: 1, alpha: 0.8)
        currentlocationButton.setImage(UIImage(systemName: "location.fill")?.resized(to: CGSize(width: 25, height: 25)).withTintColor(.systemBlue), for: .normal)
        currentlocationButton.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        view.addSubview(currentlocationButton)
        
        currentlocationButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([currentlocationButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10), currentlocationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30), currentlocationButton.widthAnchor.constraint(equalToConstant: 50), currentlocationButton.heightAnchor.constraint(equalToConstant: 50)])
        currentlocationButton.layer.cornerRadius = 25
        currentlocationButton.layer.masksToBounds = true
        
        //MARK: Zoom Out Button
        let zoomOutButton = UIButton(type: .custom)
        zoomOutButton.backgroundColor = UIColor(white: 1, alpha: 0.8)
        zoomOutButton.setImage(UIImage(systemName: "minus.square.fill")?.resized(to: CGSize(width: 25, height: 25)).withTintColor(.systemBlue), for: .normal)
        zoomOutButton.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        view.addSubview(zoomOutButton)
        
        zoomOutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([zoomOutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10), zoomOutButton.bottomAnchor.constraint(equalTo: currentlocationButton.topAnchor, constant: -20), zoomOutButton.widthAnchor.constraint(equalToConstant: 50), zoomOutButton.heightAnchor.constraint(equalToConstant: 50)])
        zoomOutButton.layer.cornerRadius = 10
        zoomOutButton.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner] // Top right corner, Top left corner respectively
        
        //MARK: Zoom In Button
        let zoomInButton = UIButton(type: .custom)
        zoomInButton.backgroundColor = UIColor(white: 1, alpha: 0.8)
        zoomInButton.setImage(UIImage(systemName: "plus.square.fill")?.resized(to: CGSize(width: 25, height: 25)).withTintColor(.systemBlue), for: .normal)
        zoomInButton.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        view.addSubview(zoomInButton)
        
        zoomInButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([zoomInButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10), zoomInButton.bottomAnchor.constraint(equalTo: zoomOutButton.topAnchor), zoomInButton.widthAnchor.constraint(equalToConstant: 50), zoomInButton.heightAnchor.constraint(equalToConstant: 50)])
        zoomInButton.layer.cornerRadius = 10
        zoomInButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] // Top right corner, Top left corner respectively
        
        //MARK: Rules Button
        let rulesButton = UIButton(type: .custom)
        rulesButton.setTitle("Rules", for: .normal)
        rulesButton.setTitleColor(UIColor(named: "AppColor2"), for: .normal)
        rulesButton.backgroundColor = UIColor(named: "AppColor1")
        rulesButton.layer.cornerRadius = 15
        rulesButton.clipsToBounds = true
        rulesButton.addTarget(self, action: #selector(rules), for: .touchUpInside)
        view.addSubview(rulesButton)
        
        rulesButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([rulesButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15), rulesButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10), rulesButton.widthAnchor.constraint(equalToConstant: 75), rulesButton.heightAnchor.constraint(equalToConstant: 30)])
        
        //MARK: Log Out Button
        let logOutButton = UIButton(type: .custom)
        logOutButton.setTitle("Log Out", for: .normal)
        logOutButton.setTitleColor(UIColor(named: "AppColor1"), for: .normal)
        logOutButton.addTarget(self, action: #selector(logOutAction), for: .touchUpInside)
        logOutButton.underline()
        view.addSubview(logOutButton)
        
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([logOutButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15), logOutButton.bottomAnchor.constraint(equalTo: rulesButton.topAnchor, constant: -2), logOutButton.widthAnchor.constraint(equalToConstant: 75), logOutButton.heightAnchor.constraint(equalToConstant: 20)])
        
        //MARK: Timer Label
        timerLabel.backgroundColor = UIColor(named: "AppColor1")
        timerLabel.textColor = UIColor(named: "AppColor2")
        timerLabel.text = "Time"
        timerLabel.layer.cornerRadius = 15
        timerLabel.textAlignment = .center
        timerLabel.clipsToBounds = true
        view.addSubview(timerLabel)
        
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([timerLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15), timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10), timerLabel.widthAnchor.constraint(equalToConstant: 100), timerLabel.heightAnchor.constraint(equalToConstant: 30)])
        
        //MARK: Start Button
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(UIColor(named: "AppColor2"), for: .normal)
        startButton.backgroundColor = UIColor(named: "AppColor1")
        startButton.titleLabel?.font = .systemFont(ofSize: 19.0, weight: .bold)
        startButton.layer.cornerRadius = 15
        startButton.clipsToBounds = true
        startButton.addTarget(self, action: #selector(startButtonAction), for: .touchUpInside)
        view.addSubview(startButton)
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([startButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor), startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40), startButton.widthAnchor.constraint(equalToConstant: 250), startButton.heightAnchor.constraint(equalToConstant: 45)])
        
        //MARK: Force Quit Button
        forceQuitButton.setTitle("Force Quit", for: .normal)
        forceQuitButton.setTitleColor(UIColor(named: "AppColor1"), for: .normal)
        forceQuitButton.addTarget(self, action: #selector(forceQuitButtonAction), for: .touchUpInside)
        view.addSubview(forceQuitButton)
        forceQuitButton.underline()
        
        forceQuitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([forceQuitButton.centerXAnchor.constraint(equalTo: timerLabel.centerXAnchor), forceQuitButton.bottomAnchor.constraint(equalTo: timerLabel.topAnchor, constant: -1), forceQuitButton.widthAnchor.constraint(equalToConstant: 100), forceQuitButton.heightAnchor.constraint(equalToConstant: 20)])
    }

    //MARK: Current Location Button Action
    @objc func pressed() {
        LocationManager.shared.getUserLocation { [weak self] location in DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                strongSelf.map.setRegion(MKCoordinateRegion(center: location.coordinate, span:MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
            }
        }
    }
    
    var zoom_count = 14
    //MARK: Zoom In Button Action
    @objc func zoomIn() {
        zoomMap(byFactor: 0.5)
        zoom_count = zoom_count-1
    }

    //MARK: Zoom Out Button Action
    @objc func zoomOut() {
        if zoom_count < 14 {
            zoomMap(byFactor: 2)
            zoom_count = zoom_count+1
        }
    }
    
    //MARK: Rules Button Action
    @objc func rules(){
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
//        self.navigationController?.pushViewController(RulesViewController(), animated: true)
        self.present(RulesViewController(), animated: true)
    }
    
    //MARK: Log Out Button Action
    @objc func logOutAction(){
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        self.tabBarController?.tabBar.isHidden = true
        let newViewControllers = NSMutableArray()
        newViewControllers.add(LogInViewController())
        self.navigationController?.setViewControllers(newViewControllers as! [UIViewController], animated: true)
    }
    
    //MARK: Start Button Action
    var startingHourInt = 0
    var startingMinuteInt = 0
    var finishHourIntStart = 0
    var finishMinuteIntStart = 0
    @objc func startButtonAction(){

        let hour = Calendar.current.component(.hour, from: Date())
        let min = Calendar.current.component(.minute, from: Date())
        
        contactDatabase() {
            if (self.startingHourInt > hour) {
                let alert = UIAlertController(title: "Please wait for starting time.", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if (self.startingHourInt == hour && self.startingMinuteInt > min){
                let alert = UIAlertController(title: "Please wait for starting time.", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if (self.finishHourIntStart < hour) {
                let alert = UIAlertController(title: "Please check for starting time.", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if (self.finishHourIntStart == hour && self.finishMinuteIntStart < min){
                let alert = UIAlertController(title: "Please check for starting time.", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.PinLocationData()
                self.timerLabelFunction()
                self.startButton.isHidden = true
                self.forceQuitButton.isHidden = false
                self.forceQuitButtonCheck = 1
                self.startButtoncheck = 0
            }
        }
    }
    

    
    //MARK: Force Quit Button Action
    @objc func forceQuitButtonAction(){
        let alert = UIAlertController(title: "Enter the Password", message: "Communicate with your administrator to enter the password.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Password"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            self.forceQuitPassword = alert?.textFields![0].text ?? ""
            self.forceQuitFunction()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Check Force Quit Password Function
    func forceQuitFunction(){
        contactDatabasePassword {
            if self.passwordKeyDatabase == self.forceQuitPassword{
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                let alert = UIAlertController(title: "Quitted from the activity.", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.forceQuitButton.isHidden = true
                self.startButton.isHidden = false
                self.forceQuitButtonCheck = 0
                self.startButtoncheck = 1
                self.score = 0
                self.timer.invalidate()
                self.timer_label.invalidate()
                self.timerLabel.text = "00:00"
                for PinAnnotation in self.map.annotations {
                    self.map.removeAnnotation(PinAnnotation)
                }
            } else {
                let alert = UIAlertController(title: "Password is incorrect.", message: "Communicate with an administrator to enter the password.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    
    //MARK: Zoom in and Out Function
    func zoomMap(byFactor delta: Double) {
        var region: MKCoordinateRegion = self.map.region
        var span: MKCoordinateSpan = map.region.span
        span.latitudeDelta *= delta
        span.longitudeDelta *= delta
        region.span = span
        map.setRegion(region, animated: true)
    }
    
    
    //MARK: Timer Label Function
    var timer_label = Timer()
    func timerLabelFunction(){
        var finishHourInt = 0
        var finishMinuteInt = 0
        _ = 60

        let ref = Database.database(url: "https://radventure-robert-default-rtdb.europe-west1.firebasedatabase.app").reference().child("time")
        ref.observeSingleEvent(of: .value) { snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let dict = child.value as? [String:Any] else {
                    return
                }
                finishHourInt = dict["finishHourInt"] as! Int
                finishMinuteInt = dict["finishMinuteInt"] as! Int
            }
        }
        timer_label = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            let hour = Calendar.current.component(.hour, from: Date())
            let min = Calendar.current.component(.minute, from: Date())
            let sec = Calendar.current.component(.second, from: Date())
            
            let date1 = DateComponents(calendar: .current, year: 1, month: 1, day: 1, hour: hour, minute: min, second: sec).date!
            let date2 = DateComponents(calendar: .current, year: 1, month: 1, day: 1, hour: finishHourInt, minute: finishMinuteInt).date!
            let minutes = date2.minutes(from: date1)
            let seconds = date2.seconds(from: date1)
            let seconds_text = seconds % 60
            
            if minutes == 0 && seconds_text == 0 {
                AudioServicesPlaySystemSound(SystemSoundID(1304))
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                let alert = UIAlertController(title: "Time finished!", message: "Please go back to the Maze.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.startButton.isHidden = false
                self.forceQuitButton.isHidden = true
                self.forceQuitButtonCheck = 0
                self.startButtoncheck = 1
                self.timer_label.invalidate()
                self.timer.invalidate()
                self.timerLabel.text = "00:00"
                for PinAnnotation in self.map.annotations {
                    self.map.removeAnnotation(PinAnnotation)
                }
            } else if (seconds_text < 10) {
                let timeString = String(minutes)
                let secondString = String(seconds_text)
                self.timerLabel.text = "\(timeString):0\(secondString)"
            } else if (minutes < 10) {
                let timeString = String(minutes)
                let secondString = String(seconds_text)
                self.timerLabel.text = "0\(timeString):\(secondString)"
            } else if (seconds_text < 10 && minutes < 10) {
                let timeString = String(minutes)
                let secondString = String(seconds_text)
                self.timerLabel.text = "0\(timeString):0\(secondString)"
            } else {
                let timeString = String(minutes)
                let secondString = String(seconds_text)
                self.timerLabel.text = "\(timeString):\(secondString)"
            }
        })
    }
    
    
    
    //MARK: Pin Location Annotation
    var PinAnnotations: CustomPointAnnotation!
    var PinAnnotationView:MKPinAnnotationView!
    
    //MARK: Check and mark pin locations in every 15 second
    @objc func pinLocations(){
        let locationCount = pinlocationsdata.count
        for i in (0..<locationCount){
            let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(pinlocationsdata[i].latitude), CLLocationDegrees(pinlocationsdata[i].longitude))
            let PinAnnotation = CustomPointAnnotation()
            PinAnnotation.coordinate = coordinate
            PinAnnotation.title = pinlocationsdata[i].name
            PinAnnotation.customidentifier = "pinAnnotation"
            map.addAnnotation(PinAnnotation)
        }
    }
    
    var timer = Timer()
    func PinLocationDataRepeat(){
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
            self.PinLocationData()
        })
    }
    
    
    
    //MARK: Location Data
    @objc func PinLocationData(){
        let ref = Database.database(url: "https://radventure-robert-default-rtdb.europe-west1.firebasedatabase.app").reference().child("coordinates")
        var name = ""
        var latitude = 0.000
        var longitude = 0.000
        var question = ""
        var answer = ""
        
        ref.observeSingleEvent(of: .value) { snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let dict = child.value as? [String:Any] else {
                    return
                }
                name = dict["name"] as! String
                latitude = dict["latitude"] as! Double
                longitude = dict["longitude"] as! Double
                question = dict["question"] as! String
                answer = dict["answer"] as! String
                
                self.pinlocationsdata.append(PinLocationsStructure(latitude: latitude, longitude: longitude, name: name, question: question, answer: answer))
            }
        }
    }
    
    //MARK: Display Question Function
    @objc func displayQuestion(){
        filteredpinlocationsdata = filteredpinlocationsdata.filter { ($0.name.lowercased().contains(place_name.lowercased())) }
        let name_chosen = filteredpinlocationsdata[0].name
        let question_chosen = filteredpinlocationsdata[0].question
        let alert = UIAlertController(title: "Question of the \(name_chosen)", message: question_chosen, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Please enter your answer"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            self.user_answer = alert?.textFields![0].text ?? ""
            self.answercheck()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    //MARK: Check Answer Function
    func answercheck(){
        let real_answer = filteredpinlocationsdata[0].answer
        if user_answer == real_answer {
            pinlocationsdata = pinlocationsdata.filter { $0.question.lowercased() != filteredpinlocationsdata[0].answer.lowercased() }
        } else {
            let alert = UIAlertController(title: "Answer is not correct.", message: "Please try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    
    //MARK: Communication with Database w/ Completion
    func contactDatabase(completion: @escaping () -> ()){
        let ref = Database.database(url: "https://radventure-robert-default-rtdb.europe-west1.firebasedatabase.app").reference().child("time")
        ref.observeSingleEvent(of: .value) { snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let dict = child.value as? [String:Any] else {
                    return
                }
                self.startingHourInt = dict["startingHourInt"] as! Int
                self.startingMinuteInt = dict["startingMinuteInt"] as! Int
                self.finishHourIntStart = dict["finishHourInt"] as! Int
                self.finishMinuteIntStart = dict["finishMinuteInt"] as! Int
                completion()
            }
        }
    }
    
    //MARK: Communication with Database for Password w/ Completion
    func contactDatabasePassword(completion: @escaping () -> ()){
        let ref = Database.database(url: "https://radventure-robert-default-rtdb.europe-west1.firebasedatabase.app").reference().child("password")
        ref.observeSingleEvent(of: .value) { snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let dict = child.value as? [String:Any] else {
                    return
                }
                self.passwordKeyDatabase = dict["password"] as! String
                completion()
            }
        }
    }
}



//MARK: Image Resize Extension
extension UIImage {
    public func resized(to target: CGSize) -> UIImage {
        let ratio = min(
            target.height / size.height, target.width / size.width
        )
        let new = CGSize(
            width: size.width * ratio, height: size.height * ratio
        )
        let renderer = UIGraphicsImageRenderer(size: new)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: new))
        }
    }
}



//MARK: Pin With Image Extension
extension HomeMapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?  {
        
        guard let annotation = annotation as? CustomPointAnnotation else {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "reuseIdentifier")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "reuseIdentifier")
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        //MARK: Pin Annotation
        if annotation.customidentifier == "pinAnnotation" {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: String(annotation.hash))
            let rightButton = UIButton(type: .contactAdd)
            rightButton.setImage(UIImage(systemName: "checkmark.seal.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal), for: .normal)
            rightButton.tag = annotation.hash
            pinView.image = UIImage(systemName: "pin.fill")!.withRenderingMode(.alwaysOriginal).withTintColor(.systemBlue, renderingMode: .alwaysOriginal).resized(to: CGSize(width: 25, height: 25))
            pinView.animatesDrop = false
            pinView.canShowCallout = true
            pinView.rightCalloutAccessoryView = rightButton
            rightButton.addTarget(self, action: #selector(displayQuestion), for: .touchUpInside)
            return pinView
        }
        return annotationView
    }
    
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//
//            var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//            var region = MKCoordinateRegion(center: self.coordinate, span: span)
//            mapView.setRegion(region, animated: true)
//
//    }
    
    //MARK: Select Annotation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)  {
        let annotation = view.annotation as? CustomPointAnnotation

        if annotation?.customidentifier == "pinAnnotation" {
            place_name = annotation?.title ?? ""
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        let annotation = view.annotation as? CustomPointAnnotation

        if annotation?.customidentifier == "pinAnnotation" {
            place_name = ""
        }
    }
}



//MARK: Date Extension
extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}

extension UIButton {
    func underline() {
        guard let title = self.titleLabel else { return }
        guard let tittleText = title.text else { return }
        let attributedString = NSMutableAttributedString(string: (tittleText))
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: (tittleText.count)))
        self.setAttributedTitle(attributedString, for: .normal)
    }
}
