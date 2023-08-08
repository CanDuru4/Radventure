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
        
        //MARK: Time Subtitle
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
            
            //MARK: Time onstraints
            detailLabel_time.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            detailLabel_time.topAnchor.constraint(equalTo: detailLabel_score.bottomAnchor, constant: 5),
        ])
    }
    
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

