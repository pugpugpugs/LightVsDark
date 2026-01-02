import SpriteKit

class LightCone: SKShapeNode {

    // MARK: - Properties

    var maxLength: CGFloat
    var minLength: CGFloat
    private(set) var currentLength: CGFloat
    private let baseLengthShrinkRate: CGFloat

    var maxAngle: CGFloat
    var minAngle: CGFloat
    private(set) var currentAngle: CGFloat
    private let baseAngleShrinkRate: CGFloat

    // Target values for smooth power-up boosts
    private var targetLength: CGFloat
    private var targetAngle: CGFloat

    // MARK: - Public read-only access
    var lengthValue: CGFloat { currentLength }
    var angleValue: CGFloat { currentAngle }

    // MARK: - Init
    init(screenSize: CGSize, desiredWidth: CGFloat = 0) {

        // Length
        self.maxLength = screenSize.height * 0.6
        self.minLength = 150
        self.currentLength = maxLength
        self.baseLengthShrinkRate = 2

        // Angle
        let width = desiredWidth > 0 ? desiredWidth : screenSize.height * 2
        let halfAngle = atan(width / (2 * maxLength))
        self.maxAngle = halfAngle * 2
        self.minAngle = .pi / 8
        self.currentAngle = maxAngle
        self.baseAngleShrinkRate = maxAngle * 0.025

        // Targets start at normal values
        self.targetLength = maxLength
        self.targetAngle = maxAngle

        super.init()

        self.fillColor = UIColor.yellow.withAlphaComponent(0.25)
        self.strokeColor = .clear
        self.zPosition = -1

        updatePathAndPhysics()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Update
    func update(deltaTime: CGFloat, difficultyLevel: CGFloat) {
        // The cone simply multiplies its base shrink rates by this value
        let shrinkLength = baseLengthShrinkRate * deltaTime * difficultyLevel
        let shrinkAngle  = baseAngleShrinkRate  * deltaTime * difficultyLevel

        // Shrink the target values toward their minimum
        targetLength = max(targetLength - shrinkLength, minLength)
        targetAngle  = max(targetAngle - shrinkAngle, minAngle)

        // Smoothly move current values toward target (for smooth visual effect / power-ups)
        let lerpFactor: CGFloat = 0.1
        currentLength += (targetLength - currentLength) * lerpFactor
        currentAngle  += (targetAngle - currentAngle)  * lerpFactor

        updatePathAndPhysics()
    }


    // MARK: - Power-up
    /// Safely apply a temporary boost
    func applyPowerUp(lengthBoost: CGFloat, angleBoost: CGFloat) {
        targetLength = min(maxLength, targetLength + lengthBoost)
        targetAngle  = min(maxAngle, targetAngle + angleBoost)
    }

    // Optional: decay target back to base over time (smoothly)
    func decayPowerUp(deltaTime: CGFloat, decayRate: CGFloat = 0.5) {
        targetLength += (maxLength - targetLength) * decayRate * deltaTime
        targetAngle  += (maxAngle - targetAngle)  * decayRate * deltaTime
    }

    // MARK: - Path + Physics
    private func updatePathAndPhysics() {
        let halfWidth = tan(currentAngle / 2) * currentLength
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: currentLength, y: -halfWidth))
        path.addLine(to: CGPoint(x: currentLength, y: halfWidth))
        path.closeSubpath()
        self.path = path

        self.physicsBody = SKPhysicsBody(polygonFrom: path)
        self.physicsBody?.categoryBitMask = PhysicsCategory.lightCone
        self.physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.powerUp
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.usesPreciseCollisionDetection = true
    }

    // MARK: - Spawn point check
    func containsPointWithPadding(_ point: CGPoint, padding: CGFloat) -> Bool {
        let offsets: [CGPoint] = [
            CGPoint(x: -padding, y: -padding),
            CGPoint(x: padding, y: -padding),
            CGPoint(x: -padding, y: padding),
            CGPoint(x: padding, y: padding)
        ]

        for offset in offsets {
            if self.contains(point + offset) {
                return true
            }
        }
        return false
    }
    
    func containsWorldPoint(_ point: CGPoint, padding: CGFloat = 0) -> Bool {
        guard let parent = parent else { return false }

        let local = convert(point, from: parent)

        // Must be in front of cone
        guard local.x > 0 else { return false }

        // Must be within visible length
        guard local.x <= currentLength + padding else { return false }

        // Must be inside angle
        let halfWidth = tan(currentAngle / 2) * local.x
        guard abs(local.y) <= halfWidth + padding else { return false }

        return true
    }

}
