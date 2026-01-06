import SpriteKit

class CollisionHandler {
    // MARK: - Dependencies
    private weak var player: Player?
    private weak var playerWeapon: PlayerWeapon?
    private let powerUpManager: PowerUpManager

    // MARK: - Event closures
    var onPlayerHitByEnemy: (() -> Void)?
    var onPlayerStartAttack: ((Enemy) -> Void)?
    var onPlayerEndAttack: ((Enemy) -> Void)?

    init(player: Player, playerWeapon: PlayerWeapon, powerUpManager: PowerUpManager) {
        self.player = player
        self.playerWeapon = playerWeapon
        self.powerUpManager = powerUpManager
    }

    // MARK: - Physics Contact
    func handleBegin(contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node,
              let nodeB = contact.bodyB.node else { return }

        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        switch collision {
        case PhysicsCategory.playerWeapon | PhysicsCategory.enemy:
            if let enemy = nodeA as? Enemy ?? nodeB as? Enemy {
                onPlayerStartAttack?(enemy)
            }

        case PhysicsCategory.player | PhysicsCategory.enemy:
            break
//            onPlayerHitByEnemy?()

        case PhysicsCategory.playerWeapon | PhysicsCategory.powerUp:
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
        case PhysicsCategory.playerWeapon | PhysicsCategory.enemy:
            if let enemy = nodeA as? Enemy ?? nodeB as? Enemy {
                onPlayerEndAttack?(enemy)
            }

        default: break
        }
    }
}
