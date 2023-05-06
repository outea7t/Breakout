//
//  CountingLabel.swift
//  CustomTransitions
//
//  Created by Out East on 06.05.2023.
//

import UIKit

/// класс, который проигрывает анимацию отсчета с startValue до endValue за duration секунд
class CountingLabel: UILabel {
    
    // экспонента для скорости
    let counterVelocity: Float = 3.0
    enum CounterAnimationType {
        case linear // f(x) = x
        case easeIn // f(x) = x^3
        case easeOut // f(x) = (1-x)^3
    }
    enum CounterType {
        case int
        case float
    }
    var startNumber: Float = 0.0
    var endNumber: Float = 0.0
    
    var progress: TimeInterval!
    var duration: TimeInterval!
    /// когда анимация закончена
    var lastUpdate: TimeInterval!
    
    var timer: Timer?
    
    var counterType: CounterType!
    var counterAnimationType: CounterAnimationType!
    
    var currentCounterValue: Float {
        if self.progress >= self.duration {
            return self.endNumber
        }
        
        let percentage = Float(progress/duration)
        let update = self.updateCounter(counterValue: percentage)
        
        return self.startNumber + (update * (self.endNumber - self.startNumber))
    }
    
    func count(fromValue: Float,
               to toValue: Float,
               withDuration duration: TimeInterval,
               animationType: CounterAnimationType,
               counterType: CounterType) {
        self.startNumber = fromValue
        self.endNumber = toValue
        self.counterType = counterType
        self.counterAnimationType = animationType
        self.progress = 0
        self.duration = duration
        self.lastUpdate = Date.timeIntervalSinceReferenceDate
        if duration == 0 {
            updateText(value: toValue)
            return
        }
        self.invalidateTimer()
        self.timer = Timer.scheduledTimer(timeInterval: 0.01,
                                          target: self,
                                          selector: #selector(self.updateValue),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    @objc func updateValue() {
        let now = Date.timeIntervalSinceReferenceDate
        self.progress = progress + (now - self.lastUpdate)
        self.lastUpdate = now
        
        if progress >= duration {
            progress = duration
        }
        
        self.updateText(value: self.currentCounterValue)
    }
    func updateText(value: Float) {
        switch counterType {
        case .int:
            self.text = "\(Int(value))"
        case .float:
            self.text = String(format: "%.2f", value)
        case .none:
            break
        }
    }
    func updateCounter(counterValue: Float) -> Float {
        switch self.counterAnimationType {
        case .linear:
            return counterValue
        case .easeIn:
            return powf(counterValue, self.counterVelocity)
        case .easeOut:
            return 1.0 - powf(1.0 - counterValue, self.counterVelocity)
        case .none:
            return 0.0
        }
    }
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
}
