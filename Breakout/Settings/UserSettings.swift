//
//  UserSettings.swift
//  Breakout
//
//  Created by Out East on 05.06.2023.
//

import Foundation
import UIKit

struct UserSettings {
    private enum UserSettingsKeys: String {
        case musicVolumeValue
        case soundsVolumeValue
    }
    /// значение громкости для музыки
    public static var musicVolumeValue: Float {
        get {
            return UserDefaults.standard.float(forKey: UserSettingsKeys.musicVolumeValue.rawValue)
        } set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserSettingsKeys.musicVolumeValue.rawValue)
            SoundManager.musicVolume = newValue
        }
    }
    /// значение громкости для звуков
    public static var soundsVolumeValue: Float {
        get {
            return UserDefaults.standard.float(forKey: UserSettingsKeys.soundsVolumeValue.rawValue)
        } set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserSettingsKeys.soundsVolumeValue.rawValue)
            SoundManager.soundsVolume = newValue
        }
    }
    private init() {
        
    }
}
