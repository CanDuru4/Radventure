//
//  ScoreboardViewController.swift
//  Radventure
//
//  Created by Can Duru on 22.06.2023.
//

import UIKit

struct ScoreboardStructure{
    let latitude, longitude: Double
    let name, question, answer: String
}

class ScoreboardViewController: UIViewController {

    //MARK: Table Setup
    lazy var ScoreboardTable: UITableView = {
        let tb = UITableView()
        tb.delegate = self
        tb.dataSource = self
        tb.register(ScoreboardTableViewCell.self, forCellReuseIdentifier: ScoreboardTableViewCell.identifer)
        return tb
    }()

    var scoreboardData:[ScoreboardStructure] = [] {
        didSet{
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppColor1")
    }
    
    

}

//MARK: TableView Extension
extension ScoreboardViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    //MARK: Row Number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    
    //MARK: Cell Content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScoreboardTableViewCell.identifer, for: indexPath) as! ScoreboardTableViewCell
        return cell
    }

    //MARK: Table Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
