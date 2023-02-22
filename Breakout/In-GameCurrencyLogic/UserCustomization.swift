//
//  UserCustomization.swift
//  Breakout
//
//  Created by Out East on 02.01.2023.
//

import Foundation
import UIKit
/// информация о выбранном пользователе скине и количестве купленных скинов
struct UserCustomization {
    public static var particleSkinIndex: Int = 0
    public static var ballSkinIndex: Int = 0
    public static var paddleSkinIndex: Int = 0
    
    public static var buyedBallSkinIndexes = [Int]()
    public static var buyedParticlesSkinIndexes = [Int]()
    public static var buyedPaddleSkinIndexes = [Int]()
    
    /// закрытый инициализатор, чтобы нельзя было создать ссылку на данный класс
    private init() {
        
    }
    
}
