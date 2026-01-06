import SpriteKit

struct EnemyStats {
    let maxHealth: CGFloat
    let baseSpeed: CGFloat
    let attackRange: CGFloat
    let hitRadius: CGFloat
    let speedMultiplierRange: ClosedRange<CGFloat>
}
