//
//  QLearning.swift
//  beanbean
//
//  Created by Sam Willenson on 4/24/24.
//


class QLearning{
    
    enum QLearningAction{
        case moveLeft
        case moveRight
        case rotateClockwise
        case defaultAction
    }
    
    var game: Game
    
    var qTable: [String: [QLearningAction: Double]] = [:]
    let learningRate: Double //alpha
    let discountFactor: Double //gamma
    let explorationRate: Double //epsilon
    var currentState: String?
    var previousState: String?
    var previousAction: QLearningAction?
    var initialState: String?
    var action: QLearningAction?
    
    init(learningRate: Double, discountFactor: Double, explorationRate: Double, currentState: String?, previousState: String?, previousAction: QLearningAction? = nil, initialState: String, game: Game) {
        self.learningRate = learningRate
        self.discountFactor = discountFactor
        self.explorationRate = explorationRate
        self.currentState = currentState
        self.previousState = previousState
        self.previousAction = previousAction
        self.initialState = initialState
        self.game = game
        self.action = self.selectAction(state: currentState ?? "")
    }
    
    
    
    func selectAction(state: String) -> QLearningAction {
        //epsilon greedy policy
        // Implement epsilon-greedy policy here
        // Choose a random action with probability epsilon, otherwise choose the action with the highest Q-value for the current state
        // Update previousState and previousAction accordingly
        // Return the chosen action
        
        var action: QLearningAction
        if Double.random(in: 0...1) < explorationRate{
            //choose random action
            let randomIndex = Int.random(in: 0...3)
            let actions: [QLearningAction] = [.moveLeft, .moveRight, .rotateClockwise]
            action = actions[randomIndex]
        }
        else{
            //choose action with highest qValue for the current state
            if let qValues = qTable[state]{
                action = qValues.max { $0.value < $1.value }?.key ?? .defaultAction
            }
            else{
                //state is not in the q table
                action = .defaultAction
            }
        }
        previousState = state
        previousAction = action
        return action
    }
    

    
    func transitionState(action: QLearningAction, grid: Grid){
        switch action {
         case .moveLeft:
             // Move the agent left
             // Update game state
            game.beanPod.moveLeft(grid: grid)
         case .moveRight:
             // Move the agent right
             // Update game state
            game.beanPod.moveRight(grid: grid)
         case .rotateClockwise:
             // Rotate the agent clockwise
             // Update game state
            game.beanPod.spinPod(grid: grid, clockWise: true)
         case .defaultAction:
             // Perform some default action
             // Update game state
            if game.beanPod.active {
                game.fastMovement = true
            }
         }
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
    
    func train(numEpisodes: Int, grid: Grid) {
        for _ in 0..<numEpisodes {
            startNewEpisode(initialState: initialState!)
            while !isEpisodeFinished() {
                let action = selectAction(state: currentState!)
                transitionState(action: action, grid: grid)
                let reward = observeReward()
                updateQValues(reward: reward, newState: currentState!)
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
        return self.game.gameState == .endScreen
    }
    
    func test(){
        
    }
}
