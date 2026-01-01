import SpriteKit

class CollisionHandler {
    weak var scene: GameScene?
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    // MARK: - Collision Handlers
    private lazy var handlers: [UInt32: (SKNode, SKNode) -> Void] = [
        PhysicsCategory.lightCone | PhysicsCategory.enemy: { [weak self] nodeA, nodeB in
            guard let self = self, let scene = self.scene else { return }
            
            let enemy = nodeA.physicsBody?.categoryBitMask == PhysicsCategory.enemy ? nodeA : nodeB
            enemy.removeFromParent()
            scene.enemies.removeAll { $0 === enemy }
        },
        
        PhysicsCategory.player | PhysicsCategory.enemy: { [weak self] _, _ in
            self?.scene?.gameOver()
        },
        
        PhysicsCategory.lightCone | PhysicsCategory.powerUp: { [weak self] nodeA, nodeB in
            guard let self = self, let scene = self.scene, let player = scene.player else { return }
            
            let lightConeNode = nodeA.physicsBody?.categoryBitMask == PhysicsCategory.lightCone ? nodeA : nodeB
            let powerUpNode = nodeA.physicsBody?.categoryBitMask == PhysicsCategory.powerUp ? nodeA : nodeB
            
            guard let lightCone = lightConeNode as? LightCone,
                  let powerUp = powerUpNode as? PowerUp
            else { return }
            
            powerUp.apply(to: player, in: scene)
            powerUp.removeFromParent()
        }
    ]
    
    // MARK: - Public
    func handle(contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        handlers[collision]?(nodeA, nodeB)
    }
}
