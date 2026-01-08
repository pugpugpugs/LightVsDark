import SpriteKit

class PowerUp {
    let node: SKSpriteNode
    private let animationProvider: SpriteSheetAnimationProvider<PowerUpState>

    private(set) var state: PowerUpState = .idle {
        didSet { startAnimation() }
    }

    let type: PowerUpType

    // MARK: - Durations
    let pickupLifetime: TimeInterval   // how long it stays on the ground
    let warningTime: TimeInterval = 1.0
    let effectDuration: TimeInterval   // how long the effect lasts after pickup

    // MARK: - Runtime timestamps
    private var pickupExpirationTime: TimeInterval?
    private var effectEndTime: TimeInterval?

    // MARK: - Init
    init(
        type: PowerUpType,
        animationProvider: SpriteSheetAnimationProvider<PowerUpState>,
        size: CGSize,
        pickupLifetime: TimeInterval = 3.0,
        effectDuration: TimeInterval = 5.0
    ) {
        self.type = type
        self.animationProvider = animationProvider
        self.pickupLifetime = pickupLifetime
        self.effectDuration = effectDuration

        self.node = SKSpriteNode(texture: animationProvider.frames(for: .idle).first)
        self.node.size = size
        self.node.name = "powerUp"
        self.node.zPosition = 100
    }

    // MARK: - Spawn
    func addToScene(_ scene: SKNode, at position: CGPoint, currentTime: TimeInterval) {
        node.position = position
        scene.addChild(node)
        pickupExpirationTime = currentTime + pickupLifetime
        effectEndTime = nil
        state = .idle
    }

    // MARK: - Pickup
    func activate(currentTime: TimeInterval) {
        guard state != .collected else { return }

        state = .collected
        
        if effectDuration > 0 {
            effectEndTime = currentTime + effectDuration
        } else {
            effectEndTime = currentTime
        }
        
        pickupExpirationTime = nil
    }

    // MARK: - Update
    func update(currentTime: TimeInterval) {
        // Ground pickup expiration
        if let pickupEnd = pickupExpirationTime, state != .collected {
            let timeLeft = pickupEnd - currentTime
            if state == .idle && timeLeft <= warningTime {
                state = .expiring
            }
            if currentTime >= pickupEnd {
                despawn()
            }
        }
        
        // Effect expiration
        if let effectEnd = effectEndTime, currentTime >= effectEnd {
            despawn()
        }
    }

    // MARK: - Despawn
    private func despawn() {
        guard state != .despawning else { return }
        state = .despawning
    }

    // MARK: - Animation
    private func startAnimation() {
        node.removeAllActions()
        let frames = animationProvider.frames(for: state)
        guard !frames.isEmpty else { return }

        let animateOnce = SKAction.animate(with: frames, timePerFrame: 0.15)

        switch state {
        case .idle, .expiring:
            node.run(.repeatForever(animateOnce))
        case .collected:
            node.run(animateOnce) { [weak self] in
                if self?.effectDuration == 0 {
                    self?.despawn()
                }
            }
        case .despawning:
            node.run(animateOnce) { [weak self] in
                self?.node.removeFromParent()
            }
        }
    }
}
