import SpriteKit

class Enemy: SKNode {

    // Shared properties
    var speedMultiplier: CGFloat
    let sprite: SKSpriteNode
    let frames: [SKTexture]

    // Base initializer
    init(position: CGPoint,
         spriteSheetName: String,
         rowIndex: Int = 0,
         rows: Int = 1,
         columns: Int = 1,
         spriteSize: CGSize = CGSize(width: 80, height: 80),
         speedMultiplierRange: ClosedRange<CGFloat> = 0.8...1.3) {

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

        setupPhysics(size: spriteSize)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupPhysics(size: CGSize) {
        let spriteCollisionSize = 0.2
        let radius = max(size.width, size.height) * spriteCollisionSize

        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.lightCone
        physicsBody?.collisionBitMask = 0
        physicsBody?.affectedByGravity = false
        physicsBody?.usesPreciseCollisionDetection = true

        #if DEBUG
        let shape = SKShapeNode(circleOfRadius: radius)
        shape.strokeColor = .green
        shape.lineWidth = 2
        shape.zPosition = 10
        addChild(shape)
        #endif
    }

    func moveTowardPlayer(playerPosition: CGPoint, baseSpeed: CGFloat, deltaTime: CGFloat) {
        let dx = playerPosition.x - position.x
        let dy = playerPosition.y - position.y
        let distance = sqrt(dx*dx + dy*dy)
        guard distance > 0 else { return }
        let velocity = baseSpeed * speedMultiplier * deltaTime
        position.x += dx / distance * velocity
        position.y += dy / distance * velocity
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
