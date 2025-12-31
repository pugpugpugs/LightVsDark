import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    var player: Player!
    var spawnManager: SpawnManager!
    var obstacles: [Obstacle] = []
    var isGameOver = false
    var score: TimeInterval = 0
    var scoreLabel: SKLabelNode!
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        
        // Create player in center
        player = Player(position: CGPoint(x: frame.midX, y: frame.midY))
        addChild(player)
        _ = player.addLightCone()
        
        // Initialize spawn manager
        spawnManager = SpawnManager(scene: self)
        
        scoreLabel = SKLabelNode(fontNamed: "Menlo")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.height - 60)
        scoreLabel.text = "0"
        addChild(scoreLabel)
    }
    
    // MARK: - Touch Input
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.rotateClockwise()
    }
    
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }
        
        score += 1.0 / 60.0
        scoreLabel.text = "\(Int(score))"
        
        // Spawn obstacles via manager
        spawnManager.update(currentTime: currentTime)
        
        // Move obstacles
        let speed: CGFloat = 2.5
        
        for obstacle in obstacles {
            obstacle.moveTowardPlayer(playerPosition: player.position, speed: speed)
            
            // Distance to player
            let (distance, angleDiff) = player.position.distanceAndAngleDiff(to: obstacle.position, facingAngle: player.facingAngle)
            
            // Check if inside light cone 30 degree cone
            if abs(angleDiff) < player.coneWidth / 2 {
                // Obstacle is in light cone -> neutralize
                obstacle.removeFromParent()
                
                if let index = obstacles.firstIndex(of: obstacle) {
                    obstacles.remove(at: index)
                }
            } else if distance < player.radius {
                gameOver()
            }
            
            // Remove off-screen obstacles
            if obstacle.position.y + obstacle.frame.height / 2 < 0 {
                obstacle.removeFromParent()
                if let index = obstacles.firstIndex(of: obstacle) {
                    obstacles.remove(at: index)
                }
            }
        }
    }
    
    // MARK: - Physics Contact
    func didBegin(_ contact: SKPhysicsContact) {
        
        let bodyA = contact.bodyA.categoryBitMask
        let bodyB = contact.bodyB.categoryBitMask
        
        let collision = bodyA | bodyB
        
        // Check if player collided with an obstacle
        if collision == PhysicsCategory.player | PhysicsCategory.obstacle {
            gameOver()
        }
    }
    
    func gameOver() {
        guard !isGameOver else { return }
        isGameOver = true
        
        removeAllActions()
        
        let wait = SKAction.wait(forDuration: 1.0)
        let restart = SKAction.run {
            if let view = self.view {
                let newScene = GameScene(size: view.bounds.size)
                newScene.scaleMode = .resizeFill
                view.presentScene(newScene, transition: .fade(withDuration: 0.5))
            }
        }
        
        run(SKAction.sequence([wait, restart]))
    }
}
