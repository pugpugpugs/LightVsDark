import SpriteKit

protocol PlayerWeapon: PowerUpAccepting {
    var owner: Player? { get set }

    // Called each frame
    func update(deltaTime: CGFloat)

    // Called when the player attacks or rotates
    func startAttack(on enemy: Enemy)
    
    func endAttack(on enemy: Enemy)
    
    // Optional: some visual representation
    var node: SKNode { get }
}
