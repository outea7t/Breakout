//
//  ShopCellData.swift
//  Breakout
//
//  Created by Out East on 15.01.2023.
//

import Foundation
import UIKit

enum TextureType2D {
    case ball
    case paddle
    case particles
}
enum TextureEffect2D {
    case doubleDamage
    case decreasedVelocity
}
struct ShopCellData {
    var image: UIImage
    var price: Int
    var color: UIColor
    var id: Int
    var type: TextureType2D
}
