import SpriteKit

struct DifficultySettings {
    let startEnemySpeed: CGFloat
    let maxEnemySpeed: CGFloat
    let startSpawnInterval: TimeInterval
    let minSpawnInterval: TimeInterval
    let roundDuration: TimeInterval   // 30 seconds for a standard round

    static let `default` = DifficultySettings(
        startEnemySpeed: 1,
        maxEnemySpeed: 3,
        startSpawnInterval: 5,
        minSpawnInterval: 0.8,
        roundDuration: 30
    )
}
