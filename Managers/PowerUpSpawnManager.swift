import SpriteKit

final class PowerUpSpawnManager {
    var onSpawn: ((PowerUp, CGPoint) -> Void)?

    private let factory: PowerUpFactory
    private let safeSpawnGenerator: SafeSpawnGenerator
    private var lastSpawnTime: TimeInterval = 0
    private var spawnInterval: TimeInterval = 5.0
    private var firstSpawnDelay: TimeInterval = 1.0

    private(set) var activePowerUpsOnScene: [PowerUp] = []

    init(factory: PowerUpFactory, safeSpawnGenerator: SafeSpawnGenerator) {
        self.factory = factory
        self.safeSpawnGenerator = safeSpawnGenerator
    }

    func update(currentTime: TimeInterval, candidateTypes: [PowerUpType]) {
        guard !candidateTypes.isEmpty else { return }
        
        for powerUp in activePowerUpsOnScene {
            powerUp.update(currentTime: currentTime)
            
            if powerUp.state == .despawning && powerUp.node.parent == nil {
                if let index = activePowerUpsOnScene.firstIndex(where: { $0 === powerUp }) {
                    activePowerUpsOnScene.remove(at: index)
                }
            }
        }
        
        guard !candidateTypes.isEmpty else { return }

        // First spawn logic
        if lastSpawnTime == 0 && currentTime < firstSpawnDelay { return }
        
        // Only allow spawn if no active power-up on scene
        guard activePowerUpsOnScene.isEmpty else { return }

        // Check spawn interval
        guard currentTime - lastSpawnTime >= spawnInterval else { return }

        guard let powerUp = factory.makeRandom(from: candidateTypes) else { return }

        let position = safeSpawnGenerator.generateSafeSpawnPoint(spriteSize: powerUp.node.size)
        
        powerUp.onRemoved = { [weak self, weak powerUp] in
            guard let self = self, let powerUp = powerUp else { return }
            powerUp.node.removeFromParent()
            self.activePowerUpsOnScene.removeAll { $0 === powerUp }
        }

        activePowerUpsOnScene.append(powerUp)
        onSpawn?(powerUp, position)

        lastSpawnTime = currentTime
    }

    func notifyPowerUpCollected(currentTime: TimeInterval) {
        activePowerUpsOnScene.removeAll()
        lastSpawnTime = currentTime
    }

    func updateSpawnInterval(_ interval: TimeInterval) {
        spawnInterval = interval
    }
}
