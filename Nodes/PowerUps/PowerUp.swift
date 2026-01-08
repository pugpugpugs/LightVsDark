import SpriteKit

class PowerUp {
    let node: SKSpriteNode
    private let animationProvider: SpriteSheetAnimationProvider<PowerUpState>
    
    private(set) var state: PowerUpState = .idle {
        didSet { startAnimation() }
    }
    
    let type: PowerUpType
    
    // MARK: - Durations
    let pickupLifetime: TimeInterval      // time on ground
    let warningTime: TimeInterval = 1.0  // last second flashes
    let effectDuration: TimeInterval     // how long effect lasts, 0 for instant
    
    // MARK: - Runtime
    private var pickupEndTime: TimeInterval?
    private var effectEndTime: TimeInterval?
    
    // Optional callback to notify manager when despawning finished
    var onRemoved: (() -> Void)?
    
    init(type: PowerUpType,
         animationProvider: SpriteSheetAnimationProvider<PowerUpState>,
         size: CGSize,
         pickupLifetime: TimeInterval = 3.0,
         effectDuration: TimeInterval = 5.0) {
        
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
        pickupEndTime = currentTime + pickupLifetime
        effectEndTime = nil
        state = .idle
    }
    
    // MARK: - Pickup / Activate
    func activate(currentTime: TimeInterval) {
        guard state != .collected else { return }
        
        state = .collected
        
        if effectDuration > 0 {
            effectEndTime = currentTime + effectDuration
        } else {
            // Instant → immediately schedule despawn
            effectEndTime = currentTime
        }
        
        // Once collected, pickup timer is irrelevant
        pickupEndTime = nil
    }
    
    // MARK: - Update (called every frame)
    func update(currentTime: TimeInterval) {
        // Check pickup expiration
        if let pickupEnd = pickupEndTime, state == .idle || state == .expiring {
            let timeLeft = pickupEnd - currentTime
            if timeLeft <= 1.0 { state = .expiring }
            if currentTime >= pickupEnd { despawn() }
        }

        // Check effect expiration
        if let effectEnd = effectEndTime, state == .collected {
            if currentTime >= effectEnd { despawn() }
        }
    }
    
    // MARK: - Schedule despawn
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
        case .collected, .despawning:
            node.run(animateOnce) { [weak self] in
                self?.onRemoved?()
            }
        }
    }
}
