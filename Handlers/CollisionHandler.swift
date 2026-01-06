import SpriteKit

class CollisionHandler {
    // MARK: - Dependencies
    private weak var player: Player?
    private weak var lightCone: LightCone?
    private let powerUpManager: PowerUpManager

    // MARK: - Event closures
    var onPlayerHitByEnemy: (() -> Void)?
    var onEnemyEnteredCone: ((Enemy) -> Void)?
    var onEnemyExitedCone: ((Enemy) -> Void)?

    init(player: Player, lightCone: LightCone, powerUpManager: PowerUpManager) {
        self.player = player
        self.lightCone = lightCone
        self.powerUpManager = powerUpManager
    }

    // MARK: - Physics Contact
    func handleBegin(contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node,
              let nodeB = contact.bodyB.node else { return }

        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        switch collision {
        case PhysicsCategory.lightCone | PhysicsCategory.enemy:
            if let enemy = nodeA as? Enemy ?? nodeB as? Enemy {
                onEnemyEnteredCone?(enemy)
            }

        case PhysicsCategory.player | PhysicsCategory.enemy:
            break
//            onPlayerHitByEnemy?()

        case PhysicsCategory.lightCone | PhysicsCategory.powerUp:
            if let powerUp = nodeA as? PowerUp ?? nodeB as? PowerUp {
//                powerUpManager.collect(powerUp)
            }

        default: break
        }
    }

    func handleEnd(contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node,
              let nodeB = contact.bodyB.node else { return }

        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        switch collision {
        case PhysicsCategory.lightCone | PhysicsCategory.enemy:
            if let enemy = nodeA as? Enemy ?? nodeB as? Enemy {
                onEnemyExitedCone?(enemy)
            }

        default: break
        }
    }
}
