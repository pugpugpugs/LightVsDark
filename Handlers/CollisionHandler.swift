import SpriteKit

class CollisionHandler {
    weak var scene: GameScene?
    var powerUpManager: PowerUpManager

    init(scene: GameScene, powerUpManager: PowerUpManager) {
        self.scene = scene
        self.powerUpManager = powerUpManager
    }

    private lazy var handlers: [UInt32: (SKNode, SKNode) -> Void] = [
        PhysicsCategory.lightCone | PhysicsCategory.enemy: { [weak self] nodeA, nodeB in
            guard let self = self, let scene = self.scene, let cone = scene.player.lightCone else { return }

            let enemyNode = nodeA.physicsBody?.categoryBitMask == PhysicsCategory.enemy ? nodeA : nodeB
            guard let enemy = enemyNode as? Enemy else { return }
            
//            enemy.applyDamage(deltaTime: <#T##CGFloat#>, enemies: <#T##[Enemy]#>)
        },

        PhysicsCategory.player | PhysicsCategory.enemy: { [weak self] _, _ in
            self?.scene?.gameOver()
        },

        PhysicsCategory.lightCone | PhysicsCategory.powerUp: { [weak self] nodeA, nodeB in
            guard let self = self, let scene = self.scene else { return }
            guard let powerUp = nodeA as? PowerUp ?? nodeB as? PowerUp else { return }

            // Forward collision to manager
            self.powerUpManager.collect(powerUp, sceneTime: scene.sceneTime)
        }
    ]

    func handle(contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        handlers[collision]?(nodeA, nodeB)
    }
}
