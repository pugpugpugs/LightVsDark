import SpriteKit

class DifficultyManager {
    // Enemy difficulty
    private(set) var enemySpeed: CGFloat          // base enemy movement speed
    private(set) var enemySpawnInterval: TimeInterval // interval between enemy spawns
    private let enemySpawnIntervalMin: TimeInterval   // minimum spawn interval
    
    private let enemyRampRate: CGFloat            // speed increase per ramp interval
    private let enemySpawnDecrease: TimeInterval  // amount to decrease spawn interval per ramp
    private let rampInterval: TimeInterval       // how often to ramp
    
    private var elapsedTime: TimeInterval = 0
    private var lastRampTime: TimeInterval = 0
    
    init(
        initialSpeed: CGFloat,
        initialSpawnInterval: TimeInterval,
        spawnIntervalMin: TimeInterval,
        rampRate: CGFloat,
        spawnDecrease: TimeInterval,
        rampInterval: TimeInterval = 10.0
    ) {
        self.enemySpeed = initialSpeed
        self.enemySpawnInterval = initialSpawnInterval
        self.enemySpawnIntervalMin = spawnIntervalMin
        self.enemyRampRate = rampRate
        self.enemySpawnDecrease = spawnDecrease
        self.rampInterval = rampInterval
    }
    
    // MARK: - Update called each frame
    func update(deltaTime: TimeInterval) {
        elapsedTime += deltaTime
        
        // Ramp difficulty every rampInterval
        if elapsedTime - lastRampTime >= rampInterval {
            lastRampTime = elapsedTime
            
            // Increase enemy speed
            enemySpeed += enemyRampRate
            
            // Decrease spawn interval but clamp to minimum
            enemySpawnInterval = max(enemySpawnIntervalMin, enemySpawnInterval - enemySpawnDecrease)
        }
    }
}
