import SpriteKit

/// Narrow the player’s light cone temporarily but more damage
class NarrowConePowerUp: PowerUp {
    init() {
        let provider = SpriteSheetAnimationProvider<PowerUpState>(
            stateSheets: [
                .idle: SKTexture(imageNamed: "Fire_01"),
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
        
        super.init(type: .narrowCone, animationProvider: provider, size: size, effectDuration: 5.0)
    }
}
