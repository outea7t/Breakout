//
//  UserProgress.swift
//  Breakout
//
//  Created by Out East on 03.05.2023.
//

import Foundation

class UserProgress {
//    public static var stars: Int {}
    /// означает, что пользователь впервые заходит в приложение
    public static var isFirstTime: Bool = true
    public static var totalStars: Int = 0
    public static var totalScore: Int = 0
    
    public static var _2DmaxAvailableLevelID: Int = 1
    public static var _2DmaxLevelIndex: Int = 30
    public static var _2DlevelsStars = [Int](repeating: 0, count: 30)
    
    public static var _3DMaxAvailableLevelID: Int = 0
    public static var _3DmaxLevelIndex: Int = 30
    public static var _3DlevelsStars = [Int](repeating: 0, count: 30)
    
    private init() {
        
    }
}
