import Foundation
import CoreGraphics

/// Generic State Machine
class StateMachine<State: Hashable> {

    private(set) var currentState: State

    init(initialState: State) {
        self.currentState = initialState
    }

    /// Call this to enter a new state
    func enter(_ newState: State) {
        // Don't re-enter the same state
        guard newState != currentState else { return }

        // Call exit for current
        exit(currentState)

        // Update state
        currentState = newState

        // Call enter for new
        enterState(newState)
    }

    /// Update the current state
    func update(deltaTime: CGFloat) {
        updateState(currentState, deltaTime: deltaTime)
    }

    /// Override in subclass: things that happen on enter
    func enterState(_ state: State) {}

    /// Override in subclass: things that happen on exit
    func exit(_ state: State) {}

    /// Override in subclass: things that happen every frame for current state
    func updateState(_ state: State, deltaTime: CGFloat) {}
}
