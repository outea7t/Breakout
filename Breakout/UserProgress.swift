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
        case timeSpent
        
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
    /// общее количество звезд, которое пользователь получил во время прохождения уровней в 2д и 3д режимах игры
    public static var totalStars: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserProgressKey.totalStars.rawValue)
        } set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserProgressKey.totalStars.rawValue)
        }
    }
    /// общее количество очков, которое пользователь получил во время игры в 2д и 3д режимах игры
    public static var totalScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserProgressKey.totalScore.rawValue)
        } set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserProgressKey.totalScore.rawValue)
        }
    }
    /// количество времени, которое пользователь провел в игре
    public static var timeSpent: TimeInterval {
        get {
            return UserDefaults.standard.double(forKey: UserProgressKey.timeSpent.rawValue)
        } set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserProgressKey.timeSpent.rawValue)
        }
    }
    /// количество времени, которое польозватель провел в игре в строковом выражении
    /// если меньше минуты будет возвращать целое число секунд
    /// если меньше часа будет возвращать целое число минут
    /// иначе целое число часов
    public static var timeSpentString: String {
        get {
            let timeSpentValue = Int(UserProgress.timeSpent)
            if timeSpentValue < 60 {
                return "\(timeSpentValue)sec"
            } else if timeSpentValue >= 60 && timeSpentValue < 3600 {
                return "\(timeSpentValue/60)min"
            } else {
                return "\(timeSpentValue/3600)h"
            }
        }
    }
    /// индекс максимального уровня, который доступен пользователю для прохождения в 2д
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
    /// максимальное количество уровней в 2д режиме
    public static var _2DmaxLevelIndex: Int = 30
    /// количество звезд, которое получил пользователь за каждый отдельный уровень
    public static var _2DlevelsStars: [Int] {
        get {
            guard let array = UserDefaults.standard.array(forKey: UserProgressKey._2DlevelsStars.rawValue) as? [Int] else {
                return [Int](repeating: 0, count: UserProgress._2DmaxLevelIndex)
            }
            return array
        } set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserProgressKey._2DlevelsStars.rawValue)
        }
    }
    /// количество скинов в режиме 2д, которое купил пользователь
    public static var _2DbuyedSkins: Int {
        get {
            return UserCustomization._2DbuyedBallSkinIndexes.count + UserCustomization._2DbuyedPaddleSkinIndexes.count + UserCustomization._2DbuyedParticlesSkinIndexes.count
        }
    }
    /// индекс максимально доступного уровня в 3д режиме
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
    /// максимальное количество уровней в 3д режиме
    public static var _3DmaxLevelIndex: Int = 30
    /// количество звезд, которое получил пользователь за каждый уровень
    public static var _3DlevelsStars: [Int] {
        get {
            guard let array = UserDefaults.standard.array(forKey: UserProgressKey._3DlevelsStars.rawValue) as? [Int] else {
                return [Int](repeating: 0, count: UserProgress._3DmaxLevelIndex)
            }
            return array
        } set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserProgressKey._3DlevelsStars.rawValue)
        }
    }
    /// количество купленных пользователем скинов в 3д режиме игры
    public static var _3DbuyedSkins: Int {
        get {
            return UserCustomization._3DbuyedBallSkinIndexes.count + UserCustomization._3DbuyedPaddleSkinIndexes.count + UserCustomization._3DbuyedParticlesSkinIndexes.count
        }
    }
    
    private init() {
        
    }
}
