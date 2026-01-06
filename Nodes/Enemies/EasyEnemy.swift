import SpriteKit

class EasyEnemy: Enemy {
    init(position: CGPoint) {
        let stats = EnemyStats(
            maxHealth: 10,
            baseSpeed: 35,
            attackRange: 50,
            hitRadius: 16,
            speedMultiplierRange: 0.8...1.3
        )
        
        let physics = EnemyPhysics(spriteSize: CGSize(width: 80, height: 80), body: SKPhysicsBody(circleOfRadius: 30))

        let provider = SpriteSheetAnimationProvider<EnemyState>(
            stateSheets: [
                .idle: SKTexture(imageNamed: "Pawn_Idle"),
                .moving: SKTexture(imageNamed: "Pawn_Run"),
                .takingDamage: SKTexture(imageNamed: "Pawn_Run_Knife"),
                .dead: SKTexture(imageNamed: "Pawn_Run_Gold"),
                .attacking: SKTexture(imageNamed: "Pawn_Interact_Axe")
            ],
            rowsPerSheet: [.idle: 1, .moving: 1, .takingDamage: 1, .dead: 1, .attacking: 1],
            columnsPerSheet: [.idle: 8, .moving: 6, .takingDamage: 6, .dead: 6, .attacking: 6]
        )

        super.init(position: position, stats: stats, physics: physics, animationProvider: provider)
        self.name = "enemy"
    }

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}
