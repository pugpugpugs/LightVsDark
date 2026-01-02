import SpriteKit

class PowerUpManager {
    private weak var cone: LightCone?
    private weak var player: Player?
    private var enemies: [Enemy]

    init(cone: LightCone?, player: Player?, enemies: [Enemy]) {
        self.cone = cone
        self.player = player
        self.enemies = enemies
    }

    func collect(_ powerUp: PowerUp, sceneTime: TimeInterval) {
        powerUp.removeFromParent() // Remove node from scene

        switch powerUp.type {
        case .widenCone:
            guard let cone = cone else { return }
            cone.applyPowerUp(
                lengthBoost: cone.baseLength * 0.5,
                angleBoost: cone.baseAngle * 0.5
            )
        case .speedBoost:
            player?.spinSpeedMultiplier *= 1.5
        case .slowEnemies:
            enemies.forEach { $0.speedMultiplier *= 0.5 }
        }

        // Track expiration
        powerUp.expirationTime = sceneTime + powerUp.duration
    }
}
