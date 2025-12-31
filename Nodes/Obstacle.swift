//
//  Obstacle.swift
//  LightVsDark iOS
//
//  Created by chris on 12/30/25.
//

import SpriteKit

class Obstacle: SKShapeNode {

    let speedMultiplier: CGFloat
    let zoneIndex: Int

    init(position: CGPoint, zoneIndex: Int, width: CGFloat = 50, height: CGFloat = 20) {
        self.speedMultiplier = CGFloat.random(in: 0.8...1.3)
        self.zoneIndex = zoneIndex

        super.init()

        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        path = CGPath(rect: rect, transform: nil)

        fillColor = .red
        strokeColor = .clear
        self.position = position

        physicsBody = SKPhysicsBody(rectangleOf: rect.size)
        physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func moveTowardPlayer(
        playerPosition: CGPoint,
        baseSpeed: CGFloat,
        deltaTime: CGFloat
    ) {
        let direction = (playerPosition - position).normalized()
        position += direction * baseSpeed * speedMultiplier * deltaTime
    }

}


