//
//  Player.swift
//  LightVsDark iOS
//
//  Created by chris on 12/30/25.
//

import SpriteKit

class Player: SKShapeNode {
    
    let zoneCount = 6
    var coneWidth: CGFloat { 2 * .pi / CGFloat(zoneCount) }
    var currentZone = 0
    var facingAngle: CGFloat {
        return CGFloat(currentZone) * coneWidth
    }
    
    let radius: CGFloat = 30
    
    init(position: CGPoint) {
        super.init()
        
        let radius: CGFloat = 25
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius*2, height: radius*2), transform: nil)
        self.fillColor = .white
        self.strokeColor = .clear
        self.position = position
        self.glowWidth = 5
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.categoryBitMask = PhysicsCategory.player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func rotateClockwise() {
        // Move one zone clockwise with wrap-around
        currentZone = (currentZone + 1) % zoneCount
        zRotation = facingAngle
    }
    
    func rotateCounterClockwise() {
        // Move one zone counter-clockwise
        currentZone = (currentZone - 1 + zoneCount) % zoneCount
        zRotation = facingAngle
    }
    
    func addLightCone() -> SKShapeNode {
         let cone = SKShapeNode()
         let path = CGMutablePath()
         path.move(to: .zero)
         let angle1 = facingAngle - coneWidth / 2
         let angle2 = facingAngle + coneWidth / 2
         let length: CGFloat = 200
         path.addLine(to: CGPoint(x: cos(angle1) * length, y: sin(angle1) * length))
         path.addArc(center: .zero, radius: length, startAngle: angle1, endAngle: angle2, clockwise: false)
         path.addLine(to: .zero)
         cone.path = path
         cone.fillColor = .yellow.withAlphaComponent(0.3)
         cone.strokeColor = .clear
         addChild(cone)
         return cone
     }
}

