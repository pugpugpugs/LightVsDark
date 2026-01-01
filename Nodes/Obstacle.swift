import SpriteKit

class Obstacle: SKNode {

    // Old properties
    var speedMultiplier: CGFloat

    // Sprite / animation
    private let sprite: SKSpriteNode
    private let frames: [SKTexture]

    init(position: CGPoint, spriteSize: CGSize = CGSize(width: 80, height: 80)) {
        self.speedMultiplier = CGFloat.random(in: 0.8...1.3)

        // Load sprite sheet and slice frames (1 row x 8 columns)
        let sheet = SKTexture(imageNamed: "green_octonid")
        self.frames = Obstacle.loadFramesFromSheet(sheet: sheet, rowIndex: 0, rows: 5, columns: 8)
        
        // Create sprite
        self.sprite = SKSpriteNode(texture: frames[0])
        self.sprite.size = spriteSize
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5) // center anchor

        super.init()
        self.position = position
        self.name = "obstacle"
        addChild(sprite)

        // Animate sprite
        let animation = SKAction.animate(with: frames, timePerFrame: 0.1)
        sprite.run(SKAction.repeatForever(animation))

        setupPhysics(size: spriteSize)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupPhysics(size: CGSize) {
        // Use a circular physics body for roughly circular sprites
        let spriteCollisionSize = 0.2
        let radius = max(sprite.size.width, sprite.size.height) * spriteCollisionSize
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)

        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.lightCone
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.usesPreciseCollisionDetection = true
        
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

    // MARK: - Frame slicing for 1-row x N-columns sprite sheet
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
