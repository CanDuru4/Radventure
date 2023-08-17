//
//  ScoreboardViewController.swift
//  Radventure
//
//  Created by Can Duru on 22.06.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseDatabase

struct ScoreboardStructure{
    let score: Int
    let name, time: String
}

class ScoreboardViewController: UIViewController {

//MARK: Set Up
    
    
    
    //MARK: Variable Setup
    var useruid = Auth.auth().currentUser?.uid
    var db = Firestore.firestore()
    var noScoreLabel = UILabel()
    var scoreboardLabel = UILabel()

    //MARK: Table Setup
    lazy var ScoreboardTable: UITableView = {
        let tb = UITableView()
        tb.delegate = self
        tb.dataSource = self
        tb.register(ScoreboardTableViewCell.self, forCellReuseIdentifier: ScoreboardTableViewCell.identifer)
        return tb
    }()
    
    //MARK: Array Setup
    var scoreboardData:[ScoreboardStructure] = []
    var sortedscoreboardData:[ScoreboardStructure] = []
    
    
    
//MARK: Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: General Load
        view.backgroundColor = UIColor(named: "AppColor1")
        ScoreboardTable.backgroundColor = UIColor(named: "AppColor1")
        ScoreboardTable.separatorColor = UIColor(named: "AppColor2")
        
        //MARK: Table Load
        view.addSubview(ScoreboardTable)
        
        //MARK: Set Layout
        setLayout()
        
        //MARK: Table Data Repeat
        self.noScoreLabel.isHidden = true
        getUserData {
            if self.gameNameVar != "" {
                self.scoreboardLabel.text = "Scoreboard of \(self.gameNameVar)"
                self.scoreboardLabel.font = self.scoreboardLabel.font.withSize(25)
            } else {
                self.scoreboardLabel.text = "Scoreboard"
                self.scoreboardLabel.font = self.scoreboardLabel.font.withSize(40)
            }
            self.sortedscoreboardData = self.scoreboardData
            self.sortedscoreboardData = self.sortedscoreboardData.sorted { $0.score > $1.score }
            let count1 = self.sortedscoreboardData.count - 1
            if count1 < 0 {
                self.noScoreLabel.isHidden = false
            } else {
                self.noScoreLabel.isHidden = true
                for i in 0...count1 {
                    if i+1 > count1 {
                        
                    } else {
                        if self.sortedscoreboardData[i].score == self.sortedscoreboardData[i+1].score {
                            if self.sortedscoreboardData[i+1].time != "" && self.sortedscoreboardData[i].time != "" {
                                let separator = ":"
                                let array_i_1 = self.sortedscoreboardData[i+1].time.components(separatedBy: separator)
                                let time_i_1 = ((Int(array_i_1[0])! * 60) + Int(array_i_1[1])!)
                                
                                let array_i = self.sortedscoreboardData[i].time.components(separatedBy: separator)
                                let time_i = ((Int(array_i[0])! * 60) + Int(array_i[1])!)

                                if time_i > time_i_1 {
                                    self.sortedscoreboardData.swapAt(i, i+1)
                                }
                            }
                        }
                    }
                }
            }
            self.ScoreboardTable.reloadData()
        }
        
        //MARK: Table Data Repeat
        getUserDataRepeat()
    }
    
    
    
//MARK: Set Layout
    func setLayout(){
        scoreboardLabel.textColor = UIColor(named: "AppColor2")
        scoreboardLabel.text = "Scoreboard"
        scoreboardLabel.font = scoreboardLabel.font.withSize(40)
        scoreboardLabel.textAlignment = .left
        scoreboardLabel.numberOfLines = -1
        scoreboardLabel.clipsToBounds = true
        view.addSubview(scoreboardLabel)
        scoreboardLabel.underline()
        
        scoreboardLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([scoreboardLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -20), scoreboardLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20), scoreboardLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)])
        
        let scoreboardexplainationLabel = UILabel()
        scoreboardexplainationLabel.textColor = UIColor(named: "AppColor2")
        scoreboardexplainationLabel.text = "Scoreboard updates in every 10 seconds, and it reflects only on the newest activity."
        scoreboardexplainationLabel.numberOfLines = -1
        scoreboardexplainationLabel.textAlignment = .left
        scoreboardexplainationLabel.clipsToBounds = true
        view.addSubview(scoreboardexplainationLabel)
        
        scoreboardexplainationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([scoreboardexplainationLabel.topAnchor.constraint(equalTo: scoreboardLabel.bottomAnchor, constant: 5), scoreboardexplainationLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20), scoreboardexplainationLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)])
        
        //MARK: No Score Label
        noScoreLabel.font = noScoreLabel.font.withSize(20)
        noScoreLabel.text = "Scoreboard will load when you start to your first activity. Get ready for the competition!"
        noScoreLabel.textColor = .white
        noScoreLabel.numberOfLines = -1
        noScoreLabel.textAlignment = .left
        noScoreLabel.clipsToBounds = true
        view.addSubview(noScoreLabel)
        
        noScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noScoreLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            noScoreLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            noScoreLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
            ])
        
        ScoreboardTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ScoreboardTable.topAnchor.constraint(equalTo: scoreboardexplainationLabel.bottomAnchor, constant: 10), ScoreboardTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor), ScoreboardTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor), ScoreboardTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)])
    }
    
    
    
