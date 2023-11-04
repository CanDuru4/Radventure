//
//  ScoreboardViewController.swift
//  Radventure
//
//  Created by Can Duru on 22.06.2023.
//

//MARK: Import
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseDatabase

//MARK: Scoreboard Structure
struct ScoreboardStructure{
    let score: Int
    let name, time, team: String
}

//MARK: Table Name Structure
struct ScoreBoardTableStructure{
    let name, time: String
}



class ScoreboardViewController: UIViewController {

//MARK: Set Up
    
    
    
    //MARK: Variable Set up
    var useruid = Auth.auth().currentUser?.uid
    var db = Firestore.firestore()
    var noScoreLabel = UILabel()
    var scoreboardLabel = UILabel()
    var scoreboard_one = UIButton()
    var scoreboard_two = UIButton()
    var scoreboard_third = UIButton()
    var scoreboard_four = UIButton()
    var chosen_table = ""
    var check1 = 0
    var check2 = 0
    var check3 = 0
    var check4 = 0
    var stop = 0

    //MARK: Table Set up
    lazy var ScoreboardTable: UITableView = {
        let tb = UITableView()
        tb.delegate = self
        tb.dataSource = self
        tb.register(ScoreboardTableViewCell.self, forCellReuseIdentifier: ScoreboardTableViewCell.identifer)
        return tb
    }()
    
