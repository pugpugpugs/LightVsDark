import SpriteKit

class Enemy: SKNode {

    // Shared properties
    let hitRadius: CGFloat
    
    var speedMultiplier: CGFloat
    let sprite: SKSpriteNode
    let frames: [SKTexture]
    var movementStyle: MovementStyle = .straight
    private var timeElapsed: CGFloat = 0
    var zigZagTime: CGFloat = 0
    private var forwardAnchor: CGPoint?
    
    var maxHealth: CGFloat = 10
    var health: CGFloat = 10
    let healthBar: HealthBar
    var isTakingDamage: Bool = false

    // Base initializer
    init(position: CGPoint,
         spriteSheetName: String,
         rowIndex: Int = 0,
         rows: Int = 1,
         columns: Int = 1,
         spriteSize: CGSize = CGSize(width: 80, height: 80),
         speedMultiplierRange: ClosedRange<CGFloat> = 0.8...1.3) {
        
        healthBar = HealthBar(maxHealth: maxHealth, size: CGSize(width: 40, height: 6))

        let spriteCollisionSize = 0.2
        self.hitRadius = max(spriteSize.width, spriteSize.height) * spriteCollisionSize
        
        self.speedMultiplier = CGFloat.random(in: speedMultiplierRange)

        // Load sprite sheet and slice frames
        let sheet = SKTexture(imageNamed: spriteSheetName)
        self.frames = Enemy.loadFramesFromSheet(sheet: sheet, rowIndex: rowIndex, rows: rows, columns: columns)

        // Create sprite node
        self.sprite = SKSpriteNode(texture: frames[0])
        self.sprite.size = spriteSize
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.sprite.zPosition = 9

        super.init()
        self.position = position
        addChild(sprite)
        
        healthBar.position = CGPoint(x: 0, y: sprite.size.height/2 + 8)
        addChild(healthBar)

        // Setup normal animation
        setupAnimation()

        setupPhysics(radius: hitRadius)
    }
    
    private func setupAnimation() {
        // Base animation (idle/movement)
        guard sprite.action(forKey: "animation") == nil else { return }
        let animation = SKAction.animate(with: frames, timePerFrame: 0.1)
        sprite.run(SKAction.repeatForever(animation), withKey: "animation")
    }
    
    func takeDamage(_ amount: CGFloat) {
        health -= amount
        healthBar.takeDamage(amount)

        if !isTakingDamage {
            isTakingDamage = true
            playDamageAnimation()
        }

        if health <= 0 {
            die()
        }
    }
    
    // MARK: - Damage Animation (replaces color flicker)
    private func playDamageAnimation() {
        // Only start if not already running
        guard sprite.action(forKey: "damageAnimation") == nil else { return }

        // Create a "damage sequence" animation using the same frames
        let damageFrames: [SKTexture] = frames
        let damageAnimation = SKAction.animate(with: damageFrames, timePerFrame: 0.1)

        // Loop animation while taking damage
        let repeatDamage = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { [weak self] in
                    guard let s = self else { return }
                    s.sprite.color = .red
                    s.sprite.colorBlendFactor = 1.0
                },
                damageAnimation,
                SKAction.run { [weak self] in
                    guard let s = self else { return }
                    s.sprite.color = .white
                    s.sprite.colorBlendFactor = 1.0
                }
            ])
        )

        sprite.run(repeatDamage, withKey: "damageAnimation")
    }

    func stopDamageEffect() {
        isTakingDamage = false
        sprite.removeAction(forKey: "damageAnimation")
        sprite.colorBlendFactor = 0
        // Restore normal animation
        setupAnimation()
    }

    // MARK: - Test Spawns
    static func testEnemiesWithinConeLength(
        lightCone: LightCone,
        scene: SKScene,
        count: Int = 5
    ) {
        var testEnemies: [Enemy] = []

        guard let parent = lightCone.parent else { return }

        let coneTip = parent.convert(lightCone.position, to: scene)
        let radius = lightCone.currentLength

        for _ in 0..<count {
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = sqrt(CGFloat.random(in: 0...1)) * radius

            let x = coneTip.x + cos(angle) * distance
            let y = coneTip.y + sin(angle) * distance

            let enemy = EasyEnemy(position: CGPoint(x: x, y: y))
            testEnemies.append(enemy)
            scene.addChild(enemy)

            let dot = SKShapeNode(circleOfRadius: 4)
            dot.fillColor = .red
            dot.position = CGPoint(x: x, y: y)
            dot.zPosition = 100
            scene.addChild(dot)
        }

        scene.run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { lightCone.applyDamage(deltaTime: 1/60, enemies: testEnemies) },
                SKAction.wait(forDuration: 1 / 60)
            ])
        ))
    }

    static func testEnemiesOutOfConeLength(
        lightCone: LightCone,
        scene: SKScene,
        count: Int = 5
    ) {
        var testEnemies: [Enemy] = []

        guard let parent = lightCone.parent else { return }

        let coneTipWorld = parent.convert(lightCone.position, to: scene)
        let coneMaxWorldY = coneTipWorld.y + lightCone.currentLength + 20
        let maxY = scene.frame.maxY

        for _ in 0..<count {
            let x = CGFloat.random(in: scene.frame.minX ... scene.frame.maxX)
            guard maxY > coneMaxWorldY else { continue }
            let y = CGFloat.random(in: coneMaxWorldY ... maxY)

            let worldPos = CGPoint(x: x, y: y)
            let enemy = EasyEnemy(position: worldPos)
            testEnemies.append(enemy)
            scene.addChild(enemy)
        }

        scene.run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { lightCone.applyDamage(deltaTime: 1/60, enemies: testEnemies) },
                SKAction.wait(forDuration: 1/60)
            ])
        ))
    }

    static func testConeEnemies(lightCone: LightCone, scene: SKScene, count: Int = 3) {
        var testEnemies: [Enemy] = []

        for _ in 0..<count {
            let yLocal = CGFloat.random(in: 0.1 * lightCone.currentLength ... 0.9 * lightCone.currentLength)
            let halfWidthAtY = lightCone.outerHalfWidth * (yLocal / lightCone.currentLength)
            let xLocal = CGFloat.random(in: -halfWidthAtY...halfWidthAtY)
            let localPoint = CGPoint(x: xLocal, y: yLocal)
            let scenePoint = lightCone.convert(localPoint, to: scene)

            let enemy = EasyEnemy(position: scenePoint)
            testEnemies.append(enemy)
            scene.addChild(enemy)

            let debugDot = SKShapeNode(circleOfRadius: 4)
            debugDot.fillColor = .red
            debugDot.position = scenePoint
            debugDot.zPosition = 100
            scene.addChild(debugDot)
        }

        let testAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { lightCone.applyDamage(deltaTime: 1 / 60, enemies: testEnemies) },
                SKAction.wait(forDuration: 1 / 60)
            ])
        )
        scene.run(testAction)
    }

    // MARK: - Base methods
    private func die() {
        removeFromParent()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupPhysics(radius: CGFloat) {
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.lightCone
        physicsBody?.collisionBitMask = 0
        physicsBody?.affectedByGravity = false
        physicsBody?.usesPreciseCollisionDetection = true
    }

    func moveTowardPlayer(playerPosition: CGPoint, baseSpeed: CGFloat, deltaTime: CGFloat, difficultyLevel: CGFloat) {
        return
    }

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
}
