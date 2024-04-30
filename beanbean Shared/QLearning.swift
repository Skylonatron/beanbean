//
//  QLearning.swift
//  beanbean
//
//  Created by Sam Willenson on 4/25/24.
//

import Foundation

enum Action: Codable {
    case moveLeft
    case moveRight
    case rotateClockwise
    case rotateCounterClockwise
    case moveDown
    case breakCombos
}

enum State: Codable {
    case buildCombos
    case handleNuisanceBeans
    case breakDown
    case gameLost
}

class QLearning{
    var qTable: [State: [Action: Double]] = [:]
    let possibleStates: [State] = [
        .buildCombos,
        .handleNuisanceBeans,
        .gameLost
    ]
    let possibleActions: [Action] = [
        .moveLeft,
        .moveRight,
        .rotateClockwise,
        .rotateCounterClockwise,
        .moveDown
    ]
    
    let learningRate: Double
    let discountFactor: Double
    let explorationRate: Double
    var currentState: State?
    var previousState: State?

    
    init(learningRate: Double, discountFactor: Double, explorationRate: Double) {
        self.learningRate = learningRate
        self.discountFactor = discountFactor
        self.explorationRate = explorationRate
        initializeQTable(states: possibleStates, actions: possibleActions)
    }
    
    func learn(chosenAction: Action, reward: Double, game: Game) {
        if self.currentState == nil || self.previousState == nil{
            self.currentState = .buildCombos
            self.previousState = .buildCombos
        }
        self.updateQValue(state: self.previousState!, action: chosenAction, reward: reward, nextState: self.currentState!)
    }
    
    func calculateReward(game: Game, qState: State) -> Double {
        var finalReward = 0.0
        switch qState {
        case .buildCombos:
            finalReward += 4.0 * Double(game.score.chainCount)
            
        case .handleNuisanceBeans:
            if game.nuisanceBeansToExplode.count != 0 {
                finalReward += 5.0
            }
        case .breakDown:
            if game.cellsToExplodeWithNuisance.count > 0 {
                finalReward += Double(game.cellsToExplodeWithNuisance.count) * 2.0
            }
        case .gameLost:
            finalReward -= 100.0
        }
        
        return finalReward
    }
    
    
    func chooseAction(state: State, possibleActions: [Action]) -> Action {
        //exploration/exploitation strategy here, epsilon greedy?
//        print(state)
        if Double.random(in: 0..<1) < explorationRate {
            return possibleActions.randomElement()!
        }
        else {
            return greedyAction(state: state, possibleActions: possibleActions)
        }
    }
    
    func initializeQTable(states: [State], actions: [Action]) {
        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("qtable.json")
            let data = try Data(contentsOf: url)
            let loadedQTable = try JSONDecoder().decode([State: [Action: Double]].self, from: data)
            qTable = loadedQTable
            print("Q-table loaded successfully.")
        }
        catch {
            print("no Q Table found, creating new one")
            for state in states {
                qTable[state] = [:]
                for action in actions {
                    qTable[state]?[action] = 0.0
                }
            }
        }
    }
    
    func updateQValue(state: State, action: Action, reward: Double, nextState: State) {
        var qValue = qTable[state]?[action] ?? 0.0
        
        let maxNextQValue = qTable[nextState]?.values.max() ?? 0.0
        
        qValue += learningRate * (reward + discountFactor * maxNextQValue - qValue)
        qTable[state, default: [:]][action] = qValue
    }
    
    func greedyAction(state: State, possibleActions: [Action]) -> Action {
        //favor exploitation
        guard let actions = qTable[state] else{
            return possibleActions.randomElement()!
        }
        return actions.max { $0.value < $1.value }!.key
        
    }
    
    func performAction (action: Action, game: Game, settings: Settings, beanPod: BeanPod, grid: Grid) {
        switch action{
        case .moveLeft:
            game.movementSpeed = settings.movement.defaultVerticalSpeed
            game.beanPod.moveLeft(grid: grid)
            break
        case .moveRight:
            game.movementSpeed = settings.movement.defaultVerticalSpeed
            game.beanPod.moveRight(grid: grid)
            break
        case .rotateClockwise:
            game.movementSpeed = settings.movement.defaultVerticalSpeed
            game.beanPod.spinPod(grid: grid, clockWise: true)
            break
        case .rotateCounterClockwise:
            game.movementSpeed = settings.movement.defaultVerticalSpeed
            game.beanPod.spinPod(grid: grid, clockWise: false)
            break
        case .moveDown:
            game.movementSpeed = settings.movement.fastVerticalSpeed
            break
        case .breakCombos: 
            
            break
            
        }
    }
    
    func analyzeBeans(beanPod: BeanPod, grid: Grid) {
        let mainBeanColor = beanPod.mainBean.color
        let sideBeanColor = beanPod.sideBean.color
        var mainBeanMatch = false
        var sideBeanMatch = false
        for row in (0..<grid.rowCount).reversed(){
            for column in 0..<grid.columnCount{
                if let cell = grid.cells[column]?[row]{
                    let cellBeanColor = cell.bean?.color
                    let cellXPosition = cell.shape.position.x
                    let upCell = cell.getUpCell(grid: grid)
                    let rightCell = cell.getRightCell(grid: grid)
                    let leftCell = cell.getLeftCell(grid: grid)
                    let mainBeanCell = beanPod.mainBean.getCell(grid: grid)
                    let mainBeanXPosition = beanPod.mainBean.shape.position.x
                    let sideBeanXPosition = beanPod.sideBean.shape.position.x
                    if cellBeanColor == mainBeanColor{
                        mainBeanMatch = true
                        if upCell?.bean?.color == sideBeanColor {
                            
                        }
                    }
                    if cellBeanColor == sideBeanColor{
                        sideBeanMatch = true
                    }
                }
            }
        }
    }
    
    func saveQTableToFile() {
        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("qtable.json")
            let data = try JSONEncoder().encode(qTable)
            try data.write(to: url)
            print("Q-table saved successfully.")
            print("Q-table file path:", url.path)
        } catch {
            print("Error saving Q-table:", error)
        }
    }
}