//MARK: Table Data
    var name = ""
    var score = 0
    var time = ""
    var gameNameVar = ""
    var check = 0
    func getUserData(completion: @escaping () -> ()) {
        check = 0
        getUserInfo {
            let ref = Database.database(url: "https://radventure-robert-default-rtdb.europe-west1.firebasedatabase.app").reference().child("scores")
            ref.observeSingleEvent(of: .value) { snapshot in
                for case let child as DataSnapshot in snapshot.children {
                    guard let dict = child.value as? [String:Any] else {
                        completion()
                        return
                    }

                    let gameNameCheck = snapshot.value as! Dictionary<String, Any>
                    for (gameName, _) in gameNameCheck {
                        if gameName == self.gameNameVar {
                            let info = dict
                            for (_, value) in info {
                                let info2 = value as! Dictionary<String, Any>
                                for (key2, value2) in info2 {
                                    if key2 == "username" {
                                        self.name = value2 as? String ?? ""
                                    } else if key2 == "score" {
                                        self.score = value2 as? Int ?? 0
                                    } else if key2 == "time" {
                                        self.time = value2 as? String ?? ""

                                    }
                                }
                                self.scoreboardData.append(ScoreboardStructure(score: self.score, name: self.name, time: self.time))
                            }
                        }
                    }
                    self.check = 1
                    completion()
                }
                
                if self.check != 1 {
                    completion()
                }
            }
        }
    }
    
    //MARK: Table Data Repeat
    var timer = Timer()
    func getUserDataRepeat(){
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
            self.scoreboardData = []
            self.sortedscoreboardData = []
            self.getUserData {
                if self.gameNameVar != "" {
                    self.scoreboardLabel.text = "Scoreboard of \(self.gameNameVar)"
                    self.scoreboardLabel.font = self.scoreboardLabel.font.withSize(25)
                } else {
                    self.scoreboardLabel.text = "Scoreboard"
                    self.scoreboardLabel.font = self.scoreboardLabel.font.withSize(40)
                }
                self.sortedscoreboardData = self.scoreboardData
                self.sortedscoreboardData = self.sortedscoreboardData.sorted { $0.score > $1.score }
                let count2 = self.sortedscoreboardData.count - 1
                if count2 < 0 {
                    self.noScoreLabel.isHidden = false
                } else {
                    self.noScoreLabel.isHidden = true
                    for i in 0...count2 {
                        if i+1 > count2 {
                            
                        } else {
                            if self.sortedscoreboardData[i].score == self.sortedscoreboardData[i+1].score {
                                if self.sortedscoreboardData[i+1].time != "" && self.sortedscoreboardData[i].time != "" {
                                    let separator = ":"
                                    let array_i_1 = self.sortedscoreboardData[i+1].time.components(separatedBy: separator)
                                    let time_i_1 = ((Int(array_i_1[0])! * 60) + Int(array_i_1[1])!)
                                    
                                    let array_i = self.sortedscoreboardData[i].time.components(separatedBy: separator)
                                    let time_i = ((Int(array_i[0])! * 60) + Int(array_i[1])!)

                                    if time_i > time_i_1 {
                                        self.sortedscoreboardData.swapAt(i, i+1)
                                    }
                                }
                            }
                        }
                    }
                }
                self.ScoreboardTable.reloadData()
            }
        })
    }
    
    
    
//MARK: Get User Info
    func getUserInfo(completion: @escaping () -> ()) {
        db.collection("users").getDocuments { querySnapshot, err in
            if err != nil{

            } else {
                let docRef = self.db.collection("users").document(self.useruid!)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        self.gameNameVar = document.get("gameNameString") as? String ?? ""
                        completion()
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }
}



//MARK: TableView Extension
extension ScoreboardViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    //MARK: Row Number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreboardData.count
    }

    
    //MARK: Cell Content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScoreboardTableViewCell.identifer, for: indexPath) as! ScoreboardTableViewCell
        if sortedscoreboardData.count != 0 {
            cell.dataStructure = sortedscoreboardData[indexPath.row]
            
            cell.backgroundColor = UIColor(named: "AppColor1")
            let title_text = "\((indexPath.row) + 1). \((sortedscoreboardData[indexPath.row].name).firstUppercased)"
            cell.titleLabel.font = cell.titleLabel.font.withSize(20)
            cell.titleLabel.textColor = UIColor(named: "AppColor2")
            let attributedString = NSMutableAttributedString(string: title_text)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: title_text.count))
            cell.titleLabel.attributedText = attributedString
            
            cell.detailLabel_score.text = "Score: \(String(sortedscoreboardData[indexPath.row].score))"
            cell.detailLabel_score.font = cell.titleLabel.font.withSize(15)
            cell.detailLabel_score.textColor = UIColor(named: "AppColor2")
            
            if (sortedscoreboardData[indexPath.row].time) == "" {
                cell.detailLabel_time.text = "Not submitted any question yet."
            } else {
                cell.detailLabel_time.text = "Remaining Time: \(sortedscoreboardData[indexPath.row].time)"
            }
            cell.detailLabel_time.textAlignment = .right
            cell.detailLabel_time.font = cell.titleLabel.font.withSize(15)
            cell.detailLabel_time.textColor = UIColor(named: "AppColor2")
            return cell
        } else {
            return cell
        }
    }

    //MARK: Table Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension UILabel {
    func underline() {
        guard let tittleText = self.text else { return }
        let attributedString = NSMutableAttributedString(string: (tittleText))
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: (tittleText.count)))
        self.attributedText = attributedString
    }
}

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}
