//
//  ARLevelsMenuCollectionViewCell.swift
//  Breakout
//
//  Created by Out East on 29.01.2023.
//

import UIKit

class ARLevelsMenuCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var levelNumber: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    
    var levelIndex = 0
    func setup(with data: LevelsMenuCellData, cellFrameWidth: CGFloat) {
        self.backgroundColor = data.backgroundColor
        self.levelIndex = data.levelNumber
        self.levelNumber.text = "\(data.levelNumber)"
        
        self.layer.shadowColor = data.shadowColor.cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0
        self.layer.shadowOffset = CGSize(width: self.bounds.width/10,
                                         height: self.bounds.height/10)
        
        self.layer.borderColor = data.backgroundColor.cgColor
        self.layer.borderWidth = cellFrameWidth/12.5
        
        self.layer.cornerRadius = cellFrameWidth/6.5
        if data.isAvailable {
            self.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.07058823529, blue: 0.3058823529, alpha: 1)
        } else {
            self.backgroundColor = #colorLiteral(red: 0.07450980392, green: 0.05098039216, blue: 0.2196078431, alpha: 1)
        }
        
        
        self.clipsToBounds = false
        guard let _3StarImage = UIImage(named: "3Star.png"),
              let _2StarImage = UIImage(named: "2Star.png"),
              let _1StarImage = UIImage(named: "1Star.png"),
              let _0StarImage = UIImage(named: "0Star.png") else {
            return
        }
        
        guard data.isAvailable else {
            return
        }
        self.starImageView.contentMode = .scaleAspectFit
        if data.starsCount == 0 {
            self.starImageView.image = _0StarImage
        } else if data.starsCount == 1 {
            self.starImageView.image = _1StarImage
        } else if data.starsCount == 2 {
            self.starImageView.image = _2StarImage
        } else if data.starsCount == 3 {
            self.starImageView.image = _3StarImage
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.starImageView.image = UIImage()
    }
}
