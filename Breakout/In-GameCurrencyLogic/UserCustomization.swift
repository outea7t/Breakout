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
    /// перечисление, для того, чтобы каждый раз не прописывать строку с именем переменной в UserDefaults
    private enum UserCustomizationKeys: String {
        // 2D
        case _2DmaxParticleSkinIndex
        case _2DmaxBallSkinIndex
        case _2DmaxPaddleSkinIndex
        
        case _2DparticleSkinIndex
        case _2DballSkinIndex
        case _2DpaddleSkinIndex
        
        case _2DbuyedParticlesSkinIndexes
        case _2DbuyedBallSkinIndexes
        case _2DbuyedPaddleSkinIndexes
        // 3D
        case _3DmaxParticleSkinIndex
        case _3DmaxBallSkinIndex
        case _3DmaxPaddleSkinIndex
        
        case _3DparticleSkinIndex
        case _3DballSkinIndex
        case _3DpaddleSkinIndex
        
        case _3DbuyedParticlesSkinIndexes
        case _3DbuyedBallSkinIndexes
        case _3DbuyedPaddleSkinIndexes
           
    }
    /// количество существующих в игре скинов для частичек 2D
    public static var _2DmaxParticleSkinIndex: Int = 12
    /// количество существующих в игре скинов для мячей 2D
    public static var _2DmaxBallSkinIndex: Int = 12
    /// количество существующих в игре скинов для ракеток 2D
    public static var _2DmaxPaddleSkinIndex: Int = 12
    
    /// текущий, выбранный игроком скин для частички 2D
    public static var _2DparticleSkinIndex: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserCustomizationKeys._2DparticleSkinIndex.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserCustomizationKeys._2DparticleSkinIndex.rawValue)
        }
    }
    /// текущий, выбранный игроком скин для мяча 2D
    public static var _2DballSkinIndex: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserCustomizationKeys._2DballSkinIndex.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserCustomizationKeys._2DballSkinIndex.rawValue)
        }
    }
    /// текущий, выбранный игроком скин для ракетки 2D
    public static var _2DpaddleSkinIndex: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserCustomizationKeys._2DpaddleSkinIndex.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserCustomizationKeys._2DpaddleSkinIndex.rawValue)
        }
    }
    
    /// все купленные игроком скины для частичек 2D
    public static var _2DbuyedParticlesSkinIndexes: [Int] {
        get {
            guard let array = UserDefaults.standard.array(forKey: UserCustomizationKeys._2DbuyedParticlesSkinIndexes.rawValue) as? [Int] else {
                return []
            }
            return array
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserCustomizationKeys._2DbuyedParticlesSkinIndexes.rawValue)
        }
    }
    /// все купленные игроком скины для мячей 2D
    public static var _2DbuyedBallSkinIndexes: [Int] {
        get {
            guard let array = UserDefaults.standard.array(forKey: UserCustomizationKeys._2DbuyedBallSkinIndexes.rawValue) as? [Int] else {
                return []
            }
            return array
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserCustomizationKeys._2DbuyedBallSkinIndexes.rawValue)
        }
    }
    /// все купленные игроком скины для ракеток 2D
    public static var _2DbuyedPaddleSkinIndexes: [Int] {
        get {
            guard let array = UserDefaults.standard.array(forKey: UserCustomizationKeys._2DbuyedPaddleSkinIndexes.rawValue) as? [Int] else {
                return []
            }
            return array
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserCustomizationKeys._2DbuyedPaddleSkinIndexes.rawValue)
        }
    }
    
    /// количество существующих в игре скинов для частичек 3D
    public static var _3DmaxParticleSkinIndex: Int = 12
    /// количество существующих в игре скинов для мячей 3D
    public static var _3DmaxBallSkinIndex: Int = 12
    /// количество существующих в игре скинов для ракеток 3D
    public static var _3DmaxPaddleSkinIndex: Int = 12
    
    /// текущий, выбранный игроком скин для частички 3D
    public static var _3DparticleSkinIndex: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserCustomizationKeys._3DparticleSkinIndex.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserCustomizationKeys._3DparticleSkinIndex.rawValue)
        }
    }
    /// текущий, выбранный игроком скин для мяча 3D
    public static var _3DballSkinIndex: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserCustomizationKeys._3DballSkinIndex.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserCustomizationKeys._3DballSkinIndex.rawValue)
        }
    }
    /// текущий, выбранный игроком скин для ракетки 3D
    public static var _3DpaddleSkinIndex: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserCustomizationKeys._3DballSkinIndex.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserCustomizationKeys._3DballSkinIndex.rawValue)
        }
    }
    
    /// все купленные игроком скины для частичек 3D
    public static var _3DbuyedParticlesSkinIndexes: [Int] {
        get {
            guard let array = UserDefaults.standard.array(forKey: UserCustomizationKeys._3DbuyedParticlesSkinIndexes.rawValue) as? [Int] else {
                return []
            }
            return array
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserCustomizationKeys._3DbuyedParticlesSkinIndexes.rawValue)
        }
    }
    /// все купленные игроком скины для мячей 3D
    public static var _3DbuyedBallSkinIndexes: [Int] {
        get {
            guard let array = UserDefaults.standard.array(forKey: UserCustomizationKeys._3DbuyedBallSkinIndexes.rawValue) as? [Int] else {
                return []
            }
            return array
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserCustomizationKeys._3DbuyedBallSkinIndexes.rawValue)
        }
    }
    /// все купленные игроком скины для ракеток 3D
    public static var _3DbuyedPaddleSkinIndexes: [Int] {
        get {
            guard let array = UserDefaults.standard.array(forKey: UserCustomizationKeys._3DbuyedPaddleSkinIndexes.rawValue) as? [Int] else {
                return []
            }
            return array
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserCustomizationKeys._3DbuyedPaddleSkinIndexes.rawValue)
        }
    }
    
    /// закрытый инициализатор, чтобы нельзя было создать ссылку на данный класс
    private init() {
        
    }
}
