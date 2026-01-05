import SpriteKit

final class SpawnManager {

    private let enemyFactory: EnemyFactory
    private let safeSpawnGenerator: SafeSpawnGenerator

    private var lastEnemySpawnTime: TimeInterval = 0
    private let enemySpawnInterval: TimeInterval = 2.0

    private var lastPowerUpTime: TimeInterval = 0
    private let powerUpInterval: TimeInterval = 10.0

    init(enemyFactory: EnemyFactory, safeSpawnGenerator: SafeSpawnGenerator) {
        self.enemyFactory = enemyFactory
        self.safeSpawnGenerator = safeSpawnGenerator
    }

    // Called each frame from GameScene
    func update(currentTime: TimeInterval) -> Enemy? {
        var spawnedEnemy: Enemy? = nil

        if currentTime - lastEnemySpawnTime > enemySpawnInterval {
            let enemy = enemyFactory.spawnEnemy()

            let spawnPos = safeSpawnGenerator.generateSafeSpawnPoint(spriteSize: enemy.sprite.size)
                                                                     
            enemy.position = spawnPos
            
            lastEnemySpawnTime = currentTime
            
            return enemy
        }

        return nil
//        // Power-ups can be handled similarly
//        if currentTime - lastPowerUpTime > powerUpInterval {
//            lastPowerUpTime = currentTime
//            // Return nil here; scene can call separate method for power-up spawning
//        }
    }
}
