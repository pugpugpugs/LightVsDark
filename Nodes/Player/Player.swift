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
    let healthBar: PlayerHealthBar

    // MARK: - Visuals
    let sprite: SKSpriteNode

    // MARK: - Weapon
    private(set) var weapon: PlayerWeapon?
    
    // MARK: - Animation
    let animationProvider: SpriteSheetAnimationProvider<PlayerState>
    
    // MARK: - State Machine
    lazy var stateMachine: PlayerStateMachine = {
        PlayerStateMachine(player: self, animationProvider: animationProvider)
    }()
    
    // MARK: - Callbacks

    // MARK: - Init
    init(position: CGPoint, stats: PlayerStats, playerPhysics: PlayerPhysics, animationProvider: SpriteSheetAnimationProvider<PlayerState>) {
        self.stats = stats
        self.hitPoints = stats.maxHealth
        
        self.animationProvider = animationProvider
        self.playerPhysics = playerPhysics
        
        self.sprite = SKSpriteNode(texture: nil, color: .white, size: playerPhysics.spriteSize)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.sprite.zPosition = 10
        
        self.healthBar = PlayerHealthBar(maxHP: stats.maxHealth)
        healthBar.position = CGPoint(x: 0, y: -playerPhysics.spriteSize.height / 2 - 10)
        
        super.init()
        self.position = position

        // Add visuals
        addChild(sprite)

        // Physics
        setupPhysics(body: playerPhysics.body)

        // Start in attacking state
        stateMachine.enter(.attacking)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Update Loop
    func update(deltaTime: CGFloat, inputDirection: CGFloat) {
        // --- Rotation ---
        updateRotation(deltaTime: deltaTime, inputDirection: inputDirection)
        
        // --- State Machine ---
        stateMachine.update(deltaTime: deltaTime)
        
        // --- Weapon ---
        weapon?.update(deltaTime: deltaTime)
    }

    // MARK: - Input / Rotation
    func applyInput(direction: CGFloat, deltaTime: CGFloat) {
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
        weapon?.node.zRotation = facingAngle
    }
    
    // MARK: - Weapon
    func equipWeapon(_ weapon: PlayerWeapon) {
        self.weapon = weapon
        weapon.owner = self
        addChild(weapon.node)
    }

    // MARK: - Damage
    func takeDamage(_ amount: Int = 1) {
        guard hitPoints > 0 else { return }
        hitPoints -= amount
        healthBar.update(hp: hitPoints)
        if hitPoints <= 0 {
            die()
        }
    }
    
    func die() {
        
    }
    
    // MARK: - Physics
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
