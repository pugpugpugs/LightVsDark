import SpriteKit

class LightCone: SKShapeNode {

    // MARK: - Properties
    var maxLength: CGFloat
    var minLength: CGFloat
    var currentLength: CGFloat
    var lengthShrinkRate: CGFloat

    var maxAngle: CGFloat
    var minAngle: CGFloat
    var currentAngle: CGFloat
    var angleShrinkRate: CGFloat

    // MARK: - Init
    init(screenSize: CGSize, desiredWidth: CGFloat = 0) {
        // Length
        self.maxLength = screenSize.height * 0.6
        self.minLength = 150
        self.currentLength = maxLength
        self.lengthShrinkRate = 2

        // Angle
        let width = desiredWidth > 0 ? desiredWidth : screenSize.height * 2
        let halfAngle = atan(width / (2 * maxLength))
        self.maxAngle = halfAngle * 2
        self.minAngle = .pi / 8
        self.currentAngle = maxAngle
        self.angleShrinkRate = maxAngle * 0.025

        super.init()

        self.fillColor = UIColor.yellow.withAlphaComponent(0.25)
        self.strokeColor = .clear
        self.zPosition = -1

        // Initial path + physics
        updatePathAndPhysics()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Update
    func update(deltaTime: CGFloat) {
        currentLength = max(currentLength - lengthShrinkRate * deltaTime, minLength)
        currentAngle = max(currentAngle - angleShrinkRate * deltaTime, minAngle)
        updatePathAndPhysics()
    }

    // MARK: - Path + Physics
    private func updatePathAndPhysics() {
        // Update the shape path
        let halfWidth = tan(currentAngle / 2) * currentLength
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: currentLength, y: -halfWidth))
        path.addLine(to: CGPoint(x: currentLength, y: halfWidth))
        path.closeSubpath()
        self.path = path

        // Update physics body to match shape
        self.physicsBody = SKPhysicsBody(polygonFrom: path)
        self.physicsBody?.categoryBitMask = PhysicsCategory.lightCone
        self.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.powerUp
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    // MARK: - Determines if spawn point is inside lightcone
    func containsPointWithPadding(_ point: CGPoint, padding: CGFloat) -> Bool {
        let offsets: [CGPoint] = [
            CGPoint(x: -padding, y: -padding),
            CGPoint(x: padding, y: -padding),
            CGPoint(x: -padding, y: padding),
            CGPoint(x: padding, y: padding),
        ]
        
        for offset in offsets {
            if self.contains(point + offset) {
                return true
            }
        }
        return false
    }
}