    //MARK: Array Set up
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
        getGameName {
            if self.userStarted == 0 {
                self.getUserData(gameNameCheckString: self.gameNameVar) {
                    self.chosen_table = self.gameNameVar
                    self.check1 = 1
                    var gameArrayCount = self.gameArray.count
                    if self.gameArray.count == 0 {
                        self.chosen_table = ""
                        self.scoreboard_two.isHidden = true
                        self.scoreboard_third.isHidden = true
                        self.scoreboard_four.isHidden = true
                    }
                    if self.gameArray.count == 1 {
                        self.scoreboard_two.isHidden = true
                        self.scoreboard_third.isHidden = true
                        self.scoreboard_four.isHidden = true
                    }
                    if self.gameArray.count == 2 {
                        self.scoreboard_two.setTitle(self.gameArray[gameArrayCount-2].name, for: .normal)
                        self.scoreboard_two.isHidden = false
                        self.scoreboard_third.isHidden = true
                        self.scoreboard_four.isHidden = true
                    }
                    if self.gameArray.count == 3 {
                        self.scoreboard_two.setTitle(self.gameArray[gameArrayCount-2].name, for: .normal)
                        self.scoreboard_third.setTitle(self.gameArray[gameArrayCount-3].name, for: .normal)
                        self.scoreboard_two.isHidden = false
                        self.scoreboard_third.isHidden = false
                        self.scoreboard_four.isHidden = true
                    }
                    if self.gameArray.count == 4 {
                        self.scoreboard_two.setTitle(self.gameArray[gameArrayCount-2].name, for: .normal)
                        self.scoreboard_third.setTitle(self.gameArray[gameArrayCount-3].name, for: .normal)
                        self.scoreboard_four.setTitle(self.gameArray[gameArrayCount-4].name, for: .normal)
                        self.scoreboard_two.isHidden = false
                        self.scoreboard_third.isHidden = false
                        self.scoreboard_four.isHidden = false
                    }
                    
                    if self.chosen_table != "" {
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
            } else {
                self.chosen_table = self.gameNameVar
                var check1 = 1
                var check2 = 0
                var check3 = 0
                var check4 = 0
                self.scoreboard_two.isHidden = true
                self.scoreboard_third.isHidden = true
                self.scoreboard_four.isHidden = true
                self.scoreboard_one.backgroundColor = UIColor.red
                self.scoreboard_two.backgroundColor =  UIColor(named: "AppColor3")
                self.scoreboard_third.backgroundColor = UIColor(named: "AppColor3")
                self.scoreboard_four.backgroundColor = UIColor(named: "AppColor3")
                
                self.getUserData(gameNameCheckString: self.chosen_table) {
                    if self.gameNameVar != "" {
                        self.scoreboardLabel.text = "Scoreboard of \(self.chosen_table)"
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
            }
        }
        
        //MARK: Table Data Repeat
        getUserDataRepeat()
    }

    
    
//MARK: Table Data
    var name = ""
    var score = 0
    var time = ""
    var gameNameVar = ""
    var userStarted = 0
    var check = 0
    var team = ""
    var gameCount = 0
    var waitforfinish = 0
    var gameArray: [ScoreBoardTableStructure] = [] {
        didSet {
            if gameArray.count == 0 {
                waitforfinish = 1
            } else {
                waitforfinish = 0
            }
        }
    }
    func getUserData(gameNameCheckString: String,completion: @escaping () -> ()) {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        check = 0
        self.gameArray = []
        getUserInfo {
            self.gameArray.sort(by: { $0.time.compare($1.time) == .orderedDescending })
            let ref = Database.database(url: "https://radventure-robert-default-rtdb.europe-west1.firebasedatabase.app").reference().child("scores")
            ref.observeSingleEvent(of: .value) { snapshot in
                for case let child as DataSnapshot in snapshot.children {
                    guard let dict = child.value as? [String:Any] else {
                        completion()
                        return
                    }

                    let gameNameCheck = snapshot.value as! Dictionary<String, Any>
                    let countGameNameCheck = gameNameCheck.count
                    var countGame = 0
                    for (gameName, _) in gameNameCheck {
                        countGame = countGame + 1
                        if gameName == gameNameCheckString {
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
                                    } else if key2 == "teammembers" {
                                        self.team = value2 as? String ?? ""
                                    }
                                }
                                self.scoreboardData.append(ScoreboardStructure(score: self.score, name: self.name, time: self.time, team: self.team))
                            }
                        }
                        if countGameNameCheck == countGame {
                            self.check = 1
                            completion()
                        }
                    }
                }
                
                if self.check != 1 {
                    completion()
                }
            }
        }
    }
    
    
//MARK: Set Layout
    func setLayout(){
        //MARK: Scoreboard Name Label
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
        
        //MARK: Scoreboard Explanation Label
        let scoreboardexplainationLabel = UILabel()
        scoreboardexplainationLabel.textColor = UIColor(named: "AppColor2")
        scoreboardexplainationLabel.text = "Scoreboard updates in every 10 seconds, and it reflects only on the newest activity."
        scoreboardexplainationLabel.numberOfLines = -1
        scoreboardexplainationLabel.textAlignment = .left
        scoreboardexplainationLabel.clipsToBounds = true
        view.addSubview(scoreboardexplainationLabel)
        
        scoreboardexplainationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([scoreboardexplainationLabel.topAnchor.constraint(equalTo: scoreboardLabel.bottomAnchor, constant: 5), scoreboardexplainationLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20), scoreboardexplainationLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)])
        
        //MARK: One Score Button
        let width = (UIScreen.main.bounds.width - 55) / 4
        scoreboard_one.setTitle("Latest Game", for: .normal)
        scoreboard_one.titleLabel?.font = .systemFont(ofSize: 12.0, weight: .regular)
        scoreboard_one.setTitleColor(UIColor(named: "AppColor2"), for: .normal)
        scoreboard_one.backgroundColor = UIColor.red
        scoreboard_one.layer.cornerRadius = 10
        scoreboard_one.titleLabel?.adjustsFontSizeToFitWidth = true
        scoreboard_one.clipsToBounds = true
        scoreboard_one.addTarget(self, action: #selector(scoreboardOne), for: .touchUpInside)
        view.addSubview(scoreboard_one)
        
        scoreboard_one.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([scoreboard_one.topAnchor.constraint(equalTo: scoreboardexplainationLabel.bottomAnchor, constant: 5), scoreboard_one.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20), scoreboard_one.widthAnchor.constraint(equalToConstant: width)])
        
        //MARK: Two Score Button
        scoreboard_two.setTitle("2", for: .normal)
        scoreboard_two.titleLabel?.font = .systemFont(ofSize: 12.0, weight: .regular)
        scoreboard_two.setTitleColor(UIColor(named: "AppColor2"), for: .normal)
        scoreboard_two.backgroundColor = UIColor(named: "AppColor3")
        scoreboard_two.titleLabel?.adjustsFontSizeToFitWidth = true
        scoreboard_two.layer.cornerRadius = 10
        scoreboard_two.clipsToBounds = true
        scoreboard_two.addTarget(self, action: #selector(scoreboardTwo), for: .touchUpInside)
        view.addSubview(scoreboard_two)
        
        scoreboard_two.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([scoreboard_two.topAnchor.constraint(equalTo: scoreboardexplainationLabel.bottomAnchor, constant: 5), scoreboard_two.leadingAnchor.constraint(equalTo: scoreboard_one.trailingAnchor, constant: 5), scoreboard_two.widthAnchor.constraint(equalToConstant: width)])
        
        //MARK: Three Score Button
        scoreboard_third.setTitle("3", for: .normal)
        scoreboard_third.titleLabel?.font = .systemFont(ofSize: 12.0, weight: .regular)
        scoreboard_third.setTitleColor(UIColor(named: "AppColor2"), for: .normal)
        scoreboard_third.backgroundColor = UIColor(named: "AppColor3")
        scoreboard_third.titleLabel?.adjustsFontSizeToFitWidth = true
        scoreboard_third.layer.cornerRadius = 10
        scoreboard_third.clipsToBounds = true
        scoreboard_third.addTarget(self, action: #selector(scoreboardThree), for: .touchUpInside)
        view.addSubview(scoreboard_third)
        
        scoreboard_third.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([scoreboard_third.topAnchor.constraint(equalTo: scoreboardexplainationLabel.bottomAnchor, constant: 5), scoreboard_third.leadingAnchor.constraint(equalTo: scoreboard_two.trailingAnchor, constant: 5), scoreboard_third.widthAnchor.constraint(equalToConstant: width)])
        
        //MARK: Fourth Score Button
        scoreboard_four.setTitle("4", for: .normal)
        scoreboard_four.titleLabel?.font = .systemFont(ofSize: 12.0, weight: .regular)
        scoreboard_four.setTitleColor(UIColor(named: "AppColor2"), for: .normal)
        scoreboard_four.backgroundColor = UIColor(named: "AppColor3")
        scoreboard_four.titleLabel?.adjustsFontSizeToFitWidth = true
        scoreboard_four.layer.cornerRadius = 10
        scoreboard_four.clipsToBounds = true
        scoreboard_four.addTarget(self, action: #selector(scoreboardFour), for: .touchUpInside)
        view.addSubview(scoreboard_four)
        
        scoreboard_four.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([scoreboard_four.topAnchor.constraint(equalTo: scoreboardexplainationLabel.bottomAnchor, constant: 5), scoreboard_four.leadingAnchor.constraint(equalTo: scoreboard_third.trailingAnchor, constant: 5), scoreboard_four.widthAnchor.constraint(equalToConstant: width)])
        
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
        
        //MARK: Table Constraints
        ScoreboardTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ScoreboardTable.topAnchor.constraint(equalTo: scoreboard_one.bottomAnchor, constant: 10), ScoreboardTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor), ScoreboardTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor), ScoreboardTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)])
    }
    
    
    
