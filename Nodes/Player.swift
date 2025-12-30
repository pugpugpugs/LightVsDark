//
//  Player.swift
//  LightVsDark iOS
//
//  Created by chris on 12/30/25.
//

import SpriteKit

class Player: SKShapeNode {
    
    init(position: CGPoint) {
        super.init()
        
        let radius: CGFloat = 25
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius*2, height: radius*2), transform: nil)
        self.fillColor = .white
        self.strokeColor = .clear
        self.position = position
        self.glowWidth = 5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func flipDirection() {
        self.zRotation += .pi
    }
    
    func addLightCone() -> SKShapeNode {
        let cone = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: -30, y: 150))
        path.addLine(to: CGPoint(x: 30, y: 150))
        path.closeSubpath()
        
        cone.path = path
        cone.fillColor = .white.withAlphaComponent(0.3)
        cone.strokeColor = .clear
        
        self.addChild(cone)
        return cone
    }
}

