import SpriteKit

/// A reusable health bar for any node
class EnemyHealthBar: SKNode {
    
    // MARK: - Properties
    
    /// Maximum health
    private(set) var maxHealth: CGFloat
    /// Current health
    private(set) var health: CGFloat
    
    /// Visual nodes
    private let backgroundNode: SKSpriteNode
    private let fillNode: SKSpriteNode
    
    /// Optional textures
    private var fillTexture: SKTexture?
    private var backgroundTexture: SKTexture?
    
    /// Size
    private let barSize: CGSize
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - maxHealth: Maximum health value
    ///   - size: Size of the bar
    ///   - fillColor: Fill color (ignored if `fillTexture` is provided)
    ///   - backgroundColor: Background color (ignored if `backgroundTexture` is provided)
    ///   - fillTexture: Optional texture for fill
    ///   - backgroundTexture: Optional texture for background
    init(
        maxHealth: CGFloat,
        size: CGSize = CGSize(width: 40, height: 6),
        fillColor: UIColor = .green,
        backgroundColor: UIColor = .black,
        fillTexture: SKTexture? = nil,
        backgroundTexture: SKTexture? = nil
    ) {
        self.maxHealth = maxHealth
        self.health = maxHealth
        self.barSize = size
        self.fillTexture = fillTexture
        self.backgroundTexture = backgroundTexture
        
        // Background
        if let bgTex = backgroundTexture {
            backgroundNode = SKSpriteNode(texture: bgTex, size: size)
        } else {
            backgroundNode = SKSpriteNode(color: backgroundColor, size: size)
        }
        backgroundNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        // Fill
        if let fillTex = fillTexture {
            fillNode = SKSpriteNode(texture: fillTex, size: size)
        } else {
            fillNode = SKSpriteNode(color: fillColor, size: size)
        }
        fillNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        super.init()
        
        addChild(backgroundNode)
        addChild(fillNode)
        
        // Position fill over background
        fillNode.position = CGPoint(x: -size.width/2, y: 0)
        backgroundNode.position = CGPoint(x: -size.width/2, y: 0)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    // MARK: - Update Health
    
    /// Sets health and updates bar
    func setHealth(_ newHealth: CGFloat, animated: Bool = true, duration: TimeInterval = 0.1) {
        health = max(0, min(newHealth, maxHealth))
        let percentage = health / maxHealth
        
        let newWidth = barSize.width * percentage
        if animated {
            fillNode.run(SKAction.resize(toWidth: newWidth, duration: duration))
        } else {
            fillNode.size.width = newWidth
        }
        
        // Optional color gradient (green → yellow → red)
        if fillTexture == nil {
            fillNode.color = percentage > 0.5 ? .green :
                             (percentage > 0.25 ? .yellow : .red)
        }
    }
    
    /// Reduce health by amount
    func takeDamage(_ amount: CGFloat, animated: Bool = true) {
        setHealth(health - amount, animated: animated)
    }
    
    /// Heal by amount
    func heal(_ amount: CGFloat, animated: Bool = true) {
        setHealth(health + amount, animated: animated)
    }
}
