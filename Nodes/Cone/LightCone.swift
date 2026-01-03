import SpriteKit

class LightCone: SKShapeNode {
    
    // MARK: - Properties
    let baseLength: CGFloat
    let baseAngle: CGFloat
    
    private(set) var currentLength: CGFloat
    private(set) var currentAngle: CGFloat
    
    private var targetLength: CGFloat
    private var targetAngle: CGFloat
    
    // DPS
    var baseDPS: CGFloat = 1
    private let innerMultiplier: CGFloat = 2.5
    private let middleMultiplier: CGFloat = 1.0
    private let outerMultiplier: CGFloat = 0.5
    
    // Half-widths
    private(set) var innerHalfWidth: CGFloat = 0
    private(set) var middleHalfWidth: CGFloat = 0
    private(set) var outerHalfWidth: CGFloat = 0
    
    // Overlays for visualization
    private let innerOverlay = SKShapeNode()
    private let middleOverlay = SKShapeNode()
    private let outerOverlay = SKShapeNode()
    
    let damageTickInterval: TimeInterval = 0.15
    
    var enemiesInCone: Set<Enemy> = []
    
    // MARK: - Init
    init(baseLength: CGFloat = 150, baseAngle: CGFloat = .pi / 3) {
        self.baseLength = baseLength
        self.baseAngle = baseAngle
        self.currentLength = baseLength
        self.currentAngle = baseAngle
        self.targetLength = baseLength
        self.targetAngle = baseAngle
        
        super.init()
        
        fillColor = UIColor.yellow.withAlphaComponent(0.1)
        strokeColor = .clear
        zPosition = -1
        
        setupOverlays()
        updateHalfWidths()
        updatePathAndPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    // MARK: - Overlays setup
    private func setupOverlays() {
        // Colors for zones
        let innerColor  = UIColor(red: 1.0, green: 0.45, blue: 0.0, alpha: 0.75)
        let middleColor = UIColor(red: 1.0, green: 0.65, blue: 0.1, alpha: 0.75)
        let outerColor  = UIColor(red: 1.0, green: 1.0,  blue: 0.2, alpha: 0.75)

        func addOverlay(_ overlay: SKShapeNode, color: UIColor, blurRadius: CGFloat) {
            overlay.fillColor = color
            overlay.strokeColor = .clear
            overlay.zPosition = 0

            // Use SKEffectNode for blur
            let glow = SKEffectNode()
            glow.shouldRasterize = true
            glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": blurRadius])
            glow.addChild(overlay)
            addChild(glow)
        }

        // Add overlays from outer → inner so the inner is on top
        addOverlay(outerOverlay, color: outerColor, blurRadius: 4)
        addOverlay(middleOverlay, color: middleColor, blurRadius: 3)
        addOverlay(innerOverlay, color: innerColor, blurRadius: 2)
    }
    
    // MARK: - Update half-widths
    private func updateHalfWidths() {
        innerHalfWidth  = tan(currentAngle / 18) * currentLength
        middleHalfWidth = tan(currentAngle / 4) * currentLength
        outerHalfWidth  = tan(currentAngle / 2) * currentLength
    }
    
    private func pathForZone(halfWidth: CGFloat, zoneMultiplier: CGFloat = 1.0) -> CGPath {
        let path = CGMutablePath()
        let tip = CGPoint(x: 0, y: 0)
        let baseY = currentLength

        let steps = 20
        let arcHeight: CGFloat = 20 * zoneMultiplier  // scale per zone

        path.move(to: tip)

        let leftX = -halfWidth
        let rightX = halfWidth

        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let x = leftX + t * (rightX - leftX)

            // Normalize relative to outer cone
            let normalizedX = x / outerHalfWidth
            let clampedX = min(max(normalizedX, -1), 1)

            let yOffset = sin((clampedX + 1) * .pi / 2) * arcHeight
            path.addLine(to: CGPoint(x: x, y: baseY + yOffset))
        }

        path.addLine(to: tip)
        path.closeSubpath()
        return path
    }


    private func updatePathAndPhysics() {
        updateHalfWidths()

        // Outer = full width
        let outerPath = pathForZone(halfWidth: outerHalfWidth)
        self.path = outerPath
        outerOverlay.path  = outerPath

        // Middle = scaled
        middleOverlay.path = pathForZone(halfWidth: middleHalfWidth)

        // Inner = scaled
        innerOverlay.path  = pathForZone(halfWidth: innerHalfWidth)
        
        if physicsBody == nil {
            physicsBody = SKPhysicsBody(polygonFrom: outerPath)
            physicsBody?.categoryBitMask = PhysicsCategory.lightCone
            physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.powerUp
            physicsBody?.collisionBitMask = 0
            physicsBody?.isDynamic = false
            physicsBody?.affectedByGravity = false
            physicsBody?.usesPreciseCollisionDetection = true
        }
    }
    
    // MARK: - Update per frame
    func update(deltaTime: CGFloat) {
        let lerpFactor: CGFloat = 0.1
        currentLength += (targetLength - currentLength) * lerpFactor
        currentAngle += (targetAngle - currentAngle) * lerpFactor
        
        updatePathAndPhysics()
    }
    
    func enemyEnteredCone(_ enemy: Enemy) {
        enemiesInCone.insert(enemy)
        enemy.enterLight()
    }

    func enemyExitedCone(_ enemy: Enemy) {
        enemiesInCone.remove(enemy)
        enemy.exitLight()
    }
    
    func applyDamage(deltaTime: CGFloat) {
        let baseDamage = baseDPS * deltaTime

        for enemy in enemiesInCone {
            guard let enemyParent = enemy.parent else { continue }

            // Convert enemy position to cone's local space
            let localPos = convert(enemy.position, from: enemyParent)
            let x = localPos.x
            let y = localPos.y

            // Check Y (cone length)
            if y < 0 || y > currentLength {
                continue
            }

            // Compute half-widths at this Y
            let innerWidthAtY  = innerHalfWidth  * (y / currentLength)
            let middleWidthAtY = middleHalfWidth * (y / currentLength)
            let outerWidthAtY  = outerHalfWidth  * (y / currentLength)

            // Determine zone based on X
            let zone: String
            let multiplier: CGFloat
            let absX = abs(x)

            if absX <= innerWidthAtY {
                zone = "INNER"
                multiplier = innerMultiplier
            } else if absX <= middleWidthAtY {
                zone = "MIDDLE"
                multiplier = middleMultiplier
            } else if absX <= outerWidthAtY {
                zone = "OUTER"
                multiplier = outerMultiplier
            } else {
                // Outside cone horizontally
                continue
            }

            // Apply damage
            let damage = baseDamage * multiplier
            enemy.takeDamage(damage)

            // Debug
//            print("Enemy \(enemy) hit in \(zone) zone for \(damage) damage")
        }
    }


    
    // MARK: - Power-ups
    func applyPowerUp(lengthBoost: CGFloat, angleBoost: CGFloat) {
        targetLength = baseLength + lengthBoost
        targetAngle = baseAngle + angleBoost
    }
    
    func decayPowerUp(deltaTime: CGFloat, decayRate: CGFloat = 0.5) {
        targetLength += (baseLength - targetLength) * decayRate * deltaTime
        targetAngle += (baseAngle - currentAngle) * decayRate * deltaTime
    }
}
