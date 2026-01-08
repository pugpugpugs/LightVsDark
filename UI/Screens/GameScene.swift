import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Properties
    private var sceneStartTime: TimeInterval?
    private var lastUpdateTime: TimeInterval = 0
    var sceneTime: TimeInterval = 0

    var isGameOver = false
    var isTouchingLeft = false
    var isTouchingRight = false

    // MARK: - Game Objects
    var player: Player!
    var playerWeapon: PlayerWeapon!

    // MARK: - Managers
    var safeSpawnGenerator: SafeSpawnGenerator!
    var spawnManager: EnemySpawnManager!
    var enemyManager: EnemyManager!
    var difficultyManager: DifficultyManager!
    var powerUpManager: PowerUpManager!
    var collisionHandler: CollisionHandler!
    var scoreManager: ScoreManager!
    var powerUpSpawnManager: PowerUpSpawnManager!

    // MARK: - Overlays
    var gameOverOverlay: GameOverOverlay!
    
    // MARK: - Factories
    var enemyFactory: EnemyFactory!
    var powerUpFactory: PowerUpFactory!

    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        becomeFirstResponder()
        backgroundColor = .black

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        setupPlayer()
        setupManagers()
        setupOverlay()
    }
    
    private func setupOverlay() {
        let overlay = GameOverOverlay()
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        overlay.onRestart = { [weak self] in self?.restartGame() }
        overlay.isHidden = true
        addChild(overlay)
        self.gameOverOverlay = overlay
    }

    private func setupPlayer() {
        let player = PlayerFactory.createDefaultPlayer(at: CGPoint(x: frame.midX, y: frame.midY))
        addChild(player)
        addChild(player.healthBar)
        player.healthBar.position = CGPoint(x: player.position.x, y: player.position.y - 25)
        self.player = player
        self.playerWeapon = player.weapon
    }

    private func setupManagers() {
        // Enemy Managers
        enemyFactory = EnemyFactory()
        safeSpawnGenerator = SafeSpawnGenerator(sceneSize: size, player: player)
        spawnManager = EnemySpawnManager(enemyFactory: enemyFactory, safeSpawnGenerator: safeSpawnGenerator)
        spawnManager.onEnemyReady = { [weak self] enemy in self?.enemyManager.add(enemy: enemy) }

        enemyManager = EnemyManager()
        enemyManager.render = { [weak self] enemy in self?.addChild(enemy) }
        enemyManager.onEnemyAttackHit = { [weak self] in
            self?.gameOver()
            self?.player.takeDamage()
            ScoreManager.shared.playerHit()
        }

        // PowerUps
        powerUpManager = PowerUpManager(player: player, weapon: playerWeapon)
        powerUpFactory = PowerUpFactory()

        powerUpSpawnManager = PowerUpSpawnManager(factory: powerUpFactory, safeSpawnGenerator: safeSpawnGenerator)
        powerUpSpawnManager.onSpawn = { [weak self] powerUp, position in
            guard let self = self else { return }
            // Add the node to the scene
            powerUp.addToScene(self, at: position, currentTime: self.sceneTime)
        }
        powerUpSpawnManager.onRemove = { [weak self] powerUp in
            guard let self = self else { return }
            
            powerUp.node.removeFromParent()
//            self.powerUpManager.remove(powerUp)
        }

        // Difficulty
        difficultyManager = DifficultyManager()
        difficultyManager.onSpawnIntervalChange = { [weak self] interval in
            self?.spawnManager.enemySpawnInterval = interval
        }
        difficultyManager.onEnemySpeedChange = { [weak self] speed in
            self?.enemyManager.updateAllEnemiesSpeedMultiplier(to: speed)
        }
        difficultyManager.onPowerUpSpawnIntervalChange = { [weak self] interval in
            self?.powerUpSpawnManager.updateSpawnInterval(interval)
        }

        // Collision Handling
        collisionHandler = CollisionHandler(player: player, playerWeapon: playerWeapon)
        collisionHandler.onPlayerStartAttack = { [weak self] enemy in
            self?.playerWeapon.startAttack(on: enemy)
        }
        collisionHandler.onPlayerEndAttack = { [weak self] enemy in
            self?.playerWeapon.endAttack(on: enemy)
        }

        // Score
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
        if sceneStartTime == nil { sceneStartTime = currentTime }
        sceneTime = currentTime - (sceneStartTime ?? currentTime)
        let deltaTime: CGFloat
        if lastUpdateTime > 0 {
            deltaTime = CGFloat(sceneTime - lastUpdateTime)
        } else {
            deltaTime = 1.0 / 60.0
        }
        lastUpdateTime = sceneTime

        // Player movement
        let input: CGFloat = (isTouchingLeft ? -1 : 0) + (isTouchingRight ? 1 : 0)
        player.update(deltaTime: deltaTime, inputDirection: input)

        // Difficulty
        difficultyManager.update(deltaTime: Double(deltaTime))

        // PowerUps: spawn eligible types
        let candidates = powerUpManager.eligiblePowerUpTypes()
        powerUpSpawnManager.update(currentTime: sceneTime, candidateTypes: candidates)
        


        // Enemies
        spawnManager.update(currentTime: sceneTime)
        enemyManager.update(deltaTime: deltaTime, playerPosition: player.position)

        // Score
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
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        for node in nodes(at: location) {
            guard let powerUp = powerUpSpawnManager.activePowerUpsOnScene.first(where: { $0.node === node }) else { continue }

            // Tell manager the player picked it up
            powerUpManager.handlePickup(powerUp, currentTime: sceneTime)

            // Remove node from spawn manager tracking (ready for next spawn)
            powerUpSpawnManager.notifyPowerUpCollected(currentTime: sceneTime)
        }

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

        stopGameLogic()
        gameOverOverlay.isHidden = false
    }

    func restartGame() {
        guard let view = view else { return }
        let newScene = GameScene(size: view.bounds.size)
        newScene.scaleMode = scaleMode
        view.presentScene(newScene, transition: .fade(withDuration: 0.4))
    }

    func stopGameLogic() {
        spawnManager.stop()
        // power up spawn stop
        // enemyManager.stopAllEnemies()
        // powerUpManager.removeAllPowerUps()
    }
}
