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

        // First spawn logic
        if lastSpawnTime == 0 && currentTime < firstSpawnDelay { return }
        
        // Only allow spawn if no active power-up on scene
        guard activePowerUpsOnScene.isEmpty else { return }

        // Check spawn interval
        guard currentTime - lastSpawnTime >= spawnInterval else { return }

        guard let powerUp = factory.makeRandom(from: candidateTypes) else { return }

        let position = safeSpawnGenerator.generateSafeSpawnPoint(spriteSize: powerUp.node.size)

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
