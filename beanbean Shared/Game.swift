//
//  Game.swift
//  beanbean
//
//  Created by Skylar Jones on 3/22/24.
//

import SpriteKit

enum GameState {
    case active
    case gravity
    case checkGroups
    case popGroups
    case new
}

struct GameParams {
    let cellSize: Int
    let rowCount: Int
    let columnCount: Int
    
}

//class Game {
//    
//    var gameState: GameState!
//    var beans : [Bean] = []
//    var cellsToExplode: [Cell] = []
//    var grid : Grid!
//    var beanPod: BeanPod!
//    var score: Score!
//    var settings: Settings!
//    
//    // 
//        
//    init(params: GameParams){
//        self.score = Score()
//        self.grid = Grid(
//            rowCount: params.rowCount,
//            columnCount: 5,
//            cellSize: params.cellSize,
//            showCells: params.debug.showCells,
//            showRowColumn: params.debug.showRowColumnNumbers
//        )
//        
//        
//        
//    }
//    
//}
