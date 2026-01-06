import SpriteKit

// MARK: - Player Factory
struct PlayerFactory {

    static func createDefaultPlayer(at position: CGPoint) -> Player {
        // MARK: - Stats
        let stats = PlayerStats(
            maxHealth: 3,
            maxSpinSpeed: .pi,
            spinAcceleration: .pi * 4,
            spinDecay: 6.0
        )
        let playerPhysics = PlayerPhysics(spriteSize: CGSize(width: 80, height: 80), body: SKPhysicsBody(circleOfRadius: 30))

        // MARK: - Physics

        // MARK: - Animation Provider
        let animationProvider = SpriteSheetAnimationProvider<PlayerState>(
            stateSheets: [
                .attacking: SKTexture(imageNamed: "Archer_Idle"),
                .dead: SKTexture(imageNamed: "Archer_Shoot"),
            ],
            rowsPerSheet: [.attacking: 1, .dead: 1],
            columnsPerSheet: [.attacking: 6, .dead: 8]
        )

        // MARK: - Player
        let player = Player(
            position: position,
            stats: stats,
            playerPhysics: playerPhysics,
            animationProvider: animationProvider
        )
        
        let lightCone = LightCone()
        
        player.equipWeapon(lightCone)

        return player
    }
}
