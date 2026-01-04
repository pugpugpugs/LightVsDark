import SpriteKit

class EnemyStateMachine: StateMachine<EnemyState> {
    
    weak var enemy: Enemy?
    private var animationProvider: AnimationProvider
    private var stateAnimations: [EnemyState: SKAction] = [:]
    var targetPosition: CGPoint = .zero
    
    init(enemy: Enemy, animationProvider: AnimationProvider) {
        self.enemy = enemy
        self.animationProvider = animationProvider
        super.init(initialState: .none)
        setupAnimations()
        setupStates()
    }
    
    // MARK: - Setup Animations per State
    private func setupAnimations() {
        for state in [EnemyState.idle, .moving, .takingDamage, .dead, .attacking] {
            let frames = animationProvider.frames(for: state)
            guard !frames.isEmpty else { continue }
            
            let action: SKAction
            
            if state == .attacking || state == .dead {
                action = SKAction.animate(with: frames, timePerFrame:  0.1)
            } else {
                action = SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 0.1))
            }
            
            stateAnimations[state] = action
        }
    }
    
    // MARK: - Setup States
    private func setupStates() {
        for state in [EnemyState.idle, .moving, .takingDamage, .dead, .attacking] {
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

        // Stop previous state actions
        enemy.sprite.removeAllActions()

        guard let action = stateAnimations[state] else { return }

        switch state {

        case .idle:
            if let idleAnim = stateAnimations[.idle] {
                enemy.sprite.run(idleAnim, withKey: "idleAnimation")
            }

            let waitThenMove = SKAction.sequence([
                SKAction.wait(forDuration: 2.0),
                SKAction.run { [weak enemy] in
                    enemy?.stateMachine.enter(.moving)
                }
            ])
            enemy.sprite.run(waitThenMove, withKey: "idleTransition")

        case .attacking:
            enemy.sprite.run(action, completion: { [weak self] in
                self?.enemy?.didFinishAttack()
            })
        case .dead:
            enemy.sprite.run(action, completion: { [weak enemy] in
                enemy?.die()
            })
        default:
            enemy.sprite.run(action, withKey: "\(state)Animation")
        }
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
        
        if state == .moving {
            let distance = enemy.position.distance(to: targetPosition)
            if distance <= enemy.attackRange {
                self.enter(state: .attacking)
            } else {
                enemy.move(deltaTime: deltaTime, targetPosition: targetPosition)
            }
        }
        
        switch state {
//        case .moving:
//            enemy.move(deltaTime: deltaTime, targetPosition: targetPosition)
        case .takingDamage:
            enemy.startDamageEffect()

        default:
            break
        }
    }
}
