//
//  GameScene.swift
//  LightVsDark iOS
//
//  Created by chris on 12/30/25.
//

import SpriteKit

class GameScene: SKScene {
    
    // MARK: - Properties
    var player: Player!
    var spawnManager: SpawnManager!
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        // Create player in center
        player = Player(position: CGPoint(x: frame.midX, y: frame.midY))
        addChild(player)
        _ = player.addLightCone()
        
        // Initialize spawn manager
        spawnManager = SpawnManager(scene: self)
    }
    
    // MARK: - Touch Input
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.flipDirection()
    }
    
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        // Spawn obstacles
        spawnManager.update(currentTime: currentTime)
        
        // Move obstacles and remove off-screen
        for node in children {
            if let obstacle = node as? Obstacle {
                obstacle.move(speed: 3)
                
                if obstacle.position.y < -50 {
                    obstacle.removeFromParent()
                }
            }
        }
    }
}

