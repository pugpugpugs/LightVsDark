//
//  CGPointExtensions.swift
//  LightVsDark iOS
//
//  Created by chris on 12/30/25.
//

import CoreGraphics

extension CGPoint {
    
    func vector(to point: CGPoint) -> CGVector {
        return CGVector(dx: point.x - x, dy: point.y - y)
    }
    
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - x
        let dy = point.y - y
        return sqrt(dx*dx + dy*dy)
    }
    
    func angle(to point: CGPoint) -> CGFloat {
        let dx = point.x - x
        let dy = point.y - y
        return atan2(dy, dx)
    }
    
    // Returns distance and angle difference (radians) to a target point
    func distanceAndAngleDiff(to target: CGPoint, facingAngle: CGFloat) -> (distance: CGFloat, angleDiff: CGFloat) {
        let dx = target.x - x
        let dy = target.y - y
        let distance = sqrt(dx*dx + dy*dy)
        let angleToTarget = atan2(dy, dx)
        var angleDiff = angleToTarget - facingAngle
        angleDiff = atan2(sin(angleDiff), cos(angleDiff)) // normalize to [-π, π]
        return (distance, angleDiff)
    }
}
