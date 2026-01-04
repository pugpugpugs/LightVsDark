import SpriteKit

class SpawnManager {
    weak var scene: GameScene?
    let safeSpawnGenerator: SafeSpawnGenerator
    
    #if DEBUG
    private let debugDrawer: DebugDrawer?
    #endif
    
    private var lastEnemySpawnTime: TimeInterval = 0
    private var lastPowerUpTime: TimeInterval = 0
    private let powerUpInterval: TimeInterval = 1000

    // MARK: - Spawn Zones
    private var spawnZones: [CGRect] = []

    init(scene: GameScene) {
        self.scene = scene
        self.safeSpawnGenerator = SafeSpawnGenerator(sceneSize: scene.size, player: scene.player)
        
        #if DEBUG
        self.debugDrawer = DebugDrawer(scene: scene)
        #endif

        setupSpawnZones()
    }

    // MARK: - Define 8 vertical zones along left/right edges
    private func setupSpawnZones() {
        guard let scene = scene else { return }
        let zoneWidth: CGFloat = 80
        let zoneHeight: CGFloat = scene.size.height / 4
        spawnZones.removeAll()
        
        for i in 0..<4 {
            // Left edge
            let leftZone = CGRect(
                x: 0,
                y: CGFloat(i) * zoneHeight,
                width: zoneWidth,
                height: zoneHeight
            )
            spawnZones.append(leftZone)
            
            // Right edge
            let rightZone = CGRect(
                x: scene.size.width - zoneWidth,
                y: CGFloat(i) * zoneHeight,
                width: zoneWidth,
                height: zoneHeight
            )
            spawnZones.append(rightZone)
        }

        #if DEBUG
        // Draw all zones
        for zone in spawnZones {
            debugDrawer?.drawRect(zone, color: .cyan, persist: true, fill: true)
        }
        #endif
    }

    // MARK: - Update per tick
    func update(currentTime: TimeInterval, enemySpawnInterval: TimeInterval) {
        guard let scene = scene, let player = scene.player else { return }

        // Enemy spawning
        if currentTime - lastEnemySpawnTime > enemySpawnInterval {
            spawnEnemy(player: player)
            lastEnemySpawnTime = currentTime
        }
        
        // Power-up spawning
        if currentTime - lastPowerUpTime > powerUpInterval {
            spawnPowerUp(player: player)
            lastPowerUpTime = currentTime
        }
    }

    private func spawnPowerUp(player: Player) {
        guard let scene = scene else { return }
        
        #if DEBUG
        debugDrawer?.clearTemporary()
        #endif
     
        let powerUp = PowerUp(type: .widenCone, duration: 3.0, size: CGSize(width: 40, height: 40))
        
        // Random zone spawn
        if let zone = spawnZones.randomElement() {
            powerUp.position = CGPoint(
                x: CGFloat.random(in: zone.minX...zone.maxX),
                y: CGFloat.random(in: zone.minY...zone.maxY)
            )
        } else {
            powerUp.position = player.position + CGPoint(x: 0, y: 300)
        }
        
        scene.addChild(powerUp)
        
        #if DEBUG
        debugDrawer?.drawDot(at: powerUp.position, color: .green, persist: false)
        print("Spawned POWERUP at \(powerUp.position)")
        #endif
    }

    private func spawnEnemy(player: Player) {
        guard let scene = scene else { return }
        if scene.enemies.count > 10 { return }

        // Random zone spawn
        let spawnPosition: CGPoint
        if let zone = spawnZones.randomElement() {
            spawnPosition = CGPoint(
                x: CGFloat.random(in: zone.minX...zone.maxX),
                y: CGFloat.random(in: zone.minY...zone.maxY)
            )
        } else {
            spawnPosition = player.position + CGPoint(x: 0, y: 300)
        }

        // Alternate enemy types using modulo
        let enemy: Enemy
        if scene.enemies.count % 2 == 0 {
            enemy = EasyEnemy(position: spawnPosition)
        } else if scene.enemies.count % 3 == 0 {
            enemy = HardEnemy(position: spawnPosition)
        } else {
            enemy = EdgeSkaterEnemy(position: spawnPosition)
        }

        scene.addChild(enemy)
        scene.enemies.append(enemy)

        #if DEBUG
        debugDrawer?.drawDot(at: enemy.position, color: .red, persist: false)
        print("Spawned \(type(of: enemy)) at \(enemy.position)")
        #endif
    }
}
