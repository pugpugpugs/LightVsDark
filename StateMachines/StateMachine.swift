import Foundation
import CoreGraphics

/// Generic State Machine
class StateMachine<State: Hashable> {
    
    private(set) var currentState: State
    private var enterHandlers: [State: () -> Void] = [:]
    private var exitHandlers: [State: () -> Void] = [:]
    private var updateHandlers: [State: (_ deltaTime: CGFloat) -> Void] = [:]
    
    init(initialState: State) {
        self.currentState = initialState
    }
    
    /// Register callbacks for a specific state
    func register(
        state: State,
        onEnter: (() -> Void)? = nil,
        onExit: (() -> Void)? = nil,
        onUpdate: ((_ deltaTime: CGFloat) -> Void)? = nil
    ) {
        if let enter = onEnter { enterHandlers[state] = enter }
        if let exit = onExit { exitHandlers[state] = exit }
        if let update = onUpdate { updateHandlers[state] = update }
    }
    
    /// Transition to a new state
    func enter(_ newState: State) {
        guard newState != currentState else { return }
        exitHandlers[currentState]?()
        currentState = newState
        enterHandlers[newState]?()
    }
    
    /// Call in your update loop
    func update(deltaTime: CGFloat) {
        updateHandlers[currentState]?(deltaTime)
    }
}
