//
//  QLearning.swift
//  beanbean
//
//  Created by Sam Willenson on 4/25/24.
//

import Foundation

enum Action {
    case moveLeft
    case moveRight
    case rotateClockwise
    case rotateCounterClockwise
    case moveDown
}

enum State {
    case searchForCombos
    case handleNuisanceBeans
    case gameOver
}

class QLearning{
    var qTable: [State: [Action: Double]] = [:]
    
    let learningRate: Double
    let discountFactor: Double
    let explorationRate: Double
    var currentState: State?
    var previousState: State?
    let possibleActions: [Action] = [.moveLeft, .moveRight, .rotateClockwise, .rotateCounterClockwise, .moveDown]
    
    init(learningRate: Double, discountFactor: Double, explorationRate: Double) {
        self.learningRate = learningRate
        self.discountFactor = discountFactor
        self.explorationRate = explorationRate
    }
    
    func learn(chosenAction: Action, reward: Double, game: Game) {
        if self.currentState == nil || self.previousState == nil{
            self.currentState = .searchForCombos
            self.previousState = .searchForCombos
        }
        self.updateQValue(state: self.previousState!, action: chosenAction, reward: reward, nextState: self.currentState!)
    }
    
    func calculateReward(game: Game, qState: State) -> Double {
        var finalReward = 0.0
        switch qState {
        case .searchForCombos:
            finalReward += 4.0 * Double(game.score.chainCount)
            
        case .handleNuisanceBeans:
            if game.nuisanceBeansToExplode.count != 0 {
                finalReward += 5.0
            }
        case .gameOver:
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
        for state in states {
            qTable[state] = [:]
            for action in actions {
                qTable[state]?[action] = 0.0
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
        }
    }
}
