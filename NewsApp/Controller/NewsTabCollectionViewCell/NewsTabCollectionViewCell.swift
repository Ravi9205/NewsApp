//
//  NewsTabCollectionViewCell.swift
//  NewsApp
//
//  Created by Ravi Dwivedi on 28/02/23.
//

import UIKit

class NewsTabCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewsTabCollectionViewCell"
   
    @IBOutlet weak var titleLabel:UILabel!
    
    public func configure(with model:NewsFeedTabModels){
        self.titleLabel.text = model.categoryName
    }
    
    
}
