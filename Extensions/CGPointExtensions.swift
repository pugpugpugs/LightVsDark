//
//  CGPointExtensions.swift
//  LightVsDark iOS
//
//  Created by chris on 12/30/25.
//

import CoreGraphics

extension CGPoint {

    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - x
        let dy = point.y - y
        return sqrt(dx*dx + dy*dy)
    }

    /// Signed angle difference [-π, π] — for shortest rotation
    func signedAngleDiff(to target: CGPoint, facingAngle: CGFloat) -> CGFloat {
        let dx = target.x - x
        let dy = target.y - y
        let angleToTarget = atan2(dy, dx)
        let diff = angleToTarget - facingAngle
        return atan2(sin(diff), cos(diff)) // normalized to [-π, π]
    }

    /// Positive angle difference [0, 2π] — for zone checks
    func angleDiff0to2Pi(to target: CGPoint, facingAngle: CGFloat) -> CGFloat {
        let dx = target.x - x
        let dy = target.y - y
        var diff = atan2(dy, dx) - facingAngle
        if diff < 0 { diff += 2 * .pi }
        return diff
    }

    func normalized() -> CGPoint {
        let length = sqrt(x*x + y*y)
        guard length > 0 else { return .zero }
        return CGPoint(x: x / length, y: y / length)
    }

    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint { CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint { CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y) }
    static func *(point: CGPoint, scalar: CGFloat) -> CGPoint { CGPoint(x: point.x * scalar, y: point.y * scalar) }
    static func +=(lhs: inout CGPoint, rhs: CGPoint) { lhs = lhs + rhs }
}


