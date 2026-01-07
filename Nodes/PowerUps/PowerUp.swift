import SpriteKit

class PowerUp: SKShapeNode {

    let type: PowerUpType
    let duration: TimeInterval
    var expirationTime: TimeInterval?

    init(type: PowerUpType, duration: TimeInterval = 3.0, size: CGSize = CGSize(width: 40, height: 40)) {
        self.type = type
        self.duration = duration
        
        super.init()
        
        let radius = min(size.width, size.height) * 0.5
        let rect = CGRect(
            x: -radius,
            y: -radius,
            width: radius * 2,
            height: radius * 2
        )
        
        self.path = CGPath(ellipseIn: rect, transform: nil)
        
        self.fillColor = .green
        self.strokeColor = .clear
        self.zPosition = 5
        self.name = "powerUp"

        // Physics body for collision
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.isDynamic = true              // dynamic so contact fires
        self.physicsBody?.categoryBitMask = PhysicsCategory.powerUp
        self.physicsBody?.contactTestBitMask = PhysicsCategory.playerWeapon
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.usesPreciseCollisionDetection = true
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
