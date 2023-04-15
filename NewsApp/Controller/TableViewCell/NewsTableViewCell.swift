//
//  NewsTableViewCell.swift
//  NewsApp
//
//  Created by Ravi Dwivedi on 27/02/23.
//

import UIKit
import SDWebImage


class NewsTableViewCell: UITableViewCell {
    
    static let identifier = "NewsTableViewCell"
    private var collectionView:UICollectionView?
    var newsCatgoryModels = [NewsFeedTabModels]()
    
    private let newsTitleLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22,weight:.semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private let subTitleLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17 ,weight:.light)
        label.numberOfLines = 0
        return label
    }()
    
    private let newsFeedImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 6
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.label.cgColor
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(newsTitleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(newsFeedImageView)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        newsTitleLabel.frame = CGRect(x: 10, y: 0, width: contentView.frame.size.width-5, height: 70)
        subTitleLabel.frame = CGRect(x: 10, y:70 , width: contentView.frame.size.width-170, height: contentView.frame.size.height/2)
        newsFeedImageView.frame = CGRect(x: contentView.frame.size.width-160, y:70 , width:150, height: contentView.frame.size.height-80)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        newsTitleLabel.text = nil
        subTitleLabel.text = nil
        newsFeedImageView.image = nil
    }
    
    func configure(with viewModel:Articles,index:Int){
        newsTitleLabel.text = viewModel.title
        subTitleLabel.text = viewModel.description
        if let url = URL(string:viewModel.urlToImage ?? "https://google.com")  {
            self.newsFeedImageView.sd_setImage(with: url, completed: nil)
        }
    }
}

