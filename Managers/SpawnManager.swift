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
    
    private var lastEnemySpawnTime: TimeInterval = 0
    
    private var lastPowerUpTime: TimeInterval = 0
    private let powerUpInterval: TimeInterval = 5

    private let zoneCount = 6
    private var lastZone: Int? = nil

    init(scene: GameScene) {
        self.scene = scene
        self.safeSpawnGenerator = SafeSpawnGenerator(sceneSize: scene.size, player: scene.player)
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
     
        let powerUp = PowerUp(type: .widenCone, duration: 3.0, size: CGSize(width: 40, height: 40))
        
        if let cone = player.lightCone {
            powerUp.position = safeSpawnGenerator.generateSafeSpawnPoint(spriteSize: CGSize(width: 40, height: 40), minDistance: player.radius + 50, cone: cone, debugColor: .red)
        } else {
            powerUp.position = player.position + CGPoint(x: 0, y: 300)
        }
        
        scene.addChild(powerUp)
        
        // DEBUG: log spawn
        print("Spawned POWERUP at \(powerUp.position)")
        
        #if DEBUG
        let debugDot = SKShapeNode(circleOfRadius: 5)
        debugDot.position = powerUp.position
        debugDot.fillColor = .yellow
        debugDot.strokeColor = .clear
        debugDot.zPosition = 50
        scene.addChild(debugDot)
        
        // Remove after a short time
        debugDot.run(SKAction.sequence([.wait(forDuration: 1.0), .removeFromParent()]))
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
        
        // DEBUG: log spawn
           print("Spawned ENEMY at \(enemy.position)")
           
           #if DEBUG
           let debugDot = SKShapeNode(circleOfRadius: 5)
           debugDot.position = enemy.position
           debugDot.fillColor = .red
           debugDot.strokeColor = .clear
           debugDot.zPosition = 50
           scene.addChild(debugDot)
           
           // Remove after a short time
           debugDot.run(SKAction.sequence([.wait(forDuration: 1.0), .removeFromParent()]))
           #endif
    }
}
