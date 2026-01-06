import SpriteKit

class Player: SKNode {

    // MARK: - Stats & Physics
    let stats: PlayerStats
    let playerPhysics: PlayerPhysics
    
    // MARK: - Rotation / Movement
    private var spinSpeed: CGFloat = 0
    var facingAngle: CGFloat = 0
    var spinSpeedMultiplier: CGFloat = 1.0

    // MARK: - Health
    private(set) var hitPoints: Int

    // MARK: - Visuals
    let sprite: SKSpriteNode
    private(set) var lightCone: LightCone
    
    // MARK: - Animation
    let animationProvider: SpriteSheetAnimationProvider<PlayerState>
    
    // MARK: - State Machine
    lazy var stateMachine: PlayerStateMachine = {
        PlayerStateMachine(player: self, animationProvider: animationProvider)
    }()

    // MARK: - Init
    init(position: CGPoint, stats: PlayerStats, playerPhysics: PlayerPhysics, animationProvider: SpriteSheetAnimationProvider<PlayerState>) {
        self.stats = stats
        self.hitPoints = stats.maxHealth
        
        // Light Cone
        self.lightCone = LightCone()
        
        // Animation
        self.animationProvider = animationProvider
        
        // Sprite
        self.playerPhysics = playerPhysics
        self.sprite = SKSpriteNode(texture: nil, color: .white, size: playerPhysics.spriteSize)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.sprite.zPosition = 10
        
        super.init()
        self.position = position

        // Add visuals
        addChild(sprite)
        addChild(lightCone)

        // Physics
        setupPhysics(body: playerPhysics.body)
        stateMachine.enter(.attacking)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func update(deltaTime: CGFloat, inputDirection: CGFloat) {
        // --- Rotation ---
        updateRotation(deltaTime: deltaTime, inputDirection: inputDirection)
        
        // --- State machine ---
        stateMachine.update(deltaTime: deltaTime)
        
        // --- Light cone ---
        lightCone.update(deltaTime: deltaTime)
        lightCone.applyDamage(deltaTime: deltaTime)
        
        // --- Optional: other per-frame logic ---
    }

    // MARK: - Input / Rotation
    func applyInput(direction: CGFloat, deltaTime: CGFloat) {
        // direction: -1 = left, +1 = right, 0 = none
        spinSpeed += direction * stats.spinAcceleration * deltaTime
        spinSpeed = min(max(spinSpeed, -stats.maxSpinSpeed), stats.maxSpinSpeed)
    }

    func updateRotation(deltaTime: CGFloat, inputDirection: CGFloat) {
        applyInput(direction: inputDirection, deltaTime: deltaTime)

        // Gradually decay spin speed
        if spinSpeed > 0 {
            spinSpeed = max(spinSpeed - stats.spinDecay * deltaTime, 0)
        } else if spinSpeed < 0 {
            spinSpeed = min(spinSpeed + stats.spinDecay * deltaTime, 0)
        }

        // Update rotation
        facingAngle += spinSpeed * spinSpeedMultiplier * deltaTime
        zRotation = facingAngle
        lightCone.zRotation = facingAngle
    }

    // MARK: - Damage
    func takeDamage() {
        hitPoints -= 1
        print("Player damaged! HP: \(hitPoints)")
    }
    
    private func setupPhysics(body: SKPhysicsBody) {
        physicsBody = body
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
    }
}
