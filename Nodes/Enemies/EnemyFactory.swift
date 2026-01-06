import SpriteKit

class EnemyFactory {
    private var enemyCount = 0

    private let enemyConstructors: [(CGPoint) -> Enemy] = [
        { EasyEnemy(position: $0) },
        { HardEnemy(position: $0) },
        { EdgeSkaterEnemy(position: $0) }
    ]

    func spawnEnemy(at position: CGPoint = .zero) -> Enemy {
        let constructor = enemyConstructors[enemyCount % enemyConstructors.count]
        enemyCount += 1
        return constructor(position)
    }
}
