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
    var enemyFactory: EnemyFactory!
    var safeSpawnGenerator: SafeSpawnGenerator!
    var spawnManager: SpawnManager!
    var enemyManager: EnemyManager!
    var difficultyManager: DifficultyManager!
    var powerUpManager: PowerUpManager!
    var collisionHandler: CollisionHandler!
    var scoreManager: ScoreManager!

    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        becomeFirstResponder()
        backgroundColor = .black

        // Physics
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        // --- Player & LightCone ---
        setupPlayer()

        // --- Managers ---
        setupManagers()
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
        // --- Enemy / Spawn ---
        enemyFactory = EnemyFactory()
        safeSpawnGenerator = SafeSpawnGenerator(sceneSize: size, player: player)
        spawnManager = SpawnManager(enemyFactory: enemyFactory, safeSpawnGenerator: safeSpawnGenerator)
        spawnManager.onEnemyReady = { [weak self] enemy in
            self?.enemyManager.add(enemy: enemy)
        }

        enemyManager = EnemyManager()
        // render closure decouples scene from manager
        enemyManager.render = { [weak self] enemy in
            self?.addChild(enemy)
        }
        
        enemyManager?.onEnemyAttackHit = { [weak self] in
            self?.player.takeDamage()
            ScoreManager.shared.playerHit()
        }

        // --- Difficulty ---
        difficultyManager = DifficultyManager()
        difficultyManager.onSpawnIntervalChange = { [weak self] interval in
            self?.spawnManager.enemySpawnInterval = interval
        }
        difficultyManager.onEnemySpeedChange = { [weak self] speedMultiplier in
            self?.enemyManager.updateAllEnemiesSpeedMultiplier(to: speedMultiplier)
        }

        // --- PowerUps ---
        powerUpManager = PowerUpManager(weapon: player.weapon, player: player, enemies: enemyManager.activeEnemies)

        // --- Collision Handling ---
        collisionHandler = CollisionHandler(player: player, playerWeapon: playerWeapon, powerUpManager: powerUpManager)

        collisionHandler.onPlayerStartAttack = { [weak self] enemy in
            self?.playerWeapon.startAttack(on: enemy)
        }

        collisionHandler.onPlayerEndAttack = { [weak self] enemy in
            self?.playerWeapon.endAttack(on: enemy)
        }

        // --- Score / Combo ---
        scoreManager = ScoreManager(
            scene: self,
            scorePosition: CGPoint(x: frame.midX, y: frame.height - 60),
            comboPosition: CGPoint(x: frame.midX, y: frame.height - 120)
        )
    }

    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        // --- Delta time ---
        if sceneStartTime == nil { sceneStartTime = currentTime }
        sceneTime = currentTime - (sceneStartTime ?? currentTime)
        let deltaTime: CGFloat
        if lastUpdateTime > 0 {
            deltaTime = CGFloat(sceneTime - lastUpdateTime)
        } else {
            deltaTime = 1.0 / 60.0
        }
        lastUpdateTime = sceneTime

        // --- Player & LightCone ---
        let input: CGFloat = (isTouchingLeft ? -1 : 0) + (isTouchingRight ? 1 : 0)
        player.update(deltaTime: deltaTime, inputDirection: input)

        // --- Difficulty ---
        difficultyManager.update(deltaTime: Double(deltaTime))

        // --- Spawn Enemies ---
        spawnManager.update(currentTime: currentTime)

        // --- Update all enemies ---
        enemyManager.update(deltaTime: deltaTime, playerPosition: player.position)

        // --- Score / Combo ---
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
