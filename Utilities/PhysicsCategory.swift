//
//  PhysicsCategory.swift
//  LightVsDark iOS
//
//  Created by chris on 12/30/25.
//

struct PhysicsCategory {
    static let player: UInt32 = 0x1 << 0
    static let enemy: UInt32 = 0x1 << 1
    static let lightCone: UInt32 = 0x1 << 2
    static let powerUp: UInt32 = 0x1 << 3
}
