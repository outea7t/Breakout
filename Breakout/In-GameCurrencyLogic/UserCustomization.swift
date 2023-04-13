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
    /// количество существующих в игре скинов для частичек
    public static var maxParticleSkinIndex: Int = 12
    /// количество существующих в игре скинов для мячей
    public static var maxBallSkinIndex: Int = 12
    /// количество существующих в игре скинов для ракеток
    public static var maxPaddleSkinIndex: Int = 12
    /// текущий, выбранный игроком скин для частички
    public static var particleSkinIndex: Int = 0
    /// текущий, выбранный игроком скин для мяча
    public static var ballSkinIndex: Int = 0
    /// текущий, выбранный игроком скин для ракетки
    public static var paddleSkinIndex: Int = 0
    /// все купленные игроком скины для частичек
    public static var buyedParticlesSkinIndexes = [Int]()
    /// все купленные игроком скины для мячей
    public static var buyedBallSkinIndexes = [Int]()
    /// все купленные игроком скины для ракеток
    public static var buyedPaddleSkinIndexes = [Int]()
    
    /// закрытый инициализатор, чтобы нельзя было создать ссылку на данный класс
    private init() {
        
    }
    
}
