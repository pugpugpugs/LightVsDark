import SpriteKit

class EnemyFactory {
    private var enemyCount = 0

    func spawnEnemy(at position: CGPoint = .zero) -> Enemy {
        enemyCount += 1

        switch enemyCount % 3 {
        case 0: return EasyEnemy(position: position)
        case 1: return HardEnemy(position: position)
        default: return EdgeSkaterEnemy(position: position)
        }
    }
}
