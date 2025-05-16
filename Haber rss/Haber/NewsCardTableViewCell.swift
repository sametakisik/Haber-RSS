//
//  NewsCardTableViewCell.swift
//  Haber
//
//  Created by Trakya18 on 15.05.2025.
//

import UIKit

class NewsCardTableViewCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Kart görünümü için kenar yuvarlama ve gölge
        backgroundColor = .clear
           contentView.backgroundColor = .clear
           cardView.backgroundColor = .red
        
        cardView.layer.cornerRadius = 10
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.layer.masksToBounds = false
        cardView.backgroundColor = .white
    }
}

