import SpriteKit

class LightCone: SKNode {

    private let angle: CGFloat       // Full cone angle in radians
    private let maxLength: CGFloat
    private let minLength: CGFloat
    private let shrinkRate: CGFloat
    private let color: SKColor

    private var currentLength: CGFloat
    private let shapeNode: SKShapeNode

    init(angle: CGFloat = .pi/3, length: CGFloat = 220, minLength: CGFloat = 120, shrinkRate: CGFloat = 5, color: SKColor = .yellow) {
        self.angle = angle
        self.maxLength = length
        self.minLength = minLength
        self.currentLength = length
        self.shrinkRate = shrinkRate
        self.color = color
        self.shapeNode = SKShapeNode()
        super.init()
        setupCone()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCone() {
        updatePath()
        shapeNode.fillColor = color.withAlphaComponent(0.25)
        shapeNode.strokeColor = .clear
        shapeNode.zPosition = -1
        addChild(shapeNode)
        
        updatePath()
    }

    private func updatePath() {
        let halfWidth = tan(angle / 2) * currentLength
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: currentLength, y: -halfWidth))
        path.addLine(to: CGPoint(x: currentLength, y: halfWidth))
        path.closeSubpath()
        shapeNode.path = path

        // Use physics body attached to shapeNode
        shapeNode.physicsBody = SKPhysicsBody(polygonFrom: path)
        shapeNode.physicsBody?.isDynamic = true
        shapeNode.physicsBody?.categoryBitMask = PhysicsCategory.lightCone
        shapeNode.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle
        shapeNode.physicsBody?.collisionBitMask = 0
    }


    // Shrink over time
    func updateLength(deltaTime: CGFloat) {
        currentLength = max(currentLength - shrinkRate * deltaTime, minLength)
        updatePath()
    }

    func resetLength(deltaTime: CGFloat) {
        currentLength = max(currentLength - shrinkRate * deltaTime, minLength)
        updatePath()
    }
}
