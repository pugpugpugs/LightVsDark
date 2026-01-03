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
    
    var baseSpeed: CGFloat = 15.0
    var speedMultiplier: CGFloat = 1.0
    private let movementManager = MovementManager()
    var movementStyle: MovementStyle = .straight
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
         spriteSize: CGSize = CGSize(width: 80, height: 80),
         speedMultiplierRange: ClosedRange<CGFloat> = 0.8...1.3,
         attackRange: CGFloat) {

        // MARK: Health
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
        stateMachine.enter(.moving)
    }

    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Update Loop
    func update(deltaTime: CGFloat, targetPosition: CGPoint) {
        movementTime += deltaTime
        
        stateMachine.targetPosition = targetPosition
        stateMachine.update(deltaTime: deltaTime)
        
        updateStateCycleTest(deltaTime: deltaTime)
    }
    
    private func handleLightConeChange() {
        if isInLightCone {
            stateMachine.enter(.takingDamage)
        } else if stateMachine.currentState == .takingDamage {
            let nextState: EnemyState = position.distance(to: stateMachine.targetPosition) <= attackRange ? .idle : .moving
            stateMachine.enter(nextState)
        }
    }
    
    // MARK: - Test State Cycling
    private var testStateIndex = 0
    private var testStateTimer: CGFloat = 0
    
    func startStateCycleTest(interval: CGFloat = 2.0) {
        testStateIndex = 0
        testStateTimer = 0
    }
    
    func updateStateCycleTest(deltaTime: CGFloat) {
        testStateTimer += deltaTime
        guard testStateTimer >= 2.0 else { return } // 2 seconds per state
        testStateTimer = 0
        
        let states: [EnemyState] = [.idle, .moving, .takingDamage, .dead]
        let nextState = states[testStateIndex % states.count]
        stateMachine.enter(nextState)
        testStateIndex += 1
        print(nextState)
    }
    
    // MARK: - Movement
    func move(deltaTime: CGFloat, targetPosition: CGPoint) {
        guard position.distance(to: targetPosition) > attackRange else { return }
        
        let movement = movementManager.movementDelta(for: self, toward: targetPosition, deltaTime: deltaTime)
        position.x += movement.dx
        position.y += movement.dy
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
    func die() { removeFromParent() }

    // MARK: - Sprite Sheet Helper
    static func loadFramesFromSheet(sheet: SKTexture, rowIndex: Int, rows: Int, columns: Int) -> [SKTexture] {
        var frames: [SKTexture] = []
        let frameWidth = 1.0 / CGFloat(columns)
        let frameHeight = 1.0 / CGFloat(rows)

        for col in 0..<columns {
            let rect = CGRect(
                x: CGFloat(col) * frameWidth,
                y: CGFloat(rows - 1 - rowIndex) * frameHeight,
                width: frameWidth,
                height: frameHeight
            )
            frames.append(SKTexture(rect: rect, in: sheet))
        }
        return frames
    }

    // MARK: - Debug / Test Methods
    static func testEnemiesWithinConeLength(lightCone: LightCone, scene: GameScene, count: Int = 1) {
        guard let parent = lightCone.parent else { return }
        let coneTip = parent.convert(lightCone.position, to: scene)
        let radius = lightCone.currentLength

        for _ in 0..<count {
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = sqrt(CGFloat.random(in: 0...1)) * radius
            let x = coneTip.x + cos(angle) * distance
            let y = coneTip.y + sin(angle) * distance

            let enemy = EasyEnemy(position: CGPoint(x: x, y: y))
            scene.addChild(enemy)
            scene.enemies.append(enemy)
        }
    }

    static func testEnemiesOutOfConeLength(lightCone: LightCone, scene: GameScene, count: Int = 2) {
        guard let parent = lightCone.parent else { return }
        let coneTipWorld = parent.convert(lightCone.position, to: scene)
        let coneMaxWorldY = coneTipWorld.y + lightCone.currentLength + 20
        let maxY = scene.frame.maxY

        for _ in 0..<count {
            let x = CGFloat.random(in: scene.frame.minX...scene.frame.maxX)
            guard maxY > coneMaxWorldY else { continue }
            let y = CGFloat.random(in: coneMaxWorldY...maxY)
            let worldPos = CGPoint(x: x, y: y)

            let enemy = EasyEnemy(position: worldPos)
            scene.addChild(enemy)
            scene.enemies.append(enemy)
        }
    }

    static func testConeEnemies(lightCone: LightCone, scene: GameScene, count: Int = 3) {
        for _ in 0..<count {
            let yLocal = CGFloat.random(in: 0.1 * lightCone.currentLength ... 0.9 * lightCone.currentLength)
            let halfWidthAtY = lightCone.outerHalfWidth * (yLocal / lightCone.currentLength)
            let xLocal = CGFloat.random(in: -halfWidthAtY...halfWidthAtY)
            let localPoint = CGPoint(x: xLocal, y: yLocal)
            let scenePoint = lightCone.convert(localPoint, to: scene)

            let enemy = EasyEnemy(position: scenePoint)
            scene.addChild(enemy)
            scene.enemies.append(enemy)
        }
    }
}
