//
//  SoundManager.swift
//  Breakout
//
//  Created by Out East on 06.06.2023.
//

import Foundation
import AVFoundation

/// названия всех звуков, которые есть в игре
enum SoundNames: String {
    case ballPaddleBump
    case bonusActivation
    case brickEverythingBump
    case loseResult
    case breakoutmain
    case gameAmbient
}

/// менеджер проигрывания звуков
struct SoundManager {
    
    public static var musicVolume: Float = UserSettings.musicVolumeValue {
        willSet {
            SoundManager.ambientAudioPlayer?.volume = newValue
            SoundManager.gameAmbientAudioPlayer?.volume = newValue
        }
    }
    public static var soundsVolume: Float = UserSettings.soundsVolumeValue {
        willSet {
            
        }
    }
    /// фоновый звук в игре
    private static var gameAmbientAudioPlayer: AVAudioPlayer?
    /// фоновый звук в меню
    private static var ambientAudioPlayer: AVAudioPlayer?
    /// звук столкновения мяча с ракеткой
    private static var ballPaddleBumpSoundPlayer: AVAudioPlayer?
    /// для проигрывания звука столкновения мяча со всеми игровыми объектами, кроме ракетки
    private static var ballBrickBumpSoundPlayer: AVAudioPlayer?
    /// для проигрывания звука активации бонуса
    private static var bonusActivationSoundPlayer: AVAudioPlayer?
    /// для проигрывания звука проигрыша, или выигрыша
    private static var loseResultOfGameSoundPlayer: AVAudioPlayer?
    /// обязательно нужно вызвать эту функцию в главном меню для настройки всех плейеров

    public static func playMenuAmbientMusic() {
        guard let musicURL = Bundle.main.url(forResource: SoundNames.breakoutmain.rawValue, withExtension: "mp3") else {
            return
        }
        do {
            SoundManager.ambientAudioPlayer = try AVAudioPlayer(contentsOf: musicURL)
            SoundManager.ambientAudioPlayer?.volume = UserSettings.musicVolumeValue
            SoundManager.ambientAudioPlayer?.numberOfLoops = -1
            SoundManager.ambientAudioPlayer?.play()
        } catch {
            print(error.localizedDescription)
        }
    }
    public static func stopMenuAmbientMusic() {
        SoundManager.ambientAudioPlayer?.stop()
        SoundManager.ambientAudioPlayer = nil
    }
    
    public static func playGameAmbientMusic() {
        guard let musicURL = Bundle.main.url(forResource: SoundNames.gameAmbient.rawValue, withExtension: "mp3") else {
            return
        }
        do {
            SoundManager.gameAmbientAudioPlayer = try AVAudioPlayer(contentsOf: musicURL)
            SoundManager.gameAmbientAudioPlayer?.volume = UserSettings.musicVolumeValue
            SoundManager.gameAmbientAudioPlayer?.numberOfLoops = -1
            SoundManager.gameAmbientAudioPlayer?.play()
        } catch {
            print(error.localizedDescription)
        }
    }
    public static func stopGameAmbientMusic() {
        SoundManager.gameAmbientAudioPlayer?.stop()
        SoundManager.gameAmbientAudioPlayer = nil
    }
    private init() {
        
    }
}
