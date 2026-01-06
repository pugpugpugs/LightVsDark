import SpriteKit

class EnemyManager {
    private(set) var enemies: [Enemy] = []

    var render: ((Enemy) -> Void)?
    var count: Int { enemies.count }
    var activeEnemies: [Enemy] { enemies }

    // MARK: - Add / Remove Enemies
    func add(enemy: Enemy) {
        enemies.append(enemy)
        
        render?(enemy)

        // Setup destruction callback
        enemy.onDestroyed = { [weak self, weak enemy] in
            guard let self = self, let enemy = enemy else { return }
            self.remove(enemy: enemy)
        }
    }

    func remove(enemy: Enemy) {
        enemies.removeAll { $0 === enemy }
    }
    
    func removeAll() {
        for enemy in enemies {
            enemy.onDestroyed = nil
            enemy.removeFromParent()
        }
        enemies.removeAll()
    }

    // MARK: - Update Loop
    func update(deltaTime: CGFloat, playerPosition: CGPoint) {
        for enemy in enemies {
            enemy.update(deltaTime: deltaTime, targetPosition: playerPosition)
        }
    }

    // MARK: - Mass Updates
    func updateAllEnemiesSpeedMultiplier(to: CGFloat) {
        for enemy in enemies {
            enemy.speedMultiplier = to
        }
    }
}
