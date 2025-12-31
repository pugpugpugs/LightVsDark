//
//  Player.swift
//  LightVsDark iOS
//
//  Created by chris on 12/30/25.
//

import SpriteKit

class Player: SKShapeNode {

    // MARK: - Configuration
    let zoneCount = 6
    var anglePerZone: CGFloat { (2 * .pi) / CGFloat(zoneCount) }

    var currentZone = 0
    var facingAngle: CGFloat {
        return CGFloat(currentZone) * anglePerZone
    }
    
    private(set) var visualAngle: CGFloat = 0
    let rotationSpeed: CGFloat = 12.0 // radians per second

    let radius: CGFloat = 25
    private(set) var lightCone: SKShapeNode?

    // MARK: - Init
    init(position: CGPoint) {
        super.init()

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

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Rotation
    func rotateClockwise() {
        currentZone = (currentZone + 1) % zoneCount
        zRotation = facingAngle
        lightCone?.zRotation = 0        // cone itself stays unrotated
        showDebugZones()
    }

    func rotateCounterClockwise() {
        currentZone = (currentZone - 1 + zoneCount) % zoneCount
        zRotation = facingAngle
        lightCone?.zRotation = 0        // cone itself stays unrotated
        showDebugZones()
    }

    // MARK: - Light Cone
    func addLightCone(length: CGFloat = 220) -> SKShapeNode {
        let cone = SKShapeNode()
        let path = CGMutablePath()
        let halfWidth = tan(anglePerZone / 2) * length

        // Draw triangle along +X axis
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: length, y: -halfWidth))
        path.addLine(to: CGPoint(x: length, y: halfWidth))
        path.closeSubpath()

        cone.path = path
        cone.fillColor = .yellow.withAlphaComponent(0.25)
        cone.strokeColor = .clear

        // Rotate cone to match currentZone exactly
        cone.zRotation = facingAngle

        addChild(cone)
        self.lightCone = cone
        return cone
    }

    // MARK: - Debug Zones
    func showDebugZones(length: CGFloat = 220) {
        debugZones.forEach { $0.removeFromParent() }
        debugZones.removeAll()

        guard let parentScene = self.scene else { return }
        
        let halfWidth = tan(anglePerZone / 2) * length

        for i in 0..<zoneCount {
            let cone = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: length, y: -halfWidth))
            path.addLine(to: CGPoint(x: length, y: halfWidth))
            path.closeSubpath()
            cone.path = path

            // Unique color per zone
            cone.fillColor = UIColor(hue: CGFloat(i)/CGFloat(zoneCount), saturation: 0.6, brightness: 0.9, alpha: 0.2)
            cone.strokeColor = .clear
            cone.lineWidth = 0

            // Highlight active zone
            if i == currentZone {
                cone.fillColor = UIColor.green.withAlphaComponent(0.35)
                cone.strokeColor = UIColor.white
                cone.lineWidth = 3
            }

            // Rotate debug zone exactly like math (0 = +X)
            cone.zRotation = CGFloat(i) * anglePerZone
            cone.position = self.position
            parentScene.addChild(cone)
            debugZones.append(cone)
        }
    }


    // MARK: - Zone Detection
    func zoneIndex(for target: CGPoint) -> Int {
        let dx = target.x - position.x
        let dy = target.y - position.y
        let angleToTarget = atan2(dy, dx) // -π…π
        let normalizedAngle = angleToTarget >= 0 ? angleToTarget : angleToTarget + 2 * .pi
        return Int(normalizedAngle / anglePerZone) % zoneCount
    }

    func isPointInsideLightCone(_ point: CGPoint) -> Bool {
        let angleDiff = position.angleDiff0to2Pi(to: point, facingAngle: facingAngle)
        
        let shortestDiff = min(angleDiff, 2 * .pi - angleDiff)
        
        let graceAngle: CGFloat = (.pi / 180) * 6 // 6 degrees
        return shortestDiff <= (anglePerZone / 2) - graceAngle
    }
    
    private var debugZones: [SKShapeNode] = []

    private func colorForZone(_ index: Int) -> UIColor {
        let hue = CGFloat(index) / CGFloat(zoneCount) // evenly spaced hues
        return UIColor(hue: hue, saturation: 0.6, brightness: 0.9, alpha: 0.3)
    }
    
    func updateVisualRotation(deltaTime: CGFloat) {
        let targetAngle = facingAngle
        let delta = shortestAngleBetween(visualAngle, targetAngle)
        visualAngle += delta * min(1, rotationSpeed * deltaTime)
        zRotation = visualAngle
    }
    
    func shortestAngleBetween(_ a: CGFloat, _ b: CGFloat) -> CGFloat {
        let diff = (b - a).truncatingRemainder(dividingBy: 2 * .pi)
        return (2 * diff).truncatingRemainder(dividingBy: 2 * .pi) - diff
    }
}

