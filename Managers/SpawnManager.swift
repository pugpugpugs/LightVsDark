//
//  SpawnManager.swift
//  LightVsDark iOS
//
//  Created by chris on 12/30/25.
//

import SpriteKit

class SpawnManager {
    
    var scene: SKScene
    var spawnInterval: TimeInterval = 1.0
    var lastSpawnTime: TimeInterval = 0
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func update(currentTime: TimeInterval) {
        if currentTime - lastSpawnTime > spawnInterval {
            spawnObstacle()
            lastSpawnTime = currentTime
        }
    }
    
    func spawnObstacle() {
        let xPos = CGFloat.random(in: 50...(scene.size.width - 50))
        let yPos = scene.size.height + 20
        let obstacle = Obstacle(position: CGPoint(x: xPos, y: yPos))
        scene.addChild(obstacle)
    }
}

