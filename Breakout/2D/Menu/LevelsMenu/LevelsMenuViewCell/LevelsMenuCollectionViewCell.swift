//
//  LevelsMenuCollectionViewCell.swift
//  Breakout
//
//  Created by Out East on 28.01.2023.
//

import UIKit

class LevelsMenuCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var levelNumber: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    
    /// идет не с 0, а с 1
    var levelIndex: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(with data: LevelsMenuCellData, cellFrameWidth: CGFloat) {
//        self.backgroundColor = data.backgroundColor
        self.levelIndex = data.levelNumber
        self.levelNumber.text = "\(data.levelNumber)"
        
        self.layer.shadowColor = data.shadowColor.cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0
        self.layer.shadowOffset = CGSize(width: self.bounds.width/10,
                                         height: self.bounds.height/10)
        
        self.layer.borderColor = data.backgroundColor.cgColor
        self.layer.borderWidth = cellFrameWidth/12.5
        self.backgroundColor = #colorLiteral(red: 0.1058823529, green: 0.007843137255, blue: 0.2039215686, alpha: 1)
        
        
        self.layer.cornerRadius = cellFrameWidth / 6.5
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.starImageView.image = UIImage()
    }
}
