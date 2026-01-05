import SpriteKit

class ScoreManager {
    // Singleton for easy access
    static var shared: ScoreManager!

    // Labels
    private var scoreLabel: SKLabelNode
    private var comboLabel: SKLabelNode

    // Score and combo state
    private(set) var score: Int = 0
    private(set) var scoreFromCombo: Int = 0
    private(set) var comboMultiplier: Int = 1
    private(set) var currentComboCount: Int = 0
    
    // Time-based score
    private var elapsedTime: TimeInterval = 0
    private let pointsPerSecond: Int = 1

    // MARK: - Initialization
    init(scene: SKScene,
         scorePosition: CGPoint = CGPoint(x: 100, y: 50),
         comboPosition: CGPoint = CGPoint(x: 100, y: 20),
         fontName: String = "Menlo",
         fontSize: CGFloat = 24,
         fontColor: SKColor = .white) {

        // Score label
        scoreLabel = SKLabelNode(fontNamed: fontName)
        scoreLabel.fontSize = fontSize
        scoreLabel.fontColor = fontColor
        scoreLabel.position = scorePosition
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.text = "Score: 0"
        scene.addChild(scoreLabel)

        // Combo label
        comboLabel = SKLabelNode(fontNamed: fontName)
        comboLabel.fontSize = fontSize
        comboLabel.fontColor = fontColor
        comboLabel.position = comboPosition
        comboLabel.horizontalAlignmentMode = .left
        comboLabel.text = "Combo x1"
        scene.addChild(comboLabel)

        // Set singleton
        ScoreManager.shared = self
    }
    
    // MARK: - Call every frame to update time-based score
    func update(deltaTime: TimeInterval) {
        elapsedTime += deltaTime
        
        let timeScore = Int(elapsedTime) * pointsPerSecond

        let comboScore = scoreFromCombo
        
        score = timeScore + comboScore
        
        updateLabels()
    }


    // MARK: - Enemy killed
    func enemyKilled(basePoints: Int) {
        // Add points scaled by combo multiplier
        scoreFromCombo += basePoints * comboMultiplier

        // Increment combo
        currentComboCount += 1
        comboMultiplier = 1 + currentComboCount / 5 // Simple scaling: +1 every 5 kills

        updateLabels()
        print("enemy killed: \(comboMultiplier)")
    }

    // MARK: - Player hit
    func playerHit() {
        currentComboCount = 0
        comboMultiplier = 1
        updateLabels()
    }

    // MARK: - Reset all
    func resetAll() {
        score = 0
        comboMultiplier = 1
        currentComboCount = 0
        updateLabels()
    }

    // MARK: - Update labels
    private func updateLabels() {
        scoreLabel.text = "Score: \(score)"
        comboLabel.text = "Combo x\(currentComboCount)"
    }
}
