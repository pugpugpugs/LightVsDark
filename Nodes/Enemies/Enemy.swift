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
