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
            enemy = EdgeSkaterEnemy(position: spawnPosition)
        } else if scene.enemies.count % 3 == 0 {
            enemy = HardEnemy(position: spawnPosition)
        } else {
            enemy = EasyEnemy(position: spawnPosition)
        }

        scene.addChild(enemy)
        scene.enemies.append(enemy)

        #if DEBUG
        debugDrawer?.drawDot(at: enemy.position, color: .red, persist: false)
        print("Spawned \(type(of: enemy)) at \(enemy.position)")
        #endif
    }

}
    
////
////  SpawnManager.swift
////  LightVsDark iOS
////
////  Created by chris on 12/30/25.
////
//
//import SpriteKit
//
//class SpawnManager {
//    weak var scene: GameScene?
//    let safeSpawnGenerator: SafeSpawnGenerator
//
//    #if DEBUG
//    private let debugDrawer: DebugDrawer?
//    #endif
//
//    private var lastEnemySpawnTime: TimeInterval = 0
//
//    private var lastPowerUpTime: TimeInterval = 0
//    private let powerUpInterval: TimeInterval = 1000
//
//    init(scene: GameScene) {
//        self.scene = scene
//        self.safeSpawnGenerator = SafeSpawnGenerator(sceneSize: scene.size, player: scene.player)
//        #if DEBUG
//        self.debugDrawer = DebugDrawer(scene: scene)
//        #endif
//    }
//
//    // MARK: - Update on tic
//    func update(currentTime: TimeInterval, enemySpawnInterval: TimeInterval) {
//        guard let scene = scene, let player = scene.player else { return }
//
//        // obstacle spawning
//        if currentTime - lastEnemySpawnTime > enemySpawnInterval {
//            spawnEnemy(player: player)
//            lastEnemySpawnTime = currentTime
//        }
//
//        // power up spawning
//        if currentTime - lastPowerUpTime > powerUpInterval {
//            spawnPowerUp(player: player)
//            lastPowerUpTime = currentTime
//        }
//    }
//
//    private func spawnPowerUp(player: Player) {
//        guard let scene = scene else { return }
//
//        #if DEBUG
//        debugDrawer?.clearTemporary()
//        #endif
//
//        let powerUp = PowerUp(type: .widenCone, duration: 3.0, size: CGSize(width: 40, height: 40))
//
//        if let cone = player.lightCone {
//            powerUp.position = safeSpawnGenerator.generateSafeSpawnPoint(spriteSize: CGSize(width: 40, height: 40), minDistance: player.radius + 50, cone: cone, debugColor: .red)
//        } else {
//            powerUp.position = player.position + CGPoint(x: 0, y: 300)
//        }
//
//        scene.addChild(powerUp)
//
//        #if DEBUG
//        debugDrawer?.drawDot(at: powerUp.position, color: .green, persist: true)
//        print("Spawned POWERUP at \(powerUp.position)")
//        #endif
//    }
//
//    private func spawnEnemy(player: Player) {
//        guard let scene = scene else { return }
//        if scene.enemies.count > 0 { return }
//
//        // Determine spawn position (safe from player/cone)
//        let spawnPosition: CGPoint
//        if let cone = player.lightCone {
//            spawnPosition = safeSpawnGenerator.generateSafeSpawnPoint(
//                spriteSize: CGSize(width: 40, height: 40),
//                minDistance: player.radius + 50,
//                cone: cone,
//                debugColor: .blue
//            )
//        } else {
//            spawnPosition = player.position + CGPoint(x: 0, y: 300)
//        }
//
//        // Decide enemy type based on difficulty or random chance
//        let difficulty = scene.difficultyManager.currentDifficulty
//        let enemy: Enemy
//
//        // Weighted random: early game mostly Easy, late game mostly Hard
////        let hardChance = min(max((difficulty - 1) / 9, 0), 1) // maps 1-10 to 0..1
////        let rand = CGFloat.random(in: 0...1)
//
//        enemy = EasyEnemy(position: spawnPosition)
////        if rand < hardChance {
////            enemy = HardEnemy(position: spawnPosition)
////        } else {
////            enemy = HardEnemy(position: spawnPosition)
////        }
//
//        // Add enemy to scene & tracking array
//        scene.addChild(enemy)
//        scene.enemies.append(enemy)
//
//        #if DEBUG
//        debugDrawer?.drawDot(at: enemy.position, color: .red, persist: true)
//        print("Spawned \(type(of: enemy)) at \(enemy.position)")
//        #endif
//    }
//
//}
