import SpriteKit

class ScoreManager {
    private weak var scene: SKScene?
    private var scoreLabel: SKLabelNode
    
    private(set) var score: TimeInterval = 0
    
    init(scene: SKScene, position: CGPoint, fontName: String = "Menlo", fontSize: CGFloat = 24, fontColor: SKColor = .white) {
        self.scene = scene
        
        // Create label
        scoreLabel = SKLabelNode(fontNamed: fontName)
        scoreLabel.fontSize = fontSize
        scoreLabel.fontColor = fontColor
        scoreLabel.position = position
        scoreLabel.text = "0"
        
        scene.addChild(scoreLabel)
    }
    
    // MARK: - Update score
    func update(deltaTime: TimeInterval) {
        score += deltaTime
        scoreLabel.text = "\(Int(score))"
    }
    
    // Optionally reset
    func reset() {
        score = 0
        scoreLabel.text = "0"
    }
}
