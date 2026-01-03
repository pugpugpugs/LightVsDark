import SpriteKit

class CollisionHandler {
    weak var scene: GameScene?
    var powerUpManager: PowerUpManager

    init(scene: GameScene, powerUpManager: PowerUpManager) {
        self.scene = scene
        self.powerUpManager = powerUpManager
    }

    private lazy var beginHandlers: [UInt32: (SKNode, SKNode) -> Void] = [
        PhysicsCategory.lightCone | PhysicsCategory.enemy: { [weak self] nodeA, nodeB in
            guard let self = self, let scene = self.scene, let cone = scene.player.lightCone else { return }

            let enemyNode = nodeA.physicsBody?.categoryBitMask == PhysicsCategory.enemy ? nodeA : nodeB
            guard let enemy = enemyNode as? Enemy else { return }
            cone.enemyEnteredCone(enemy)
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
    
    private lazy var endHandlers: [UInt32: (SKNode, SKNode) -> Void] = [
        PhysicsCategory.lightCone | PhysicsCategory.enemy: { [weak self] nodeA, nodeB in
            guard let self = self, let scene = self.scene, let cone = scene.player.lightCone else { return }

            let enemyNode = nodeA.physicsBody?.categoryBitMask == PhysicsCategory.enemy ? nodeA : nodeB
            guard let enemy = enemyNode as? Enemy else { return }
            
            print("exited cone")

            cone.enemyExitedCone(enemy)
        }
    ]

    func handleBegin(contact: SKPhysicsContact) {
        print("handle begin")
        guard let nodeA = contact.bodyA.node,
              let nodeB = contact.bodyB.node else { return }

        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        beginHandlers[collision]?(nodeA, nodeB)
    }

    func handleEnd(contact: SKPhysicsContact) {
        print("handle end")
        guard let nodeA = contact.bodyA.node,
              let nodeB = contact.bodyB.node else { return }

        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        endHandlers[collision]?(nodeA, nodeB)
    }

}
