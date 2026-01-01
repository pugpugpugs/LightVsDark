import SpriteKit

class Player: SKShapeNode {

    // MARK: - Configuration
    let radius: CGFloat = 25
    let anglePerZone: CGFloat = .pi / 3  // 6 zones = 60 degrees

    // Rotation properties
    private var spinSpeed: CGFloat = 0
    let maxSpinSpeed: CGFloat = .pi       // radians/sec
    let spinAcceleration: CGFloat = .pi * 4
    let spinDecay: CGFloat = 6.0
    var facingAngle: CGFloat = 0

    // Light cone
    private(set) var lightCone: LightCone?
    
    private var debugZones: [SKShapeNode] = []
    private var zoneCount: Int = 6

    // MARK: - Init
    init(position: CGPoint, screenSize: CGSize) {
        super.init()
        self.position = position
        
        let radius: CGFloat = 25
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius*2, height: radius*2), transform: nil)
        self.fillColor = .white
        self.strokeColor = .clear
        self.glowWidth = 5

        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.categoryBitMask = PhysicsCategory.player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false

        lightCone = LightCone(screenSize: screenSize)
        if let cone = lightCone {
            addChild(cone)
        }
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Input / Rotation
    func applyInput(direction: CGFloat, deltaTime: CGFloat) {
        // direction: -1 = left, +1 = right, 0 = none
        spinSpeed += direction * spinAcceleration * deltaTime
        spinSpeed = min(max(spinSpeed, -maxSpinSpeed), maxSpinSpeed)
    }

    func updateRotation(deltaTime: CGFloat, inputDirection: CGFloat) {
        applyInput(direction: inputDirection, deltaTime: deltaTime)
        
        // Gradually decay spin speed
        if spinSpeed > 0 {
            spinSpeed = max(spinSpeed - spinDecay * deltaTime, 0)
        } else if spinSpeed < 0 {
            spinSpeed = min(spinSpeed + spinDecay * deltaTime, 0)
        }

        // Update rotation
        facingAngle += spinSpeed * deltaTime
        zRotation = facingAngle
        lightCone?.zRotation = facingAngle
    }

    // MARK: - Debug Zones
    func addDebugZones(to scene: SKScene) {
        debugZones.forEach { $0.removeFromParent() }
        debugZones.removeAll()
        let halfWidth = 220 * tan(anglePerZone / 2) // max cone length = 220

        for i in 0..<zoneCount {
            let zone = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: 220, y: -halfWidth))
            path.addLine(to: CGPoint(x: 220, y: halfWidth))
            path.closeSubpath()
            zone.path = path

            zone.fillColor = UIColor(hue: CGFloat(i)/CGFloat(zoneCount), saturation: 0.6, brightness: 0.9, alpha: 0.2)
            zone.strokeColor = .clear
            zone.position = self.position
            zone.zRotation = CGFloat(i) * anglePerZone
            scene.addChild(zone)
            debugZones.append(zone)
        }
    }
}
