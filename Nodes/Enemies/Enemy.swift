import SpriteKit

// MARK: - Base Enemy Class
class Enemy: SKNode {

    // MARK: - Stats
    let stats: EnemyStats
    var health: CGFloat
    var speedMultiplier: CGFloat
    var currentSpeed: CGFloat {
        stats.baseSpeed * speedMultiplier
    }
    var attackRange: CGFloat
    let hitRadius: CGFloat

    // MARK: - Visuals
    let sprite: SKSpriteNode
    let healthBar: HealthBar
    let animationProvider: SpriteSheetAnimationProvider<EnemyState>
    private let defaultSpriteColor: UIColor

    // MARK: - State
    var isInLightCone: Bool = false { didSet { handleLightConeChange() } }
    lazy var stateMachine: EnemyStateMachine = {
        EnemyStateMachine(enemy: self, animationProvider: animationProvider)
    }()

    // MARK: - Callbacks
    var onDestroyed: (() -> Void)?
    var onAttackHit: (() -> Void)?

    // MARK: - Movement
    private let movementManager = MovementManager()
    var movementStyle: MovementStyle
    private(set) var timeElapsed: CGFloat = 0

    // MARK: - Init
    init(position: CGPoint,
         stats: EnemyStats,
         physics: EnemyPhysics,
         animationProvider: SpriteSheetAnimationProvider<EnemyState>,
         movementStyle: MovementStyle = .straight) {

        self.stats = stats
        self.health = stats.maxHealth
        self.speedMultiplier = CGFloat.random(in: stats.speedMultiplierRange)
        self.attackRange = stats.attackRange
        self.hitRadius = stats.hitRadius
        self.movementStyle = movementStyle

        // Sprite
        self.sprite = SKSpriteNode(texture: nil, color: .white, size: physics.spriteSize)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.sprite.zPosition = 9
        self.defaultSpriteColor = self.sprite.color

        // Health bar
        self.healthBar = HealthBar(maxHealth: stats.maxHealth, size: CGSize(width: physics.spriteSize.width / 2, height: 6))

        self.animationProvider = animationProvider

        super.init()
        self.position = position

        // Add visuals
        addChild(sprite)
        healthBar.position = CGPoint(x: 0, y: physics.spriteSize.height / 2 + 8)
        addChild(healthBar)

        // Physics
        setupPhysics(body: physics.body)

        // Initial state
        stateMachine.enter(.idle)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Update Loop
    func update(deltaTime: CGFloat, targetPosition: CGPoint) {
        timeElapsed += deltaTime
        stateMachine.targetPosition = targetPosition
        stateMachine.update(deltaTime: deltaTime)
    }

    // MARK: - Light Cone
    private func handleLightConeChange() {
        if isInLightCone {
            stateMachine.enter(.takingDamage)
        } else if stateMachine.currentState == .takingDamage {
            let nextState: EnemyState = position.distance(to: stateMachine.targetPosition) <= attackRange ? .attacking : .moving
            stateMachine.enter(nextState)
        }
    }

    func enterLight() { isInLightCone = true }
    func exitLight() { isInLightCone = false }

    // MARK: - Movement
    func move(deltaTime: CGFloat, targetPosition: CGPoint) {
        guard stateMachine.currentState == .moving else { return }
        guard position.distance(to: targetPosition) > attackRange else { return }
        let movement = movementManager.movementDelta(for: self, toward: targetPosition, deltaTime: deltaTime)
        position.x += movement.dx
        position.y += movement.dy
    }

    // MARK: - Attack
    func didFinishAttack() {
        onAttackHit?()
        destroy()
    }

    // MARK: - Damage
    func takeDamage(_ amount: CGFloat) {
        health -= amount
        healthBar.takeDamage(amount)
        if health <= 0 { stateMachine.enter(.dead) }
    }

    // MARK: - Damage Effects
    fileprivate var isTakingDamage: Bool = false
    fileprivate let flashDuration: CGFloat = 0.2

    func startDamageEffect() {
        guard !isTakingDamage else { return }
        isTakingDamage = true

        let flash = SKAction.sequence([
            SKAction.run { [weak self] in
                guard let s = self else { return }
                s.sprite.color = .red
                s.sprite.colorBlendFactor = 1.0
            },
            SKAction.wait(forDuration: flashDuration),
            SKAction.run { [weak self] in
                guard let s = self else { return }
                s.sprite.color = .gray
                s.sprite.colorBlendFactor = 1.0
            },
            SKAction.wait(forDuration: flashDuration)
        ])
        sprite.run(SKAction.repeatForever(flash), withKey: "damageAnimation")
    }

    func stopDamageEffect() {
        guard isTakingDamage else { return }
        isTakingDamage = false
        sprite.removeAction(forKey: "damageAnimation")
        sprite.color = defaultSpriteColor
        sprite.colorBlendFactor = 0
        sprite.blendMode = .alpha
    }

    // MARK: - Physics
    private func setupPhysics(body: SKPhysicsBody) {
        physicsBody = body
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.lightCone
        physicsBody?.collisionBitMask = 0
        physicsBody?.affectedByGravity = false
        physicsBody?.usesPreciseCollisionDetection = true
    }

    // MARK: - Death
    func die() {
        ScoreManager.shared.enemyKilled(basePoints: 10)
        destroy()
    }

    func destroy() {
        physicsBody = nil
        removeAllActions()
        removeFromParent()
        onDestroyed?()
    }
}
