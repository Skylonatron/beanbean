//
//  QLearning.swift
//  beanbean
//
//  Created by Sam Willenson on 4/24/24.
//

class QLearning{
    var qTable: [String: [String: Double]] = [:]
    
    let learningRate: Double //alpha
    let discountFactor: Double //gamma
    let explorationRate: Double //epsilon
    var currentState: String?
    var previousState: String?
    
    var previousAction: String?
    
    init(learningRate: Double, discountFactor: Double, explorationRate: Double, currentState: String?, previousState: String?, previousAction: String? = nil) {
        self.learningRate = learningRate
        self.discountFactor = discountFactor
        self.explorationRate = explorationRate
        self.currentState = currentState
        self.previousState = previousState
        self.previousAction = previousAction
    }
    
    func selectAction(state: String) -> String {
        //epsilon greedy policy
        // Implement epsilon-greedy policy here
        // Choose a random action with probability epsilon, otherwise choose the action with the highest Q-value for the current state
        // Update previousState and previousAction accordingly
        // Return the chosen action
        
        var action: String
        if Double.random(in: 0...1) < explorationRate{
            //choose random action
        }
        else{
            //choose action with highest qValue for the current state
            if let qValues = qTable[state]{
                action = qValues.max { $0.value < $1.value }?.key ?? ""
            }
            else{
                //state is not in the q table
                action = ""
            }
        }
        previousState = state
        previousAction = action
        return action
    }
    
    func transitionState(action: String){
        
    }
    
    func updateQValues(reward: Double, newState: String) {
        // Implement Q-value update using the Q-learning formula
        // Update the Q-value for the previous state-action pair
        guard let prevState = previousState, let prevAction = previousAction else{
            return
        }
        let targetQValue = reward + discountFactor * (qTable[newState]?.values.max() ?? 0)
        let oldValue = qTable[prevState]?[prevAction] ?? 0
        qTable[prevState]?[prevAction] = oldValue + learningRate * (targetQValue - oldValue)
        
    }
    
    func train(numEpisodes: Int) {
        for _ in 0..<numEpisodes {
            startNewEpisode(initialState: initialState)
            while !isEpisodeFinished() {
                let action = selectAction(state: currentState)
                transitionState(action: action)
                let reward = observeReward()
                updateQValues(reward: reward, newState: currentState)
            }
            
        }
    }
    
    func startNewEpisode(initialState: String) {
        // Reset the current state to the initial state
        // Clear the previous state and previous action
        currentState = initialState
        previousState = nil
        previousAction = nil
    }
    
    func observeReward() -> Double {
        return 0
    }
    
    func isEpisodeFinished() -> Bool {
        return false
    }
    
    func test(){
        
    }
}
