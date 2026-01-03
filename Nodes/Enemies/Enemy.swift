import SpriteKit

class Enemy: SKNode {

    // MARK: - Properties
    let hitRadius: CGFloat
    var speedMultiplier: CGFloat
    let sprite: SKSpriteNode
    let frames: [SKTexture]
    var movementStyle: MovementStyle = .straight
    private var timeElapsed: CGFloat = 0
    var zigZagTime: CGFloat = 0
    private var forwardAnchor: CGPoint?
    let defaultSpriteColor: UIColor
    
    var maxHealth: CGFloat = 10
    var health: CGFloat = 10
    let healthBar: HealthBar
    
    private var isTakingDamage: Bool = false
    private var damageFlashTimer: CGFloat = 0
    private var flashRed: Bool = true
    private let flashDuration: CGFloat = 0.2
    
    var isInLightCone: Bool = false {
        didSet {
            if isInLightCone {
                startDamageEffect()
            } else {
                stopDamageEffect()
            }
        }
    }

    // MARK: - Initializer
    init(position: CGPoint,
         spriteSheetName: String,
         rowIndex: Int = 0,
         rows: Int = 1,
         columns: Int = 1,
         spriteSize: CGSize = CGSize(width: 80, height: 80),
         speedMultiplierRange: ClosedRange<CGFloat> = 0.8...1.3) {
        
        healthBar = HealthBar(maxHealth: maxHealth, size: CGSize(width: 40, height: 6))
        self.hitRadius = max(spriteSize.width, spriteSize.height) * 0.2
        self.speedMultiplier = CGFloat.random(in: speedMultiplierRange)

        // Load frames from sprite sheet
        let sheet = SKTexture(imageNamed: spriteSheetName)
        self.frames = Enemy.loadFramesFromSheet(sheet: sheet, rowIndex: rowIndex, rows: rows, columns: columns)

        self.sprite = SKSpriteNode(texture: frames[0])
        self.sprite.size = spriteSize
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.sprite.zPosition = 9
        
        defaultSpriteColor = self.sprite.color

        super.init()
        self.position = position
        addChild(sprite)
        
        healthBar.position = CGPoint(x: 0, y: sprite.size.height/2 + 8)
        addChild(healthBar)

        setupAnimation()
        setupPhysics(radius: hitRadius)
    }

    // MARK: - Animations
    private func setupAnimation() {
        guard sprite.action(forKey: "animation") == nil else { return }
        let animation = SKAction.animate(with: frames, timePerFrame: 0.1)
        sprite.run(SKAction.repeatForever(animation), withKey: "animation")
    }

    private func startDamageEffect() {
        guard !isTakingDamage else { return }
        isTakingDamage = true

        let flash = SKAction.sequence([
            SKAction.run { [weak self] in
                guard let s = self else { return }
                s.sprite.color = .red
                s.sprite.colorBlendFactor = 1.0
            },
            SKAction.wait(forDuration: 0.2),
            SKAction.run { [weak self] in
                guard let s = self else { return }
                s.sprite.color = .gray
                s.sprite.colorBlendFactor = 1.0
            },
            SKAction.wait(forDuration: 0.2)
        ])

        let repeatFlash = SKAction.repeatForever(flash)
        sprite.run(repeatFlash, withKey: "damageAnimation")
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
    func enterLight() {
        isInLightCone = true
    }

    func exitLight() {
        isInLightCone = false
    }

    // MARK: - Damage
    func takeDamage(_ amount: CGFloat) {
        health -= amount
        healthBar.takeDamage(amount)
        if health <= 0 { die() }
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
    
    func update(deltaTime: CGFloat) {
        // --- Damage flashing ---
//        print(isTakingDamage)
//        if isTakingDamage {
//            damageFlashTimer -= deltaTime
//            if damageFlashTimer <= 0 {
//                print(flashRed)
//                flashRed.toggle()
//                sprite.color = flashRed ? .red : .black
//                sprite.colorBlendFactor = 1.0
//                damageFlashTimer = flashDuration
//            }
//        }
    }

    // MARK: - Movement (placeholder)
    func moveTowardPlayer(playerPosition: CGPoint, baseSpeed: CGFloat, deltaTime: CGFloat, difficultyLevel: CGFloat) {
        // Implement movement later
    }

    // MARK: - Death
    private func die() {
        removeFromParent()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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

    static func testEnemiesOutOfConeLength(lightCone: LightCone, scene: GameScene, count: Int = 5) {
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
