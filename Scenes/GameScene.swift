import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    var player: Player!
    var spawnManager: SpawnManager!
    var obstacles: [Obstacle] = []
    var isGameOver = false
    var score: TimeInterval = 0
    var scoreLabel: SKLabelNode!
    
    var baseObstacleSpeed: CGFloat = 50
    var spawnIntervalBase: TimeInterval = 1.0
    
    // Difficulty ramping
    var difficultyTimer: TimeInterval = 0
    private var lastDifficultyUpdate: TimeInterval = 0
    let difficultyRampRate: CGFloat = 50 // speed increase per 10 seconds
    let spawnIntervalMin: TimeInterval = 0.5
   
    private var lastUpdateTime: TimeInterval = 0
    
    override var canBecomeFirstResponder: Bool { true }
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        becomeFirstResponder()
        
        backgroundColor = .black
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        
        // Create player in center
        player = Player(position: CGPoint(x: frame.midX, y: frame.midY))
        addChild(player)
        _ = player.addLightCone()
        
        // Initialize spawn manager
        spawnManager = SpawnManager(scene: self)
        
        // Score label
        scoreLabel = SKLabelNode(fontNamed: "Menlo")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.height - 60)
        scoreLabel.text = "0"
        addChild(scoreLabel)
    }
    
    // MARK: - Touch Input
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if location.x < frame.midX {
            player.rotateCounterClockwise()
        } else {
            player.rotateClockwise()
        }
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            switch press.key?.keyCode {
            case .keyboardLeftArrow:
                player.rotateCounterClockwise()
            case .keyboardRightArrow:
                player.rotateClockwise()
            default:
                break
            }
        }
    }
    
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        // Calculate deltaTime using your lastUpdateTime extension
        let deltaTime: CGFloat = lastUpdateTime > 0 ? CGFloat(currentTime - lastUpdateTime) : 1.0 / 60.0
        lastUpdateTime = currentTime

        // Update score
        score += Double(deltaTime)
        scoreLabel.text = "\(Int(score))"

        // Difficulty ramp — once every 10 seconds
        difficultyTimer += Double(deltaTime)
        if difficultyTimer - lastDifficultyUpdate >= 10.0 {
            lastDifficultyUpdate = difficultyTimer
            baseObstacleSpeed += difficultyRampRate
            spawnManager.spawnInterval = max(spawnIntervalMin, spawnManager.spawnInterval - 0.05)
        }

        // Spawn obstacles
        spawnManager.update(currentTime: currentTime)

        // Move obstacles and handle interactions
        for obstacle in obstacles {
            // Move obstacle toward player
            obstacle.moveTowardPlayer(
                playerPosition: player.position,
                baseSpeed: baseObstacleSpeed,
                deltaTime: deltaTime
            )
            
            // Check if obstacle is inside the player's current zone
            if player.zoneIndex(for: obstacle.position) == player.currentZone {
                // Destroy the obstacle
                obstacle.removeFromParent()
                obstacles.removeAll { $0 === obstacle }
                continue
            }
            
            // Check collision with player
            if player.position.distance(to: obstacle.position) < player.radius {
                gameOver()
                return
            }
            
            // Remove off-screen obstacles
            if obstacle.position.y + obstacle.frame.height / 2 < 0 {
                obstacle.removeFromParent()
                obstacles.removeAll { $0 === obstacle }
            }
        }

    }

    
    // MARK: - Physics Contact
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == (PhysicsCategory.player | PhysicsCategory.obstacle) {
            gameOver()
        }
    }
    
    // MARK: - Game Over
    func gameOver() {
        guard !isGameOver else { return }
        isGameOver = true
        removeAllActions()
        
        let wait = SKAction.wait(forDuration: 1.0)
        let restart = SKAction.run { [weak self] in
            guard let self = self, let view = self.view else { return }
            let newScene = GameScene(size: view.bounds.size)
            newScene.scaleMode = .resizeFill
            view.presentScene(newScene, transition: .fade(withDuration: 0.5))
        }
        run(SKAction.sequence([wait, restart]))
    }
}
