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
        super.enter(.idle) // Trigger initial state enter
    }

    private func setupAnimations() {
        for state in [EnemyState.idle, .moving, .takingDamage, .attacking, .dead] {
            let frames = animationProvider.frames(for: state)
            guard !frames.isEmpty else { continue }

            let action: SKAction
            if state == .attacking || state == .dead {
                action = SKAction.animate(with: frames, timePerFrame: 0.1)
            } else {
                action = SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 0.1))
            }

            stateAnimations[state] = action
        }
    }

    // MARK: - Enter
    override func enterState(_ state: EnemyState) {
        guard let enemy = enemy else { return }

        enemy.sprite.removeAllActions() // Clear previous state actions

        switch state {
        case .idle:
            if let anim = stateAnimations[.idle] {
                enemy.sprite.run(anim, withKey: "idleAnimation")
            }
            let waitThenMove = SKAction.sequence([
                SKAction.wait(forDuration: 2.0),
                SKAction.run { [weak enemy] in
                    enemy?.stateMachine.enter(.moving)
                }
            ])
            enemy.sprite.run(waitThenMove, withKey: "idleTransition")

        case .moving:
            if let anim = stateAnimations[.moving] {
                enemy.sprite.run(anim, withKey: "movingAnimation")
            }

        case .attacking:
            if let anim = stateAnimations[.attacking] {
                enemy.sprite.run(anim, completion: { [weak enemy] in
                    enemy?.didFinishAttack()
                })
            }

        case .takingDamage:
            if let anim = stateAnimations[.takingDamage] {
                enemy.sprite.run(anim, withKey: "damageAnimation")
            }
            enemy.startDamageEffect()

        case .dead:
            if let anim = stateAnimations[.dead] {
                enemy.sprite.run(anim, completion: { [weak enemy] in
                    enemy?.destroy()
                })
            } else {
                enemy.destroy()
            }
        default:
            break
        }
    }

    // MARK: - Exit
    override func exit(_ state: EnemyState) {
        guard let enemy = enemy else { return }
        switch state {
        case .takingDamage:
            enemy.stopDamageEffect()
            enemy.sprite.removeAction(forKey: "damageAnimation")
        default:
            break
        }
    }

    // MARK: - Update
    override func updateState(_ state: EnemyState, deltaTime: CGFloat) {
        guard let enemy = enemy else { return }

        switch state {
        case .moving:
            let distance = enemy.position.distance(to: targetPosition)
            if distance <= enemy.attackRange {
                enter(.attacking)
            } else {
                enemy.move(deltaTime: deltaTime, targetPosition: targetPosition)
            }
        default:
            break
        }
    }
}
