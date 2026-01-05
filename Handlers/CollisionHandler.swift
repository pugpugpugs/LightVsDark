import SpriteKit

class CollisionHandler {
    weak var lightCone: LightCone?
    weak var player: Player?
    weak var powerUpManager: PowerUpManager?

    init(player: Player, lightCone: LightCone, powerUpManager: PowerUpManager) {
        self.player = player
        self.lightCone = lightCone
        self.powerUpManager = powerUpManager
    }

    private lazy var beginHandlers: [UInt32: (SKNode, SKNode) -> Void] = [
        PhysicsCategory.lightCone | PhysicsCategory.enemy: { [weak self] nodeA, nodeB in
            guard let cone = self?.lightCone else { return }

            let enemyNode = nodeA.physicsBody?.categoryBitMask == PhysicsCategory.enemy ? nodeA : nodeB
            guard let enemy = enemyNode as? Enemy else { return }
            cone.enemyEnteredCone(enemy)
        },

        PhysicsCategory.player | PhysicsCategory.enemy: { [weak self] nodeA, nodeB in
            let enemyNode = nodeA.physicsBody?.categoryBitMask == PhysicsCategory.enemy ? nodeA : nodeB
            guard let enemy = enemyNode as? Enemy else { return }
            
            enemy.stateMachine.enter(.attacking)
        },

//        PhysicsCategory.lightCone | PhysicsCategory.powerUp: { [weak self] nodeA, nodeB in
//            guard let cone = self?.lightCone else { return }
//            guard let powerUp = nodeA as? PowerUp ?? nodeB as? PowerUp else { return }
//
//            // Forward collision to manager
//            self.powerUpManager.collect(powerUp, sceneTime: scene.sceneTime)
//        }
    ]
    
    private lazy var endHandlers: [UInt32: (SKNode, SKNode) -> Void] = [
        PhysicsCategory.lightCone | PhysicsCategory.enemy: { [weak self] nodeA, nodeB in
            guard let cone = self?.lightCone else { return }

            let enemyNode = nodeA.physicsBody?.categoryBitMask == PhysicsCategory.enemy ? nodeA : nodeB
            guard let enemy = enemyNode as? Enemy else { return }

            cone.enemyExitedCone(enemy)
        }
    ]

    func handleBegin(contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node,
              let nodeB = contact.bodyB.node else { return }

        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        beginHandlers[collision]?(nodeA, nodeB)
    }

    func handleEnd(contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node,
              let nodeB = contact.bodyB.node else { return }

        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        endHandlers[collision]?(nodeA, nodeB)
    }

}
