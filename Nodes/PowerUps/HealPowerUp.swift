import SpriteKit

/// Instant health recovery
class HealPowerUp: PowerUp {
    
    init() {
        let provider = SpriteSheetAnimationProvider<PowerUpState>(
            stateSheets: [
                .idle: SKTexture(imageNamed: "Water_01"),
                .expiring: SKTexture(imageNamed: "Expiring"),
                .collected: SKTexture(imageNamed: "Collected"),
                .despawning: SKTexture(imageNamed: "Despawning")
            ],
            rowsPerSheet: [
                .idle: 1, .expiring: 1, .collected: 1, .despawning: 1
            ],
            columnsPerSheet: [
                .idle: 6, .expiring: 6, .collected: 6, .despawning: 6
            ]
        )
        let size = CGSize(width: 80, height: 80)
        
        super.init(type: .heal, animationProvider: provider, size: size, duration: 5.0)
    }
}
