import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Properties
    private var sceneStartTime: TimeInterval?
    
    var player: Player!
    var lightCone: LightCone!
    var spawnManager: SpawnManager!
    var safeSpawnGenerator: SafeSpawnGenerator!
    var enemyFactory: EnemyFactory!
    
    var enemies: [Enemy] = []
    var isGameOver = false
    
    private var lastUpdateTime: TimeInterval = 0
    var isTouchingLeft = false
    var isTouchingRight = false
    var sceneTime: TimeInterval = 0

    // Managers / Handlers
    var difficultyManager: DifficultyManager!
    var collisionHandler: CollisionHandler!
    var scoreManager: ScoreManager!
    var powerUpManager: PowerUpManager!
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        becomeFirstResponder()

        backgroundColor = .black
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero

        // --- Player setup ---
        player = Player(position: CGPoint(x: frame.midX, y: frame.midY), screenSize: self.size)
        lightCone = player.lightCone
        addChild(player)
        
        // --- PowerUpManager ---
        powerUpManager = PowerUpManager(cone: player.lightCone, player: player, enemies: enemies)

        // --- CollisionHandler ---
        collisionHandler = CollisionHandler(player: player, lightCone: lightCone, powerUpManager: powerUpManager)

        enemyFactory = EnemyFactory()
        safeSpawnGenerator = SafeSpawnGenerator(sceneSize: size, player: player)
        
        // --- SpawnManager ---
        spawnManager = SpawnManager(enemyFactory: enemyFactory, safeSpawnGenerator: safeSpawnGenerator)

        // --- DifficultyManager ---
        difficultyManager = DifficultyManager(
            initialSpeed: 50,
            initialSpawnInterval: 2.5,
            spawnIntervalMin: 0.5,
            rampRate: 10,
            spawnDecrease: 0.1
        )

        // --- ScoreManager ---
        scoreManager = ScoreManager(
            scene: self,
            scorePosition: CGPoint(x: frame.midX, y: frame.height - 60),
            comboPosition: CGPoint(x: frame.midX, y: frame.height - 120)
        )
    }
    
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }
        
        // Delta time
        let deltaTime: CGFloat
        if lastUpdateTime > 0 {
            deltaTime = CGFloat(sceneTime - lastUpdateTime)
        } else {
            deltaTime = 1.0 / 60.0
        }
        lastUpdateTime = sceneTime

        // --- Player ---
        var input: CGFloat = 0
        if isTouchingLeft { input = -1 }
        if isTouchingRight { input = 1 }
        
        player.updateRotation(deltaTime: deltaTime, inputDirection: input)
        
        player.lightCone?.update(deltaTime: deltaTime)
        
        player.lightCone?.applyDamage(deltaTime: deltaTime)

        // --- Difficulty ---
        difficultyManager.update(deltaTime: Double(deltaTime))

        // --- Spawn ---
        if let enemy = spawnManager.update(currentTime: currentTime) {
                    // Set closure for attack
                    enemy.onAttackHit = { [weak self] in
                        self?.player.takeDamage()
                    }

                    // Set closure for destruction
                    enemy.onDestroyed = { [weak self, weak enemy] in
                        guard let self = self, let enemy = enemy else { return }
                        self.enemies.removeAll { $0 === enemy }
                    }

                    addChild(enemy)
                    enemies.append(enemy)
                }

                // Update all enemies
                for enemy in enemies {
                    enemy.update(deltaTime: CGFloat(deltaTime), targetPosition: player.position)
                }

        // --- Score ---
        scoreManager.update(deltaTime: Double(deltaTime))
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

    // MARK: - Physics Contact
    func didBegin(_ contact: SKPhysicsContact) {
        collisionHandler.handleBegin(contact: contact)
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        collisionHandler.handleEnd(contact: contact)
    }

    // MARK: - Game Over
    func gameOver() {
        return
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
