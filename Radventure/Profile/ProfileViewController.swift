//
//  ProfileViewController.swift
//  Radventure
//
//  Created by Can Duru on 8.08.2023.
//

//MARK: Import
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import AudioToolbox

//MARK: Info Array
struct Info {
    var name: String
    var score: String
    var time_stamp: String
    var remainingTime: String
    var team: String
}



class ProfileViewController: UIViewController {

//MARK: Set Up
    

    
    //MARK: Variable Set Up
    let hiText = UILabel()
    var clearScoresButton = UIButton()
    var noScoreLabel = UILabel()
    var gameName = ""
    var score = ""
    var date = ""
    var time = ""
    var team = ""
    var gameArrayCount = 0
    var passwordKeyDatabase = ""
    var scoreClearPassword = ""
    var currentuseruid = Auth.auth().currentUser?.uid

    //MARK: Table Set Up
    lazy var table: UITableView = {
        let tb = UITableView()
        tb.delegate = self
        tb.dataSource = self
        tb.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifer)
        return tb
    }()
    var selectedCellIndexPath: IndexPath?

    //MARK: Profile Info Array Set Up
    var profileInfo: [Info] = [] {
        didSet{
            if profileInfo.count != 0 {
                clearScoresButton.isHidden = false
                noScoreLabel.isHidden = true
            } else {
                clearScoresButton.isHidden = true
                noScoreLabel.isHidden = false
            }
        }
    }
    
    
    
//MARK: Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: General Load
        view.backgroundColor = UIColor(named: "AppColor1")

        //MARK: Table Load
        table.backgroundColor = UIColor(named: "AppColor1")
        table.separatorColor = UIColor(named: "AppColor2")
        view.addSubview(table)
        
        //MARK: Set Layout
        self.setLayout()
        clearScoresButton.isHidden = true
        noScoreLabel.isHidden = false
        
        //MARK: Get User Data
        self.getUserData()
        self.getUserScoreData(){
            self.getUserScoreData2 {
                self.table.reloadData()
            }
        }
        
        //MARK: Start Timer
        self.timerTable()
    }
    
    
    
//MARK: Set Layout
    func setLayout(){
        
        
        //MARK: Hi Text Label
        hiText.font = hiText.font.withSize(30)
        hiText.textColor = .white
        hiText.textAlignment = .left
        hiText.clipsToBounds = true
        view.addSubview(hiText)
        
        hiText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hiText.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            hiText.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            ])
        
        //MARK: Tabel Name Label
        let tableLabel = UILabel()
        tableLabel.font = tableLabel.font.withSize(20)
        tableLabel.text = "Previous Scores"
        tableLabel.textColor = .white
        tableLabel.textAlignment = .left
        tableLabel.clipsToBounds = true
        view.addSubview(tableLabel)
        tableLabel.underline()
        
        tableLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableLabel.topAnchor.constraint(equalTo: hiText.bottomAnchor, constant: 30),
            tableLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            ])
        
        //MARK: No Score Label
        noScoreLabel.font = noScoreLabel.font.withSize(15)
        noScoreLabel.text = "No Previous Score Found! Get ready for the competition."
        noScoreLabel.textColor = .white
        noScoreLabel.numberOfLines = -1
        noScoreLabel.textAlignment = .left
        noScoreLabel.clipsToBounds = true
        view.addSubview(noScoreLabel)
        
        noScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noScoreLabel.topAnchor.constraint(equalTo: tableLabel.bottomAnchor, constant: 10),
            noScoreLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            noScoreLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
            ])
        
        //MARK: Clear Scores Button
        clearScoresButton.setTitle("Clear Scores", for: .normal)
        clearScoresButton.setTitleColor(UIColor(named: "AppColor2"), for: .normal)
        clearScoresButton.backgroundColor = UIColor.red
        clearScoresButton.addTarget(self, action: #selector(clearScoresButtonAction), for: .touchUpInside)
        clearScoresButton.layer.cornerRadius = 5
        clearScoresButton.clipsToBounds = true
        view.addSubview(clearScoresButton)
        
        clearScoresButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([clearScoresButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20), clearScoresButton.centerYAnchor.constraint(equalTo: tableLabel.centerYAnchor), clearScoresButton.widthAnchor.constraint(equalToConstant: 150)])
        
        //MARK: Tabel Constraints
        table.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([table.topAnchor.constraint(equalTo: tableLabel.bottomAnchor, constant: 10), table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor), table.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20), table.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)])
    }

    
    
