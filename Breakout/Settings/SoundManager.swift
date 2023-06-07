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
    case gameAmbient
    case loseResult
    case breakoutmain
}

/// менеджер проигрывания звуков
struct SoundManager {
    
    public static var musicVolume: Float = UserSettings.musicVolumeValue {
        willSet {
            SoundManager.ambientMusicPlayer?.volume = newValue
        }
    }
    public static var soundsVolume: Float = UserSettings.soundsVolumeValue {
        willSet {
            
        }
    }
    private static var ambientMusicPlayer: AVAudioPlayer?
    /// звук столкновения мяча с ракеткой
    private static var ballPaddleBumpSoundPlayer: AVAudioPlayer?
    /// для проигрывания звука столкновения мяча со всеми игровыми объектами, кроме ракетки
    private static var ballBrickBumpSoundPlayer: AVAudioPlayer?
    /// для проигрывания звука активации бонуса
    private static var bonusActivationSoundPlayer: AVAudioPlayer?
    /// для проигрывания звука проигрыша, или выигрыша
    private static var loseResultOfGameSoundPlayer: AVAudioPlayer?
    /// обязательно нужно вызвать эту функцию в главном меню для настройки всех плейеров
//    public static func setup() {
//        guard let ballPaddleBumpURL = Bundle.main.url(forResource: SoundNames.ballPaddleBump.rawValue, withExtension: "wav"),
//              let ballEverythingBumpURL = Bundle.main.url(forResource: SoundNames.brickEverythingBump.rawValue, withExtension: "wav"),
//              let bonusActivationURL = Bundle.main.url(forResource: SoundNames.bonusActivation.rawValue, withExtension: "wav"),
//              let loseResultOfGameSoundURL = Bundle.main.url(forResource: SoundNames.loseResult.rawValue, withExtension: "wav") else {
//            return
//        }
//        
//        do {
//            SoundManager.ballPaddleBumpSoundPlayer = try AVAudioPlayer(contentsOf: ballPaddleBumpURL)
//            SoundManager.ballPaddleBumpSoundPlayer?.volume = UserSettings.soundsVolumeValue
//            SoundManager.ballPaddleBumpSoundPlayer?.numberOfLoops = 0
//            SoundManager.ballPaddleBumpSoundPlayer?.play()
//        } catch {
//            print(error.localizedDescription)
//        }
//        
//        do {
//            SoundManager.ballBrickBumpSoundPlayer = try AVAudioPlayer(contentsOf: ballEverythingBumpURL)
//            SoundManager.ballBrickBumpSoundPlayer?.volume = UserSettings.soundsVolumeValue
//            SoundManager.ballBrickBumpSoundPlayer?.numberOfLoops = 0
//            SoundManager.ballBrickBumpSoundPlayer?.play()
//        } catch {
//            print(error.localizedDescription)
//        }
//        
//        do {
//            SoundManager.bonusActivationSoundPlayer = try AVAudioPlayer(contentsOf: bonusActivationURL)
//            SoundManager.bonusActivationSoundPlayer?.volume = UserSettings.soundsVolumeValue
//            SoundManager.bonusActivationSoundPlayer?.numberOfLoops = 0
//            SoundManager.bonusActivationSoundPlayer?.play()
//        } catch {
//            print(error.localizedDescription)
//        }
//        
//        do {
//            SoundManager.loseResultOfGameSoundPlayer = try AVAudioPlayer(contentsOf: loseResultOfGameSoundURL)
//            SoundManager.loseResultOfGameSoundPlayer?.volume = UserSettings.soundsVolumeValue
//            SoundManager.loseResultOfGameSoundPlayer?.numberOfLoops = 0
//            SoundManager.loseResultOfGameSoundPlayer?.play()
//        } catch {
//            print(error.localizedDescription)
//        }
//        
//    }
    
    public static func playMenuAmbientMusic() {
        guard let musicURL = Bundle.main.url(forResource: SoundNames.breakoutmain.rawValue, withExtension: "mp3") else {
            return
        }
        do {
            SoundManager.ambientMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
            SoundManager.ambientMusicPlayer?.volume = UserSettings.musicVolumeValue
            SoundManager.ambientMusicPlayer?.numberOfLoops = -1
            SoundManager.ambientMusicPlayer?.play()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public static func playBallPaddleBumpSound() {
        SoundManager.ballPaddleBumpSoundPlayer?.volume = UserSettings.soundsVolumeValue
        SoundManager.ballPaddleBumpSoundPlayer?.play()
    }
    
    public static func playBallBrickBumpSound() {
        guard let url = Bundle.main.url(forResource: SoundNames.brickEverythingBump.rawValue, withExtension: "wav") else {
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = UserSettings.soundsVolumeValue
            player.numberOfLoops = 0
            player.play()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public static func playBonusActivationSound() {
        SoundManager.bonusActivationSoundPlayer?.volume = UserSettings.soundsVolumeValue
        SoundManager.bonusActivationSoundPlayer?.play()
    }
    public static func playLoseResultOfGameSound() {
        SoundManager.loseResultOfGameSoundPlayer?.volume = UserSettings.soundsVolumeValue
        SoundManager.loseResultOfGameSoundPlayer?.play()
    }
    
    private init() {
        
    }
}
