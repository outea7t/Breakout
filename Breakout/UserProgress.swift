//
//  UserProgress.swift
//  Breakout
//
//  Created by Out East on 03.05.2023.
//

import Foundation

class UserProgress {
    private enum UserProgressKey: String {
        case isFirstTime
        case totalStars
        case totalScore
        
        case _2DmaxAvailableLevelID
        case _2DmaxLevelIndex
        case _2DlevelsStars
        
        case _3DmaxAvailableLevelID
        case _3DmaxLevelIndex
        case _3DlevelsStars
    }
//    public static var stars: Int {}
    /// означает, что пользователь впервые заходит в приложение
    public static var isFirstTime: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserProgressKey.isFirstTime.rawValue)
        } set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserProgressKey.isFirstTime.rawValue)
        }
    }
    public static var totalStars: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserProgressKey.totalStars.rawValue)
        } set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserProgressKey.totalStars.rawValue)
        }
    }
    public static var totalScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserProgressKey.totalScore.rawValue)
        } set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserProgressKey.totalScore.rawValue)
        }
    }
    
    public static var _2DmaxAvailableLevelID: Int {
        get {
            if UserDefaults.standard.integer(forKey: UserProgressKey._2DmaxAvailableLevelID.rawValue) == 0 {
                return 1
            } else {
                return UserDefaults.standard.integer(forKey: UserProgressKey._2DmaxAvailableLevelID.rawValue)
            }
        } set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserProgressKey._2DmaxAvailableLevelID.rawValue)
        }
    }
    public static var _2DmaxLevelIndex: Int = 30
    public static var _2DlevelsStars: [Int] {
        get {
            guard let array = UserDefaults.standard.array(forKey: UserProgressKey._2DlevelsStars.rawValue) as? [Int] else {
                return [Int](repeating: 0, count: 30)
            }
            return array
        } set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserProgressKey._2DlevelsStars.rawValue)
        }
    }
    
    public static var _3DmaxAvailableLevelID: Int {
        get {
            if UserDefaults.standard.integer(forKey: UserProgressKey._3DmaxAvailableLevelID.rawValue) == 0 {
                return 1
            } else {
                return UserDefaults.standard.integer(forKey: UserProgressKey._3DmaxAvailableLevelID.rawValue)
            }
        } set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserProgressKey._3DmaxAvailableLevelID.rawValue)
        }
    }
    public static var _3DmaxLevelIndex: Int = 30
    public static var _3DlevelsStars: [Int] {
        get {
            guard let array = UserDefaults.standard.array(forKey: UserProgressKey._3DlevelsStars.rawValue) as? [Int] else {
                return [Int](repeating: 0, count: 30)
            }
            return array
        } set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserProgressKey._3DlevelsStars.rawValue)
        }
    }
    
    public static var _2DbuyedSkins: Int {
        get {
            return UserCustomization._2DbuyedBallSkinIndexes.count + UserCustomization._2DbuyedPaddleSkinIndexes.count + UserCustomization._2DbuyedParticlesSkinIndexes.count
        }
    }
    public static var _3DbuyedSkins: Int {
        get {
            return UserCustomization._3DbuyedBallSkinIndexes.count + UserCustomization._3DbuyedPaddleSkinIndexes.count + UserCustomization._3DbuyedParticlesSkinIndexes.count
        }
    }
    private init() {
        
    }
}
