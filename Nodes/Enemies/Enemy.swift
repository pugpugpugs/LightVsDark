import SpriteKit

class Enemy: SKNode {

    // MARK: - Properties
    let hitRadius: CGFloat
    let sprite: SKSpriteNode
    var timeElapsed: CGFloat = 0
    private var forwardAnchor: CGPoint?
    let defaultSpriteColor: UIColor
    
    var maxHealth: CGFloat = 10
    var health: CGFloat = 10
    let healthBar: HealthBar
    
    fileprivate var isTakingDamage: Bool = false
    fileprivate let flashDuration: CGFloat = 0.2
    
    var isInLightCone: Bool = false {
        didSet { handleLightConeChange() }
    }
    
    var baseSpeed: CGFloat = 35.0
    var speedMultiplier: CGFloat = 1.0
    private let movementManager = MovementManager()
    var movementStyle: MovementStyle
    private var movementTime: CGFloat = 0
    private var movementAnchor: CGPoint?
    
    var attackRange: CGFloat
    
    // MARK: - Animation Provider
    let animationProvider: SpriteSheetAnimationProvider
    
    // MARK: - State Machine
    lazy var stateMachine: EnemyStateMachine = {
        EnemyStateMachine(enemy: self, animationProvider: animationProvider)
    }()

    // MARK: - Init
    init(position: CGPoint,
         animationProvider: SpriteSheetAnimationProvider,
         movementStyle: MovementStyle = .straight,
         spriteSize: CGSize = CGSize(width: 80, height: 80),
         speedMultiplierRange: ClosedRange<CGFloat> = 0.8...1.3,
         attackRange: CGFloat) {

        // MARK: Health
        self.movementStyle = movementStyle
        self.maxHealth = 10
        self.health = maxHealth
        self.healthBar = HealthBar(maxHealth: maxHealth, size: CGSize(width: 40, height: 6))

        // MARK: Hit radius & speed
        self.hitRadius = max(spriteSize.width, spriteSize.height) * 0.2
        self.speedMultiplier = CGFloat.random(in: speedMultiplierRange)
        self.attackRange = attackRange

        // MARK: Sprite node
        self.sprite = SKSpriteNode(texture: nil)
        self.sprite.size = spriteSize
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.sprite.zPosition = 9
        self.defaultSpriteColor = self.sprite.color

        // MARK: AnimationProvider
        self.animationProvider = animationProvider

        super.init()

        self.position = position

        // Add sprite and health bar
        addChild(sprite)
        healthBar.position = CGPoint(x: 0, y: sprite.size.height / 2 + 8)
        addChild(healthBar)

        // Physics
        setupPhysics(radius: hitRadius)

        // Set initial state safely after everything is initialized
        stateMachine.enter(.idle)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Update Loop
    func update(deltaTime: CGFloat, targetPosition: CGPoint) {
        movementTime += deltaTime
        
        stateMachine.targetPosition = targetPosition
        stateMachine.update(deltaTime: deltaTime)
    }
    
    private func handleLightConeChange() {
        if isInLightCone {
            stateMachine.enter(.takingDamage)
        } else if stateMachine.currentState == .takingDamage {
            let nextState: EnemyState = position.distance(to: stateMachine.targetPosition) <= attackRange ? .attacking : .moving
            stateMachine.enter(nextState)
        }
    }
    
    // MARK: - Movement
    func move(deltaTime: CGFloat, targetPosition: CGPoint) {
        guard position.distance(to: targetPosition) > attackRange else { return }
        
        let movement = movementManager.movementDelta(for: self, toward: targetPosition, deltaTime: deltaTime)
        position.x += movement.dx
        position.y += movement.dy
    }
    
    func didFinishAttack() {
        destroy()
    }

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

    // MARK: - Light Cone Interaction
    func enterLight() { isInLightCone = true }
    func exitLight() { isInLightCone = false }

    // MARK: - Damage
    func takeDamage(_ amount: CGFloat) {
        health -= amount
        healthBar.takeDamage(amount)
        if health <= 0 { stateMachine.enter(.dead) }
    }

    // MARK: - Physics
    private func setupPhysics(radius: CGFloat) {
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.lightCone
        physicsBody?.collisionBitMask = 0
        physicsBody?.affectedByGravity = false
        physicsBody?.usesPreciseCollisionDetection = true
    }

    // MARK: - Death
    func destroy() {
        physicsBody = nil
        removeAllActions()
        removeFromParent()
        guard let scene = self.scene as? GameScene else { return }
        scene.enemies.removeAll { $0 === self }
        scene.player.lightCone?.enemiesInCone.remove(self)
    }
}
