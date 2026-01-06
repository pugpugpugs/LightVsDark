import SpriteKit

class LightCone: SKShapeNode, PlayerWeapon {
    
    // MARK: - PlayerWeapon
    weak var owner: Player?
    var node: SKNode { return self }
    
    // MARK: - Debug
    var debugDrawEnabled: Bool = true {
        didSet { updateDebugVisibility() }
    }
    private var physicsDebugNode: SKShapeNode?
    
    // MARK: - Enemies
    private var activeEnemies = NSHashTable<Enemy>.weakObjects()
    
    // MARK: - Cone Properties
    let baseLength: CGFloat
    let baseAngle: CGFloat
    
    private(set) var currentLength: CGFloat
    private(set) var currentAngle: CGFloat
    
    private var targetLength: CGFloat
    private var targetAngle: CGFloat
    
    // Damage
    var isAttacking: Bool = false
    var baseDPS: CGFloat = 5
    private let innerMultiplier: CGFloat = 2.5
    private let middleMultiplier: CGFloat = 1.0
    private let outerMultiplier: CGFloat = 0.5
    
    // Half-widths
    private(set) var innerHalfWidth: CGFloat = 0
    private(set) var middleHalfWidth: CGFloat = 0
    private(set) var outerHalfWidth: CGFloat = 0
    
    // Overlays
    private let innerOverlay = SKShapeNode()
    private let middleOverlay = SKShapeNode()
    private let outerOverlay = SKShapeNode()
    
    var enemiesInCone = NSHashTable<Enemy>.weakObjects()
    
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
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Update / Attack
    func update(deltaTime: CGFloat) {
        // Smoothly interpolate towards target
        let lerpFactor: CGFloat = 0.1
        currentLength += (targetLength - currentLength) * lerpFactor
        currentAngle += (targetAngle - currentAngle) * lerpFactor
        updatePathAndPhysics()
        
        let damage = baseDPS * deltaTime
        for enemy in activeEnemies.allObjects {
            guard let enemyParent = enemy.parent else { return }
            let localPos = convert(enemy.position, from: enemyParent)
            let x = localPos.x
            let y = localPos.y
            
            if y < 0 || y > currentLength { return }
            let innerWidthAtY = innerHalfWidth * (y / currentLength)
            let middleWidthAtY = middleHalfWidth * (y / currentLength)
            let outerWidthAtY = outerHalfWidth * (y / currentLength)
            let absX = abs(x)
            let multiplier: CGFloat
            if absX <= innerWidthAtY { multiplier = innerMultiplier }
            else if absX <= middleWidthAtY { multiplier = middleMultiplier }
            else if absX <= outerWidthAtY { multiplier = outerMultiplier }
            else { return }
            
            enemy.takeDamage(damage * multiplier)
        }
    }
    
    func startAttack(on enemy: Enemy) {
        activeEnemies.add(enemy)
        enemy.isAttackedStart()
    }
    
    func endAttack(on enemy: Enemy) {
        activeEnemies.remove(enemy)
        enemy.isAttackedEnd()
    }
    
    // MARK: - Helpers
    private func setupOverlays() {
        let innerColor  = UIColor(red: 1, green: 0.45, blue: 0, alpha: 0.75)
        let middleColor = UIColor(red: 1, green: 0.65, blue: 0.1, alpha: 0.75)
        let outerColor  = UIColor(red: 1, green: 1, blue: 0.2, alpha: 0.75)
        
        func addOverlay(_ overlay: SKShapeNode, color: UIColor, blurRadius: CGFloat) {
            overlay.fillColor = color
            overlay.strokeColor = .clear
            overlay.zPosition = 0
            let glow = SKEffectNode()
            glow.shouldRasterize = true
            glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": blurRadius])
            glow.addChild(overlay)
            addChild(glow)
        }
        
        addOverlay(outerOverlay, color: outerColor, blurRadius: 4)
        addOverlay(middleOverlay, color: middleColor, blurRadius: 3)
        addOverlay(innerOverlay, color: innerColor, blurRadius: 2)
    }
    
    private func updateHalfWidths() {
        innerHalfWidth  = tan(currentAngle / 18) * currentLength
        middleHalfWidth = tan(currentAngle / 4) * currentLength
        outerHalfWidth  = tan(currentAngle / 2) * currentLength
    }
    
    private func updatePathAndPhysics() {
        updateHalfWidths()
        let outerPath = pathForZone(halfWidth: outerHalfWidth)
        self.path = outerPath
        outerOverlay.path = outerPath
        middleOverlay.path = pathForZone(halfWidth: middleHalfWidth)
        innerOverlay.path = pathForZone(halfWidth: innerHalfWidth)
        
        if physicsBody == nil {
            physicsBody = SKPhysicsBody(polygonFrom: outerPath)
            physicsBody?.categoryBitMask = PhysicsCategory.playerWeapon
            physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.powerUp
            physicsBody?.collisionBitMask = 0
            physicsBody?.isDynamic = false
            physicsBody?.affectedByGravity = false
            physicsBody?.usesPreciseCollisionDetection = true
            
            let debugNode = SKShapeNode(path: outerPath)
            debugNode.strokeColor = .cyan
            debugNode.lineWidth = 2
            debugNode.fillColor = .clear
            debugNode.zPosition = 100
            addChild(debugNode)
            physicsDebugNode = debugNode
        } else {
            physicsDebugNode?.path = outerPath
        }
        
        updateDebugVisibility()
    }
    
    private func pathForZone(halfWidth: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let tip = CGPoint.zero
        let baseY = currentLength
        let steps = 20
        let arcHeight: CGFloat = 20
        
        path.move(to: tip)
        for i in 0...steps {
            let t = CGFloat(i)/CGFloat(steps)
            let x = -halfWidth + t * (halfWidth*2)
            let yOffset = sin((x/outerHalfWidth + 1) * .pi/2) * arcHeight
            path.addLine(to: CGPoint(x: x, y: baseY + yOffset))
        }
        path.addLine(to: tip)
        path.closeSubpath()
        return path
    }
    
    private func updateDebugVisibility() {
        innerOverlay.isHidden = !debugDrawEnabled
        middleOverlay.isHidden = !debugDrawEnabled
        outerOverlay.isHidden = !debugDrawEnabled
        physicsDebugNode?.isHidden = !debugDrawEnabled
    }
}
