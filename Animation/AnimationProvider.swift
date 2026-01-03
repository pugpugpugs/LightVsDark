import SpriteKit

protocol AnimationProvider {
    func frames(for state: EnemyState) -> [SKTexture]
}
