import SpriteKit

class PowerUp {
    let node: SKSpriteNode
    private let animationProvider: SpriteSheetAnimationProvider<PowerUpState>
    private(set) var state: PowerUpState = .idle {
        didSet { startAnimation() }
    }
    let type: PowerUpType
    let duration: TimeInterval
    private(set) var pickupExpirationTime: TimeInterval?
    private(set) var effectExpirationTime: TimeInterval?

    init(type: PowerUpType,
         animationProvider: SpriteSheetAnimationProvider<PowerUpState>,
         size: CGSize,
         duration: TimeInterval,
         pickupExpirationTime: TimeInterval = 3.0,
         effectExpirationTime: TimeInterval = 5.0) {
        self.type = type
        self.animationProvider = animationProvider
        self.node = SKSpriteNode(texture: animationProvider.frames(for: .idle).first)
        self.node.size = size
        self.node.name = "powerUp"
        self.node.zPosition = 100
        self.duration = duration
        self.effectExpirationTime = effectExpirationTime
        self.pickupExpirationTime = pickupExpirationTime
    }

    func addToScene(_ scene: SKNode, at position: CGPoint, currentTime: TimeInterval) {
        print("adding to scene")
        node.position = position
        scene.addChild(node)
        state = .idle
        pickupExpirationTime = currentTime + duration
    }

    private func startAnimation() {
        print("animationg \(state)")
        node.removeAllActions()
        let frames = animationProvider.frames(for: state)
        guard !frames.isEmpty else { return }

        switch state {
        case .idle, .expiring:
            let action = SKAction.repeatForever(.animate(with: frames, timePerFrame: 0.15))
            node.run(action)
        case .collected:
            let action = SKAction.animate(with: frames, timePerFrame: 0.15)
            node.run(action) { [weak self] in
                self?.deactivate()
            }
        case .despawning:
            let action = SKAction.animate(with: frames, timePerFrame: 0.15)
            node.run(action) { [weak self] in
                self?.node.removeFromParent()
            }
        }
    }

    func activate(currentTime: TimeInterval) {
        guard state != .collected else { return }
        
        state = .collected
        effectExpirationTime = currentTime + duration
        pickupExpirationTime = nil
    }

    func deactivate() {
        // Only run despawning if not already despawning
        guard state != .despawning else { return }

        state = .despawning
        pickupExpirationTime = nil
        effectExpirationTime = nil

        // Run the animation once, then remove the node
        let frames = animationProvider.frames(for: .despawning)
        guard !frames.isEmpty else {
            node.removeFromParent()
            return
        }

        let animation = SKAction.animate(with: frames, timePerFrame: 0.15)
        node.run(animation) { [weak self] in
            self?.node.removeFromParent()
        }
    }

    func update(currentTime: TimeInterval) {
        // --- Pickup expiration ---
        if let pickupEnd = pickupExpirationTime {
            let timeLeft = pickupEnd - currentTime
            if state == .idle && timeLeft <= 1.0 {
                state = .expiring
            }
            if currentTime >= pickupEnd {
                state = .despawning
                pickupExpirationTime = nil
            }
        }

        // --- Effect expiration ---
        if let effectEnd = effectExpirationTime, currentTime >= effectEnd {
            state = .despawning
            effectExpirationTime = nil
        }
    }

    func isExpired(currentTime: TimeInterval) -> Bool {
        guard let expiration = effectExpirationTime else { return false }
        return currentTime >= expiration
    }
}
