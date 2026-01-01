//
//  SpawnManager.swift
//  LightVsDark iOS
//
//  Created by chris on 12/30/25.
//

import SpriteKit

class SpawnManager {
    weak var scene: GameScene?
    let safeSpawnGenerator: SafeSpawnGenerator
    
    #if DEBUG
    private let debugDrawer: DebugDrawer?
    #endif
    
    private var lastEnemySpawnTime: TimeInterval = 0
    
    private var lastPowerUpTime: TimeInterval = 0
    private let powerUpInterval: TimeInterval = 5

    private let zoneCount = 6
    private var lastZone: Int? = nil

    init(scene: GameScene) {
        self.scene = scene
        self.safeSpawnGenerator = SafeSpawnGenerator(sceneSize: scene.size, player: scene.player)
        #if DEBUG
        self.debugDrawer = DebugDrawer(scene: scene)
        #endif
    }

    // MARK: - Update on tic
    func update(currentTime: TimeInterval, enemySpawnInterval: TimeInterval) {
        guard let scene = scene, let player = scene.player else { return }

        // obstacle spawning
        if currentTime - lastEnemySpawnTime > enemySpawnInterval {
            spawnEnemy(player: player)
            lastEnemySpawnTime = currentTime
        }
        
        // power up spawning
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
        
        if let cone = player.lightCone {
            powerUp.position = safeSpawnGenerator.generateSafeSpawnPoint(spriteSize: CGSize(width: 40, height: 40), minDistance: player.radius + 50, cone: cone, debugColor: .red)
        } else {
            powerUp.position = player.position + CGPoint(x: 0, y: 300)
        }
        
        scene.addChild(powerUp)
        
        #if DEBUG
        debugDrawer?.drawDot(at: powerUp.position, color: .red, persist: true)
        print("Spawned POWERUP at \(powerUp.position)")
        #endif
    }

    private func spawnEnemy(player: Player) {
        guard let scene = scene else { return }
        
        var spawnPosition: CGPoint
        
        if let cone = player.lightCone {
            spawnPosition = safeSpawnGenerator.generateSafeSpawnPoint(spriteSize: CGSize(width: 40, height: 40), minDistance: player.radius + 50, cone: cone, debugColor: .blue)
        } else {
            spawnPosition = player.position + CGPoint(x: 0, y: 300)
        }
        
        let enemy = EasyEnemy(position: spawnPosition)
        scene.addChild(enemy)
        scene.enemies.append(enemy)
        
        #if DEBUG
        debugDrawer?.drawDot(at: enemy.position, color: .green, persist: true)
        print("Spawned ENEMY at \(enemy.position)")
        #endif
    }
}
