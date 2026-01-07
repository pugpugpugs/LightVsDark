import SpriteKit

class SpawnManager {
    let enemyFactory: EnemyFactory
    let safeSpawnGenerator: SafeSpawnGenerator
    
    private var lastSpawnTime: TimeInterval = 0
    var enemySpawnInterval: TimeInterval = 2.0
    
    var onEnemyReady: ((Enemy) -> Void)?

    init(enemyFactory: EnemyFactory, safeSpawnGenerator: SafeSpawnGenerator) {
        self.enemyFactory = enemyFactory
        self.safeSpawnGenerator = safeSpawnGenerator
    }

    func update(currentTime: TimeInterval) {
        if currentTime - lastSpawnTime >= enemySpawnInterval {
            lastSpawnTime = currentTime
            let enemy = createEnemy()
            onEnemyReady?(enemy)
        }
    }

    private func createEnemy() -> Enemy {
        // Generate spawn point AFTER creating enemy
        let enemy = enemyFactory.spawnEnemy()
        enemy.position = safeSpawnGenerator.generateSafeSpawnPoint(spriteSize: enemy.sprite.size)
        return enemy
    }
    
    func stop() {
        lastSpawnTime = 0
        onEnemyReady = nil
    }
}
