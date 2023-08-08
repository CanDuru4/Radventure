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

    var useruid = Auth.auth().currentUser?.uid
    var db = Firestore.firestore()
    
    //MARK: Table Setup
    lazy var ScoreboardTable: UITableView = {
        let tb = UITableView()
        tb.delegate = self
        tb.dataSource = self
        tb.register(ScoreboardTableViewCell.self, forCellReuseIdentifier: ScoreboardTableViewCell.identifer)
        return tb
    }()

    var scoreboardData:[ScoreboardStructure] = []
    var sortedscoreboardData:[ScoreboardStructure] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppColor1")
        ScoreboardTable.backgroundColor = UIColor(named: "AppColor1")
        ScoreboardTable.separatorColor = UIColor(named: "AppColor2")
        view.addSubview(ScoreboardTable)
        setLayout()
        getUserData {
            self.sortedscoreboardData = self.scoreboardData
            self.sortedscoreboardData = self.sortedscoreboardData.sorted { $0.score > $1.score }
            let count1 = self.sortedscoreboardData.count - 1
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
            self.ScoreboardTable.reloadData()
        }
        getUserDataRepeat()
    }
    
    //MARK: Table
    func setLayout(){
        
        let scoreboardLabel = UILabel()
        scoreboardLabel.textColor = UIColor(named: "AppColor2")
        scoreboardLabel.text = "Scoreboard"
        scoreboardLabel.font = scoreboardLabel.font.withSize(40)
        scoreboardLabel.textAlignment = .left
        scoreboardLabel.clipsToBounds = true
        view.addSubview(scoreboardLabel)
        scoreboardLabel.underline()
        
        scoreboardLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([scoreboardLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -20), scoreboardLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)])
        
        let scoreboardexplainationLabel = UILabel()
        scoreboardexplainationLabel.textColor = UIColor(named: "AppColor2")
        scoreboardexplainationLabel.text = "Scoreboard updates in every 10 seconds, and it reflects only on the newest activity."
        scoreboardexplainationLabel.numberOfLines = -1
        scoreboardexplainationLabel.textAlignment = .left
        scoreboardexplainationLabel.clipsToBounds = true
        view.addSubview(scoreboardexplainationLabel)
        
        scoreboardexplainationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([scoreboardexplainationLabel.topAnchor.constraint(equalTo: scoreboardLabel.bottomAnchor, constant: 5), scoreboardexplainationLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20), scoreboardexplainationLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)])
        
        ScoreboardTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ScoreboardTable.topAnchor.constraint(equalTo: scoreboardexplainationLabel.bottomAnchor, constant: 10), ScoreboardTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor), ScoreboardTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor), ScoreboardTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)])
    }
    
    var name = ""
    var score = 0
    var time = ""
    func getUserData(completion: @escaping () -> ()) {
        db.collection("users").getDocuments { querySnapshot, err in
            if err != nil{
                
            } else {
                for document in querySnapshot!.documents {
                    self.name = document.get("name") as? String ?? ""
                    self.score = document.get("score") as? Int ?? 0
                    self.time = document.get("time") as? String ?? ""
                    self.scoreboardData.append(ScoreboardStructure(score: self.score, name: self.name, time: self.time))
                }
                completion()
            }
        }
    }
    
    var timer = Timer()
    func getUserDataRepeat(){
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
            self.scoreboardData = []
            self.sortedscoreboardData = []
            self.getUserData {
                self.sortedscoreboardData = self.scoreboardData
                self.sortedscoreboardData = self.sortedscoreboardData.sorted { $0.score > $1.score }
                let count2 = self.sortedscoreboardData.count - 1
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
                self.ScoreboardTable.reloadData()
            }
        })
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
