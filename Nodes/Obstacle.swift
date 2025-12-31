//
//  Obstacle.swift
//  LightVsDark iOS
//
//  Created by chris on 12/30/25.
//

import SpriteKit

class Obstacle: SKShapeNode {
    
    var targetAngle: CGFloat = 0
    var type: ObstacleType = .light
    
    init(position: CGPoint, width: CGFloat = 50, height: CGFloat = 20) {
        super.init()
        
        let rect = CGRect(x: -width/2, y: -height/2, width: width, height: height)
        self.path = CGPath(rect: rect, transform: nil)
        self.fillColor = .red
        self.strokeColor = .clear
        self.position = position
        
        self.physicsBody = SKPhysicsBody(rectangleOf: rect.size)
        self.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.isDynamic = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveTowardPlayer(playerPosition: CGPoint, speed: CGFloat) {
        let dx = playerPosition.x - position.x
        let dy = playerPosition.y - position.y
        let distance = sqrt(dx*dx + dy*dy)
        
        guard distance > 0 else { return }
        
        position.x += (dx / distance) * speed
        position.y += (dy / distance) * speed
    }
}

