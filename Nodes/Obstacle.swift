//
//  Obstacle.swift
//  LightVsDark iOS
//
//  Created by chris on 12/30/25.
//

import SpriteKit

class Obstacle: SKShapeNode {
    
    init(position: CGPoint, width: CGFloat = 50, height: CGFloat = 20) {
        super.init()
        
        let rect = CGRect(x: -width/2, y: -height/2, width: width, height: height)
        self.path = CGPath(rect: rect, transform: nil)
        self.fillColor = .red
        self.strokeColor = .clear
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move(speed: CGFloat) {
        self.position.y -= speed
    }
}

