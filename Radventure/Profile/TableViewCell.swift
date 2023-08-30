//
//  TableViewCell.swift
//  Radventure
//
//  Created by Can Duru on 8.08.2023.
//

import UIKit


class TableViewCell: UITableViewCell {

//MARK: Set Up
    static let identifer = "TableViewCell"
    
    var dataStructure: Info!
    var titleLabel:UILabel!
    var detailLabel_score:UILabel!
    var detailLabel_time: UILabel!
    var detailLabel_remaining: UILabel!
    var detailLabel_team: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    

//MARK: Select Cell Function
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    
//MARK: Load
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: TableViewCell.identifer)
        configureViews()
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }
        
//MARK: Set Contents
    func configureViews(){
        
        //MARK: Name Title
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .systemGray
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        self.addSubview(titleLabel)
        
        
        //MARK: Score Subtitle
        detailLabel_score = UILabel()
        detailLabel_score.numberOfLines = -1
        detailLabel_score.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(detailLabel_score)
        
        //MARK: Team Member Subtitle
        detailLabel_team = UILabel()
        detailLabel_team.numberOfLines = -1
        detailLabel_team.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(detailLabel_team)
        
        //MARK: Remaning Time Subtitle
        detailLabel_remaining = UILabel()
        detailLabel_remaining.numberOfLines = -1
        detailLabel_remaining.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(detailLabel_remaining)
        
        //MARK: Date Subtitle
        detailLabel_time = UILabel()
        detailLabel_time.numberOfLines = -1
        detailLabel_time.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(detailLabel_time)

    //MARK: Constraints
        NSLayoutConstraint.activate([
        
        
            //MARK: Title Constraints
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            
            //MARK: Score Constraints
            detailLabel_score.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            detailLabel_score.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            detailLabel_score.widthAnchor.constraint(equalTo: self.widthAnchor),
            
            //MARK: Team Constraints
            detailLabel_team.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            detailLabel_team.topAnchor.constraint(equalTo: detailLabel_score.bottomAnchor, constant: 5),
            detailLabel_team.widthAnchor.constraint(equalTo: self.widthAnchor),
            
            //MARK: Remaning Time Subtitle
            detailLabel_remaining.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            detailLabel_remaining.topAnchor.constraint(equalTo: detailLabel_team.bottomAnchor, constant: 5),
            
            //MARK: Date Constraints
            detailLabel_time.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            detailLabel_time.topAnchor.constraint(equalTo: detailLabel_remaining.bottomAnchor, constant: 5),
        ])
    }
    
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

