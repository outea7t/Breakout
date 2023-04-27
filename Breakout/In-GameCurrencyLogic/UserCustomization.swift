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
    /// количество существующих в игре скинов для частичек 2D
    public static var _2DmaxParticleSkinIndex: Int = 12
    /// количество существующих в игре скинов для мячей 2D
    public static var _2DmaxBallSkinIndex: Int = 12
    /// количество существующих в игре скинов для ракеток 2D
    public static var _2DmaxPaddleSkinIndex: Int = 12
    
    /// текущий, выбранный игроком скин для частички 2D
    public static var _2DparticleSkinIndex: Int = 0
    /// текущий, выбранный игроком скин для мяча 2D
    public static var _2DballSkinIndex: Int = 0
    /// текущий, выбранный игроком скин для ракетки 2D
    public static var _2DpaddleSkinIndex: Int = 0
    
    /// все купленные игроком скины для частичек 2D
    public static var _2DbuyedParticlesSkinIndexes = [Int]()
    /// все купленные игроком скины для мячей 2D
    public static var _2DbuyedBallSkinIndexes = [Int]()
    /// все купленные игроком скины для ракеток 2D
    public static var _2DbuyedPaddleSkinIndexes = [Int]()
    
    /// количество существующих в игре скинов для частичек 3D
    public static var _3DmaxParticleSkinIndex: Int = 0
    /// количество существующих в игре скинов для мячей 3D
    public static var _3DmaxBallSkinIndex: Int = 0
    /// количество существующих в игре скинов для ракеток 3D
    public static var _3DmaxPaddleSkinIndex: Int = 0
    
    /// текущий, выбранный игроком скин для частички 3D
    public static var _3DparticleSkinIndex: Int = 0
    /// текущий, выбранный игроком скин для мяча 3D
    public static var _3DballSkinIndex: Int = 0
    /// текущий, выбранный игроком скин для ракетки 3D
    public static var _3DpaddleSkinIndex: Int = 0
    
    /// все купленные игроком скины для частичек 3D
    public static var _3DbuyedParticlesSkinIndexes = [Int]()
    /// все купленные игроком скины для мячей 3D
    public static var _3DbuyedBallSkinIndexes = [Int]()
    /// все купленные игроком скины для ракеток 3D
    public static var _3DbuyedPaddleSkinIndexes = [Int]()
    
    /// закрытый инициализатор, чтобы нельзя было создать ссылку на данный класс
    private init() {
        
    }
}
