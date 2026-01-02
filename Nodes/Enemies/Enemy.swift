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
    
    var maxHealth: CGFloat = 3
    var health: CGFloat = 10


    // Base initializer
    init(position: CGPoint,
         spriteSheetName: String,
         rowIndex: Int = 0,
         rows: Int = 1,
         columns: Int = 1,
         spriteSize: CGSize = CGSize(width: 80, height: 80),
         speedMultiplierRange: ClosedRange<CGFloat> = 0.8...1.3) {

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

        super.init()
        self.position = position
        addChild(sprite)

        // Animate sprite
        let animation = SKAction.animate(with: frames, timePerFrame: 0.1)
        sprite.run(SKAction.repeatForever(animation))

        setupPhysics(radius: hitRadius)
    }
    
    func takeDamage(_ amount: CGFloat) {
        health -= amount
        return
        if health <= 0 {
            die()
        }
    }
    
    static func testEnemiesWithinConeLength(
        lightCone: LightCone,
        scene: SKScene,
        count: Int = 5
    ) {
        var testEnemies: [Enemy] = []

        guard let parent = lightCone.parent else { return }

        // Cone tip in scene space
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

            // Debug dot
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

        // Cone tip in world space
        let coneTipWorld = parent.convert(lightCone.position, to: scene)

        // Cone maximum forward Y (include any arc if needed)
        let coneMaxWorldY = coneTipWorld.y + lightCone.currentLength + 20

        // The top of the screen
        let maxY = scene.frame.maxY

        for _ in 0..<count {
            // Random X anywhere on screen
            let x = CGFloat.random(in: scene.frame.minX ... scene.frame.maxX)

            // Random Y above coneMaxWorldY, but clamp to screen
            guard maxY > coneMaxWorldY else {
                print("Screen too small to spawn enemies outside cone")
                continue
            }

            let y = CGFloat.random(in: coneMaxWorldY ... maxY)

            let worldPos = CGPoint(x: x, y: y)

            let enemy = EasyEnemy(position: worldPos)
            testEnemies.append(enemy)
            scene.addChild(enemy)
        }

        scene.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run { lightCone.applyDamage(deltaTime: 1/60, enemies: testEnemies) },
                    SKAction.wait(forDuration: 1/60)
                ])
            )
        )
    }



    
    static func testConeEnemies(lightCone: LightCone, scene: SKScene, count: Int = 3) {
        var testEnemies: [Enemy] = []

        for _ in 0..<count {
            // Pick a random Y within the cone length (local space)
            let yLocal = CGFloat.random(in: 0.1 * lightCone.currentLength
                                             ... 0.9 * lightCone.currentLength)

            // Compute outer width at that Y
            let halfWidthAtY = lightCone.outerHalfWidth * (yLocal / lightCone.currentLength)

            // Pick a random X within cone bounds (local space)
            let xLocal = CGFloat.random(in: -halfWidthAtY...halfWidthAtY)

            // Local cone-space position
            let localPoint = CGPoint(x: xLocal, y: yLocal)

            // 🔑 Convert to scene space
            let scenePoint = lightCone.convert(localPoint, to: scene)

            // Spawn enemy in scene space
            let enemy = EasyEnemy(position: scenePoint)
            testEnemies.append(enemy)
            scene.addChild(enemy)

            // Debug marker
            let debugDot = SKShapeNode(circleOfRadius: 4)
            debugDot.fillColor = .red
            debugDot.position = scenePoint
            debugDot.zPosition = 100
            scene.addChild(debugDot)
        }

        // Test damage loop
        let testAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run {
                    lightCone.applyDamage(deltaTime: 1 / 60, enemies: testEnemies)
                },
                SKAction.wait(forDuration: 1 / 60)
            ])
        )

        scene.run(testAction)
    }

    
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
        let dx = playerPosition.x - position.x
        let dy = playerPosition.y - position.y
        let distance = sqrt(dx*dx + dy*dy)
        guard distance > 0 else { return }

        // Initialize forward anchor if needed
        if forwardAnchor == nil {
            forwardAnchor = position
        }

        // Move forward toward player
        let forwardVelocity = baseSpeed * speedMultiplier * deltaTime
        let forwardX = dx / distance * forwardVelocity
        let forwardY = dy / distance * forwardVelocity
        forwardAnchor!.x += forwardX
        forwardAnchor!.y += forwardY

        var finalX = forwardAnchor!.x
        var finalY = forwardAnchor!.y

        // Update zigzag time
        zigZagTime += deltaTime

        // Zigzag movement
        switch movementStyle {
        case .zigZag(let baseAmplitude, let baseFrequency):
            // Scale slightly with difficulty
            let adjustedAmplitude = baseAmplitude * (0.5 + 0.05 * difficultyLevel)
            let adjustedFrequency = min(baseFrequency * (0.8 + 0.02 * difficultyLevel), 2.5) // max 2.5 Hz

            let sideOffset = sin(zigZagTime * adjustedFrequency * 2 * .pi) * adjustedAmplitude

            // Perpendicular to forward movement
            let perpX = -dy / distance
            let perpY = dx / distance

            finalX += perpX * sideOffset
            finalY += perpY * sideOffset
        default: break
        }

        position = CGPoint(x: finalX, y: finalY)
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
