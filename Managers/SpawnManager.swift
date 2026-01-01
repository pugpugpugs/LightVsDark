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
    
    var spawnInterval: TimeInterval = 1.5
    private var lastSpawnTime: TimeInterval = 0
    
    private var lastPowerUpTime: TimeInterval = 0
    private let powerUpInterval: TimeInterval = 5

    private let zoneCount = 6
    private var lastZone: Int? = nil

    init(scene: GameScene) {
        self.scene = scene
        self.safeSpawnGenerator = SafeSpawnGenerator(sceneSize: scene.size, player: scene.player)
    }

    // MARK: - Update on tic
    func update(currentTime: TimeInterval) {
        guard let scene = scene, let player = scene.player else { return }

        // obstacle spawning
        if currentTime - lastSpawnTime > spawnInterval {
            spawnObstacle(player: player)
            lastSpawnTime = currentTime
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
            powerUp.position = safeSpawnGenerator.generateSafeSpawnPoint(spriteSize: CGSize(width: 40, height: 40), minDistance: player.radius + 50, cone: cone)
        } else {
            powerUp.position = player.position + CGPoint(x: 0, y: 300)
        }
        
        scene.addChild(powerUp)
    }

    private func spawnObstacle(player: Player) {
        guard let scene = scene else { return }
        
        var spawnPosition: CGPoint
        
        if let cone = player.lightCone {
            spawnPosition = safeSpawnGenerator.generateSafeSpawnPoint(spriteSize: CGSize(width: 40, height: 40), minDistance: player.radius + 50, cone: cone)
        } else {
            spawnPosition = player.position + CGPoint(x: 0, y: 300)
        }
        
        let obstacle = Obstacle(position: spawnPosition)
        scene.addChild(obstacle)
        scene.obstacles.append(obstacle)
    }
}
