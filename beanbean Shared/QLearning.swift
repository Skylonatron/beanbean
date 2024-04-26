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
}

enum State {
    case searchForCombos
    case lookAtNextBean
    case emptyBoard
    case navigateBean
    case handleNuisanceBeans
    case gameOver
}

class QLearning{
    var qTable: [State: [Action: Double]] = [:]
    
    let learningRate: Double
    let discountFactor: Double
    let explorationRate: Double
    
    init(learningRate: Double, discountFactor: Double, explorationRate: Double) {
        self.learningRate = learningRate
        self.discountFactor = discountFactor
        self.explorationRate = explorationRate
    }
    
    func chooseAction(state: State, possibleActions: [Action]) -> Action {
        //exploration/exploitation strategy here, epsilon greedy?
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
    
    private func greedyAction(state: State, possibleActions: [Action]) -> Action {
        //favor exploitation
        guard let actions = qTable[state] else{
            return possibleActions.randomElement()!
        }
        return actions.max { $0.value < $1.value }!.key
        
    }
}