//MARK: One Score Button Action
    @objc func scoreboardOne() {
        self.scoreboard_one.backgroundColor = UIColor.red
        self.scoreboard_two.backgroundColor = UIColor(named: "AppColor3")
        self.scoreboard_third.backgroundColor = UIColor(named: "AppColor3")
        self.scoreboard_four.backgroundColor = UIColor(named: "AppColor3")
        self.check2 = 0
        self.check3 = 0
        self.check4 = 0
        
        if check1 == 1 {
            
        } else {
            if stop == 1 {
                
            } else {
                stop = 1
                self.chosen_table = self.gameNameVar
                self.check1 = 1
                self.scoreboardData = []
                self.sortedscoreboardData = []
                let latest = gameArray.count
                self.getUserData(gameNameCheckString: self.gameNameVar) {
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
                    self.stop = 0
                    self.ScoreboardTable.reloadData()
                }
            }
        }
    }
    
    
    
//MARK: Two Score Button Action
    @objc func scoreboardTwo() {
        self.scoreboard_one.backgroundColor = UIColor(named: "AppColor3")
        self.scoreboard_two.backgroundColor =  UIColor.red
        self.scoreboard_third.backgroundColor = UIColor(named: "AppColor3")
        self.scoreboard_four.backgroundColor = UIColor(named: "AppColor3")
        self.check1 = 0
        self.check3 = 0
        self.check4 = 0
        
        if check2 == 1 {
            
        } else {
            if waitforfinish == 1 {
                
            } else {
                if stop == 1 {
                    
                } else {
                    stop = 1
                    self.scoreboardData = []
                    self.sortedscoreboardData = []
                    let latest = gameArray.count
                    self.check2 = 1
                    self.chosen_table = gameArray[latest-2].name
                    self.getUserData(gameNameCheckString: gameArray[latest-2].name) {
                        if self.gameNameVar != "" {
                            self.scoreboardLabel.text = "Scoreboard of \(self.gameArray[latest-2].name)"
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
                        self.stop = 0
                        self.ScoreboardTable.reloadData()
                    }
                }
            }
        }
    }
    
   
    
//MARK: Three Score Button Action
    @objc func scoreboardThree() {
        self.scoreboard_one.backgroundColor = UIColor(named: "AppColor3")
        self.scoreboard_two.backgroundColor = UIColor(named: "AppColor3")
        self.scoreboard_third.backgroundColor = UIColor.red
        self.scoreboard_four.backgroundColor = UIColor(named: "AppColor3")
        self.check1 = 0
        self.check2 = 0
        self.check4 = 0
        
        if check3 == 1 {
            
        } else {
            if waitforfinish == 1 {
                
            } else {
                if stop == 1 {
                    
                } else {
                    stop = 1
                    self.scoreboardData = []
                    self.sortedscoreboardData = []
                    let latest = gameArray.count
                    self.chosen_table = gameArray[latest-3].name
                    self.check3 = 1
                    self.getUserData(gameNameCheckString: gameArray[latest-3].name) {
                        if self.gameNameVar != "" {
                            self.scoreboardLabel.text = "Scoreboard of \(self.gameArray[latest-3].name)"
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
                        self.stop = 0
                        self.ScoreboardTable.reloadData()
                    }
                }
            }
        }
    }
    
    
    
//MARK: Four Score Button Action
    @objc func scoreboardFour() {
        self.scoreboard_one.backgroundColor = UIColor(named: "AppColor3")
        self.scoreboard_two.backgroundColor = UIColor(named: "AppColor3")
        self.scoreboard_third.backgroundColor = UIColor(named: "AppColor3")
        self.scoreboard_four.backgroundColor = UIColor.red
        self.check1 = 0
        self.check2 = 0
        self.check3 = 0
        
        if check4 == 1 {
            
        } else {
            if waitforfinish == 1 {
                
            } else {
                if stop == 1 {
                    
                } else {
                    stop = 1
                    self.scoreboardData = []
                    self.sortedscoreboardData = []
                    self.check4 = 1
                    let latest = gameArray.count
                    self.chosen_table = gameArray[latest-4].name
                    self.getUserData(gameNameCheckString: gameArray[latest-4].name) {
                        if self.gameNameVar != "" {
                            self.scoreboardLabel.text = "Scoreboard of \(self.gameArray[latest-4].name)"
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
                        self.stop = 0
                        self.ScoreboardTable.reloadData()
                    }
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
            
            if self.userStarted == 0 {
                self.getUserData(gameNameCheckString: self.chosen_table) {
                    var gameArrayCount = self.gameArray.count
                    if self.gameArray.count == 0 {
                        self.chosen_table = ""
                        self.scoreboard_two.isHidden = true
                        self.scoreboard_third.isHidden = true
                        self.scoreboard_four.isHidden = true
                    }
                    if self.gameArray.count == 1 {
                        self.scoreboard_two.isHidden = true
                        self.scoreboard_third.isHidden = true
                        self.scoreboard_four.isHidden = true
                    }
                    if self.gameArray.count == 2 {
                        self.scoreboard_two.setTitle(self.gameArray[gameArrayCount-2].name, for: .normal)
                        self.scoreboard_two.isHidden = false
                        self.scoreboard_third.isHidden = true
                        self.scoreboard_four.isHidden = true
                    }
                    if self.gameArray.count == 3 {
                        self.scoreboard_two.setTitle(self.gameArray[gameArrayCount-2].name, for: .normal)
                        self.scoreboard_third.setTitle(self.gameArray[gameArrayCount-3].name, for: .normal)
                        self.scoreboard_two.isHidden = false
                        self.scoreboard_third.isHidden = false
                        self.scoreboard_four.isHidden = true
                    }
                    if self.gameArray.count == 4 {
                        self.scoreboard_two.setTitle(self.gameArray[gameArrayCount-2].name, for: .normal)
                        self.scoreboard_third.setTitle(self.gameArray[gameArrayCount-3].name, for: .normal)
                        self.scoreboard_four.setTitle(self.gameArray[gameArrayCount-4].name, for: .normal)
                        self.scoreboard_two.isHidden = false
                        self.scoreboard_third.isHidden = false
                        self.scoreboard_four.isHidden = false
                    }
                    
                    if self.chosen_table != "" {
                        self.scoreboardLabel.text = "Scoreboard of \(self.chosen_table)"
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
            } else {
                self.chosen_table = self.gameNameVar
                var check1 = 1
                var check2 = 0
                var check3 = 0
                var check4 = 0
                self.scoreboard_two.isHidden = true
                self.scoreboard_third.isHidden = true
                self.scoreboard_four.isHidden = true
                self.scoreboard_one.backgroundColor = UIColor.red
                self.scoreboard_two.backgroundColor =  UIColor(named: "AppColor3")
                self.scoreboard_third.backgroundColor = UIColor(named: "AppColor3")
                self.scoreboard_four.backgroundColor = UIColor(named: "AppColor3")
                
                self.getUserData(gameNameCheckString: self.chosen_table) {
                    if self.gameNameVar != "" {
                        self.scoreboardLabel.text = "Scoreboard of \(self.chosen_table)"
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
            }
        })
    }
    
    
    
//MARK: Get User Info
    var nameArray = ""
    var dateArray = ""
    func getUserInfo(completion: @escaping () -> ()) {
        db.collection("users").getDocuments { querySnapshot, err in
            if err != nil{

            } else {
                let docRef = self.db.collection("users").document(self.useruid!)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        self.gameNameVar = document.get("gameNameString") as? String ?? ""
                        self.userStarted = document.get("start") as? Int ?? 0
                        self.gameCount = document.get("gameCount") as? Int ?? 0
                        if document.data()?["gameName"] != nil {
                            let info = document.data()?["gameName"] as? Dictionary<String, Any> ?? nil
                            if info != nil {
                                for (_, value) in info! {
                                    let info2 = value as! Dictionary<String, Any>
                                    for (key2, value2) in info2 {
                                        if key2 == "name" {
                                            self.nameArray = value2 as! String
                                        }
                                        if key2 == "date" {
                                            self.dateArray = value2 as! String
                                        }
                                    }
                                    self.gameArray.append(ScoreBoardTableStructure(name: self.nameArray, time: self.dateArray))
                                }
                                completion()
                            }
                        } else {
                            completion()
                        }
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }
    
  
    
//MARK: Get Game Name Function
    func getGameName(completion: @escaping () -> ()) {
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
            
            if sortedscoreboardData[indexPath.row].team == "" {
                
            } else {
                cell.detailLabel_team.text = "Team: \(String(sortedscoreboardData[indexPath.row].team).capitalized)"
                cell.detailLabel_team.font = cell.titleLabel.font.withSize(15)
                cell.detailLabel_team.textColor = UIColor(named: "AppColor2")
            }
            return cell
        } else {
            return cell
        }
    }

    //MARK: Table Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if sortedscoreboardData[indexPath.row].team == "" {
            return 75
        } else {
            return 100
        }
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