//MARK: Clear Scores Button Action
    @objc func clearScoresButtonAction(){
        let alert = UIAlertController(title: "Enter the Password", message: "Communicate with your administrator to enter the password.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Password"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            self.scoreClearPassword = alert?.textFields![0].text ?? ""
            self.scoreClearFunction()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
//MARK: Clear Scores Button Function
    func scoreClearFunction(){
        contactDatabasePassword {
            if self.passwordKeyDatabase == self.scoreClearPassword{
                AudioServicesPlaySystemSound(SystemSoundID(1304))
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.profileInfo = []
                self.table.reloadData()
                let alert = UIAlertController(title: "Scores are deleted.", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.updateDataClear(){
                    self.updateCommonDataClear {
                        ScoreboardViewController().getUserData(gameNameCheckString: self.gameName) {
                        }
                    }
                }
            } else {
                let alert = UIAlertController(title: "Password is incorrect.", message: "Communicate with an administrator to enter the password.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    func updateDataClear(completion: @escaping () -> ()){
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).updateData(["score": 0, "time": "", "gameCount": 0, "gameName": FieldValue.delete()]) { (error) in
            if error != nil {
                let alert = UIAlertController(title: "An error occured. Try again.", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            completion()
        }
    }
    func updateCommonDataClear(completion: @escaping () -> ()){
        let ref = Database.database(url: "https://radventure-robert-default-rtdb.europe-west1.firebasedatabase.app/").reference().child("scores")
        ref.observeSingleEvent(of: .value) { snapshot in
            for case let child as DataSnapshot in snapshot.children {
                let info = child.value as! Dictionary<String, Any>
                for (_, value) in info {
                    let info2 = value as! Dictionary<String, Any>
                    for (key2, value2) in info2 {
                        if key2 == "uid" {
                            if value2 as! String == Auth.auth().currentUser!.uid {
                                ref.child(child.key).child(self.currentuseruid!).removeValue()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
//MARK: Get User Data
    func getUserData(){
        let db = Firestore.firestore()
        let user = (Auth.auth().currentUser?.uid)!
        db.collection("users").document(user).addSnapshotListener { documentSnapshot, error in
          guard let document = documentSnapshot else {
            print("Error fetching document: \(error!)")
            return
          }
          guard let data = document.data()?["name"] else {
            print("Document data was empty.")
            return
          }
            self.hiText.text = ("Hi, " + (data as? String ?? ""))
            self.hiText.attributedText = self.addSpecificColorText(fullString: self.hiText.text! as NSString, colorPartOfString: "Hi, ")
        }
    }

    
    
//MARK: Get User Score Data
    func getUserScoreData(completion: @escaping () -> ()){
        self.profileInfo = []
        let db = Firestore.firestore()
        let user = (Auth.auth().currentUser?.uid)!
        let docRef = db.collection("users").document(user)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.gameArrayCount = Int(document.data()?["gameCount"] as? String ?? "0")!
                completion()
            } else {
                print("Document does not exist")
            }
        }
    }
    func getUserScoreData2(completion: @escaping () -> ()){
        let db = Firestore.firestore()
        let user = (Auth.auth().currentUser?.uid)!
        let docRef = db.collection("users").document(user)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if document.data()?["gameName"] != nil {
                    let info = document.data()?["gameName"] as? Dictionary<String, Any> ?? nil
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
                            self.profileInfo.sort(by: { $0.time_stamp.compare($1.time_stamp) == .orderedDescending })
                        }
                    }
                }
                completion()
            } else {
                print("Document does not exist")
            }
        }
    }
  
    
    
//MARK: Timer Function
    var timer_table = Timer()
    func timerTable(){
        timer_table = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: { _ in
            self.profileInfo = []
            self.getUserScoreData {
                self.getUserScoreData2 {
                    self.table.reloadData()
                }
            }
        })
    }
    
    
    
//MARK: Communication with Database for Password w/ Completion
    func contactDatabasePassword(completion: @escaping () -> ()){
        let ref = Database.database(url: "https://radventure-robert-default-rtdb.europe-west1.firebasedatabase.app").reference()
        ref.observeSingleEvent(of: .value) { snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let dict = child.value as? [String:Any] else {
                    return
                }
                if child.key == "password" {
                    self.passwordKeyDatabase = dict["scorePassword"] as! String
                    completion()
                }
            }
        }
    }

    
    
//MARK: Color Text Beginning
    func addSpecificColorText(fullString: NSString, colorPartOfString: NSString) -> NSAttributedString {
        let nonColorFontAttribute = [NSAttributedString.Key.foregroundColor: UIColor(named: "AppColor2")]
        let colorFontAttribute = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let coloredString = NSMutableAttributedString(string: fullString as String, attributes:nonColorFontAttribute as [NSAttributedString.Key : Any])
        coloredString.addAttributes(colorFontAttribute, range: fullString.range(of: colorPartOfString as String))
        return coloredString
    }
}



//MARK: TableView Extension
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    
    //MARK: Row Number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileInfo.count
    }

    
    
    //MARK: Cell Content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifer, for: indexPath) as! TableViewCell
        cell.backgroundColor = UIColor(named: "AppColor1")
        cell.dataStructure = profileInfo[indexPath.row]
        let title_text = profileInfo[indexPath.row].name
        cell.titleLabel.font = cell.titleLabel.font.withSize(20)
        cell.titleLabel.textColor = UIColor(named: "AppColor2")
        let attributedString = NSMutableAttributedString(string: title_text)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: title_text.count))
        cell.titleLabel.attributedText = attributedString

        cell.detailLabel_score.text = "Score: \(String(profileInfo[indexPath.row].score))"
        cell.detailLabel_score.font = cell.titleLabel.font.withSize(15)
        cell.detailLabel_score.textColor = .white

        cell.detailLabel_team.text = "Team Members: \(profileInfo[indexPath.row].team)"
        cell.detailLabel_team.font = cell.titleLabel.font.withSize(15)
        cell.detailLabel_team.textColor = .white
        
        let splitStringArray = profileInfo[indexPath.row].remainingTime.split(separator: ":", maxSplits: 1).map(String.init)
        cell.detailLabel_remaining.text = "Remaining Time: \(splitStringArray[0]) minutes and \(splitStringArray[1]) seconds"
        cell.detailLabel_remaining.font = cell.titleLabel.font.withSize(15)
        cell.detailLabel_remaining.textColor = .white
        
        cell.detailLabel_time.text = "Date: \(profileInfo[indexPath.row].time_stamp)"
        cell.detailLabel_time.font = cell.titleLabel.font.withSize(15)
        cell.detailLabel_time.textColor = .white
        
        return cell
    }

    
    
    //MARK: Table Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    
    
    //MARK: Select Function
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
