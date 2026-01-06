import SpriteKit

class EdgeSkaterEnemy: Enemy {

    init(position: CGPoint) {
        let stats = EnemyStats(
            maxHealth: 15,
            baseSpeed: 40,
            attackRange: 80,
            hitRadius: 18,
            speedMultiplierRange: 0.9...1.2
        )
        
        let physics = EnemyPhysics(spriteSize: CGSize(width: 80, height: 80), body: SKPhysicsBody(circleOfRadius: 30))

        let provider = SpriteSheetAnimationProvider<EnemyState>(
            stateSheets: [
                .idle: SKTexture(imageNamed: "Warrior_Idle"),
                .moving: SKTexture(imageNamed: "Warrior_Run"),
                .takingDamage: SKTexture(imageNamed: "Warrior_Hit"),
                .dead: SKTexture(imageNamed: "Warrior_Die"),
                .attacking: SKTexture(imageNamed: "Warrior_Attack")
            ],
            rowsPerSheet: [
                .idle: 1, .moving: 1, .takingDamage: 1, .dead: 1, .attacking: 1
            ],
            columnsPerSheet: [
                .idle: 8, .moving: 6, .takingDamage: 6, .dead: 4, .attacking: 4
            ]
        )

        super.init(
            position: position,
            stats: stats,
            physics: physics,
            animationProvider: provider,
            movementStyle: .edgeSkater(offset: 50, speedVariation: 0.2)
        )

        self.name = "enemy"
    }

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}
