import SpriteKit

struct DifficultySettings {
    let startEnemySpeed: CGFloat
    let maxEnemySpeed: CGFloat
    let startSpawnInterval: TimeInterval
    let minSpawnInterval: TimeInterval
    let roundDuration: TimeInterval   // 30 seconds for a standard round

    static let `default` = DifficultySettings(
        startEnemySpeed: 50,
        maxEnemySpeed: 120,
        startSpawnInterval: 2.5,
        minSpawnInterval: 0.8,
        roundDuration: 30
    )
}
