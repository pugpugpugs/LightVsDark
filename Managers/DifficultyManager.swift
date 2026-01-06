import SpriteKit

class DifficultyManager {
    private let settings: DifficultySettings
    private var elapsedTime: TimeInterval = 0
    
    var onSpawnIntervalChange: ((TimeInterval) -> Void)?
    var onEnemySpeedChange: ((CGFloat) -> Void)?

    // Computed properties for current frame
    var enemySpeed: CGFloat {
        // Linear interpolation from start to max speed
        let t = min(elapsedTime / settings.roundDuration, 1)
        return settings.startEnemySpeed + (settings.maxEnemySpeed - settings.startEnemySpeed) * CGFloat(t)
    }
    
    var enemySpawnInterval: TimeInterval {
        let t = min(elapsedTime / settings.roundDuration, 1)
        return settings.startSpawnInterval - (settings.startSpawnInterval - settings.minSpawnInterval) * t
    }
    
    var currentDifficulty: CGFloat {
        // 1..10 scale based on elapsed time fraction
        let fraction = min(elapsedTime / settings.roundDuration, 1)
        return 1 + fraction * 9
    }
    
    init(settings: DifficultySettings = .default) {
        self.settings = settings
    }
    
    func update(deltaTime: TimeInterval) {
        elapsedTime += deltaTime
        onSpawnIntervalChange?(enemySpawnInterval)
        onEnemySpeedChange?(enemySpeed)
    }
    
    func reset() {
        elapsedTime = 0
    }
}
