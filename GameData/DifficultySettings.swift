import SpriteKit

struct DifficultySettings {
    let startEnemySpeed: CGFloat
    let maxEnemySpeed: CGFloat
    let startEnemySpawnInterval: TimeInterval
    let minEnemySpawnInterval: TimeInterval
    let roundDuration: TimeInterval   // 30 seconds for a standard round

    static let `default` = DifficultySettings(
        startEnemySpeed: 1,
        maxEnemySpeed: 3,
        startEnemySpawnInterval: 5,
        minEnemySpawnInterval: 0.8,
        roundDuration: 30
    )
}
