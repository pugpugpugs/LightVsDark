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
    var isTouchingLeft = false
    var isTouchingRight = false

    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        becomeFirstResponder()

        backgroundColor = .black
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero

        // Player setup
        player = Player(position: CGPoint(x: frame.midX, y: frame.midY))
        addChild(player)
        player.addDebugZones(to: self)

        // Spawn manager
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
        isTouchingLeft = location.x < frame.midX
        isTouchingRight = location.x >= frame.midX
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouchingLeft = false
        isTouchingRight = false
    }

    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        let deltaTime: CGFloat = lastUpdateTime > 0 ? CGFloat(currentTime - lastUpdateTime) : 1.0 / 60.0
        lastUpdateTime = currentTime

        // Rotation input
        var input: CGFloat = 0
        if isTouchingLeft { input = -1 }
        if isTouchingRight { input = 1 }
        player.updateRotation(deltaTime: deltaTime, inputDirection: input)

        // Shrink light cone over time
        player.lightCone?.updateLength(deltaTime: deltaTime)

        // Update score
        score += Double(deltaTime)
        scoreLabel.text = "\(Int(score))"

        // Difficulty ramp — every 10 seconds
        difficultyTimer += Double(deltaTime)
        if difficultyTimer - lastDifficultyUpdate >= 10.0 {
            lastDifficultyUpdate = difficultyTimer
            baseObstacleSpeed += difficultyRampRate
            spawnManager.spawnInterval = max(spawnIntervalMin, spawnManager.spawnInterval - 0.05)
        }

        // Spawn obstacles
        spawnManager.update(currentTime: currentTime)

        // Move obstacles and remove off-screen
        for obstacle in obstacles {
            obstacle.moveTowardPlayer(playerPosition: player.position, baseSpeed: baseObstacleSpeed, deltaTime: deltaTime)

            // Off-screen removal
            if obstacle.position.y + obstacle.frame.height / 2 < 0 {
                obstacle.removeFromParent()
                obstacles.removeAll { $0 === obstacle }
            }
        }
    }

    // Collision handler dictionary
    lazy var collisionHandlers: [UInt32: (SKNode, SKNode) -> Void] = [
        PhysicsCategory.lightCone | PhysicsCategory.obstacle: { [weak self] nodeA, nodeB in
            guard let self = self else { return }
            let obstacle = nodeA.physicsBody?.categoryBitMask == PhysicsCategory.obstacle ? nodeA : nodeB
            obstacle.removeFromParent()
            self.obstacles.removeAll { $0 === obstacle }
        },
        PhysicsCategory.player | PhysicsCategory.obstacle: { [weak self] _, _ in
            self?.gameOver()
        }
    ]

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }

        // Compute combined categoryBitMask
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        // Call handler if exists
        collisionHandlers[collision]?(nodeA, nodeB)
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
