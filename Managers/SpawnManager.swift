//
//  SpawnManager.swift
//  LightVsDark iOS
//
//  Created by chris on 12/30/25.
//

import SpriteKit

class SpawnManager {
    weak var scene: GameScene?
    var lastSpawnTime: TimeInterval = 0
    var spawnInterval: TimeInterval = 1.0
    let spawnDistance: CGFloat = 300

    init(scene: GameScene) {
        self.scene = scene
    }

    func update(currentTime: TimeInterval) {
        
        if currentTime - lastSpawnTime > spawnInterval {
            spawnObstacle()
            lastSpawnTime = currentTime
        }
    }

    private func spawnObstacle() {
        guard let scene = scene else { return }
        guard let player = scene.player else { return }
        
        // Random angle around the player
        let angle = CGFloat.random(in: 0 ..< .pi * 2)
        let xPos = player.position.x + cos(angle) * spawnDistance
        let yPos = player.position.y + sin(angle) * spawnDistance
        
        let obstacle = Obstacle(position:  CGPoint(x: xPos, y: yPos))
        
        scene.addChild(obstacle)
        scene.obstacles.append(obstacle)
    }
}

