import SpriteKit

class PlayerStateMachine: StateMachine<PlayerState> {

    weak var player: Player?
    let animationProvider: SpriteSheetAnimationProvider<PlayerState>
    
    private var stateAnimations: [PlayerState: SKAction] = [:]

    init(player: Player, animationProvider: SpriteSheetAnimationProvider<PlayerState>) {
        self.player = player
        self.animationProvider = animationProvider
        super.init(initialState: .none)
        
        super.enter(.attacking)
    }
    
    override func setupAnimations() {
        for state in [PlayerState.attacking, .dead] {
            let frames = animationProvider.frames(for: state)
            guard !frames.isEmpty else { continue }

            let action: SKAction
            // One-shot vs looping
            if state == .dead {
                action = SKAction.animate(with: frames, timePerFrame: 0.2)
            } else {
                action = SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 0.2))
            }

            stateAnimations[state] = action
        }
    }
    
    override func enterState(_ state: PlayerState) {
        guard let player = player else { return }

        // Other state-specific behavior
        switch state {
        case .attacking:
            if let anim = stateAnimations[.attacking] {
                player.sprite.run(anim, withKey: "attackAnimation")
            }
        case .dead:
            if let anim = stateAnimations[.dead] {
                player.sprite.run(anim, withKey: "deadAnimation")
            }
        default:
            break
        }
    }
}
