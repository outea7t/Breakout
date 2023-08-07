//
//  SegueNames.swift
//  Breakout
//
//  Created by Out East on 07.08.2023.
//

import Foundation
import UIKit

enum GameSegue: String {
    // 2D
    case menuToLevelsMenu = "FromMenuToLevelsMenu"
    case mainMenuToShop = "FromMainMenuToShop"
    case menuToARMenu = "FromMenuToARMenu"
    case levelsMenuToGame = "FromLevelsMenuToGame"
    case levelsMenuToCoachingView = "FromLevelsMenuToCoachingView"
    case gameToPause = "FromGameToPause"
    case gameToLose = "FromGameToLose"
    case gameToWin = "FromGameToWin"
    
    // 3D AR
    case arMenuToLevelsARMenu = "FromARMenuToLevelsARMenu"
    case levelsARMenuToARGameMenu = "FromLevelsARMenuToARGameMenu"
    case arGameToARWin = "FromARGameToARWin"
    case arGameToARLose = "FromARGameToARLose"
    case arGameToARPause = "FromARGameToARPause"
    
    // Shop
    // 2D
    case ballTexturesToCellMenu = "FromBallTexturesToCellMenu"
    case paddleTexturesToCellMenu = "FromPaddleTexturesToCellMenu"
    case particleTexturesToCellMenu = "FromParticleTexturesToCellMenu"
    case levelTexturesToCellMenu = "FromLevelTexturesToCellMenu"
    // 3D
    case ball3DToCellMenu3D = "FromBall3DToCellMenu3D"
    case paddle3DToCellMenu3D = "FromPaddle3DToCellMenu3D"
    case particles3DToCellMenu3D = "FromParticles3DToCellMenu3D"
}
