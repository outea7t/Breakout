//
//  ShopCellData.swift
//  Breakout
//
//  Created by Out East on 15.01.2023.
//

import Foundation
import UIKit

enum TextureType {
    case ball
    case paddle
    case particles
}
enum TextureEffect2D {
    case doubleDamage
    case decreasedVelocity
}

struct Shop2DCellData {
    var image: UIImage
    var price: Int
    var color: UIColor
    var id: Int
    var type: TextureType
}
