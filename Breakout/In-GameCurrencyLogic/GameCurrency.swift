//
//  GameCurrency.swift
//  Breakout
//
//  Created by Out East on 02.01.2023.
//

import Foundation
import UIKit

// статический класс со значением валюты
// сделать систему очков за прохождение уровня
// их количество(очков) будет зависеть от потерянных жизней
// -1: 80% от очков, -2: 60% от очков, -3 и т.д.: 50% от очков
// также от времени(систему подсчета пока не придумал)
// за каждый пройденный уровень будут давать монеты, которые потом можно будет тратить на скины
// сейчас пока планируется сделать скины-текстуры на мяч, частички, которые отлетают от него,
// возможно еще на ракетку(но с этим у меня пока что мало идей)

struct GameCurrency {
    /// текущее количество денег, которое есть у пользователя
    public static var userMoney: Int = 10000
    /// функция, которое возвращает строковое количество денег пользователя
    /// если их больше 1000 то она убирает 0 и приписывает к в конце
    public static func updateUserMoneyLabel() -> String {
        var userMoneyLabel = ""
        if GameCurrency.userMoney > 1000 {
            let userMoney = GameCurrency.userMoney
            let thousands = userMoney/1000
            let hundreds = (userMoney-1000*thousands)/100
            if hundreds == 0 {
                userMoneyLabel = "\(thousands)k"
            } else {
                userMoneyLabel = "\(thousands).\(hundreds)k"
            }
        } else {
            userMoneyLabel = "\(GameCurrency.userMoney)"
        }
        
        return userMoneyLabel
    }
    
    // чтобы нельзя было инициализировать элементы данного класса
    private init() {
        
    }
}
