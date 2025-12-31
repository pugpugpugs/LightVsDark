//
//  CGVectorExtensions.swift
//  LightVsDark iOS
//
//  Created by chris on 12/31/25.
//

import CoreGraphics

extension CGVector {
    var length: CGFloat { sqrt(dx*dx + dy*dy) }
    func normalized() -> CGVector {
        let len = length
        return len > 0 ? CGVector(dx: dx/len, dy: dy/len) : CGVector.zero
    }
    func dot(_ other: CGVector) -> CGFloat { dx*other.dx + dy*other.dy }
}
