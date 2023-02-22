//
//  LevelsMenuCollectionViewCell.swift
//  Breakout
//
//  Created by Out East on 28.01.2023.
//

import UIKit

class LevelsMenuCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var levelNumber: UILabel!
    var levelIndex: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func setup(with data: LevelsMenuCellData) {
        self.backgroundColor = data.backgroundColor
        self.levelIndex = data.levelNumber
        self.levelNumber.text = "\(data.levelNumber)"
        
        self.layer.shadowColor = data.shadowColor.cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0
        self.layer.shadowOffset = CGSize(width: self.bounds.width/10,
                                         height: self.bounds.height/10)
        
        self.clipsToBounds = false
    }
}
