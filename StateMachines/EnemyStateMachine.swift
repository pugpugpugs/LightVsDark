import SpriteKit

class EnemyStateMachine: StateMachine<EnemyState> {
    
    weak var enemy: Enemy?
    private var animationProvider: AnimationProvider
    private var stateAnimations: [EnemyState: SKAction] = [:]
    var targetPosition: CGPoint = .zero
    
    init(enemy: Enemy, animationProvider: AnimationProvider) {
        self.enemy = enemy
        self.animationProvider = animationProvider
        super.init(initialState: .idle)
        setupAnimations()
        setupStates()
    }
    
    // MARK: - Setup Animations per State
    private func setupAnimations() {
        for state in [EnemyState.idle, .moving, .takingDamage, .dead] {
            let frames = animationProvider.frames(for: state)
            guard !frames.isEmpty else { continue }
            
            // Create repeating animation SKAction
            let animation = SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 0.1))
            stateAnimations[state] = animation
        }
    }
    
    // MARK: - Setup States
    private func setupStates() {
        for state in [EnemyState.idle, .moving, .takingDamage, .dead] {
            register(
                state: state,
                onEnter: { [weak self] in self?.enter(state: state) },
                onExit: { [weak self] in self?.exit(state: state) },
                onUpdate: { [weak self] deltaTime in self?.updateState(state: state, deltaTime: deltaTime) }
            )
        }
    }
    
    // MARK: - State Enter
    private func enter(state: EnemyState) {
        guard let enemy = enemy else { return }
        
        // Stop previous state animation (optional, only if key differs)
        // Not needed if each state has its own key
        
        // Play frame animation for this state
        if let action = stateAnimations[state] {
            let actionKey = "\(state)Animation"
            if enemy.sprite.action(forKey: actionKey) == nil {
                enemy.sprite.run(action, withKey: actionKey)
            }
        }
        
        // Set tint for differentiation (optional)
        enemy.sprite.color = color(for: state)
        enemy.sprite.colorBlendFactor = 1.0
        enemy.sprite.blendMode = .add
    }
    
    // MARK: - State Exit
    private func exit(state: EnemyState) {
        // Stop any temporary effects if needed
        guard let enemy = enemy else { return }
        if state == .takingDamage {
            enemy.stopDamageEffect() // stops the flashing effect
        }
    }
    
    // MARK: - State Update
    private func updateState(state: EnemyState, deltaTime: CGFloat) {
        guard let enemy = enemy else { return }
        switch state {
        case .moving:
            enemy.move(deltaTime: deltaTime, targetPosition: targetPosition)
        case .takingDamage:
            enemy.startDamageEffect() // runs separate "damageFlash" SKAction
        default:
            break
        }
    }
    
    // MARK: - Helpers
    private func color(for state: EnemyState) -> UIColor {
        switch state {
        case .idle: return .blue
        case .moving: return .black
        case .takingDamage: return .red
        case .dead: return .white
        }
    }
}
