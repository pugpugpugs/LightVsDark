import SpriteKit

class EdgeSkaterEnemy: Enemy {

    init(position: CGPoint) {
        let provider = SpriteSheetAnimationProvider(
            stateSheets: [
                .idle: SKTexture(imageNamed: "Warrior_Idle"),
                .moving: SKTexture(imageNamed: "Warrior_Run"),
                .takingDamage: SKTexture(imageNamed: "Warrior_Hit"),
                .dead: SKTexture(imageNamed: "Warrior_Die"),
                .attacking: SKTexture(imageNamed: "Warrior_Attack")
            ],
            rowsPerSheet: [
                .idle: 1,
                .moving: 1,
                .takingDamage: 1,
                .dead: 1,
                .attacking: 1
            ],
            columnsPerSheet: [
                .idle: 8,
                .moving: 6,
                .takingDamage: 6,
                .dead: 4,
                .attacking: 4
            ]
        )
        super.init(position: position, animationProvider: provider, movementStyle: .edgeSkater(offset: 50, speedVariation: 0.2), spriteSize: CGSize(width: 80, height: 80), attackRange: 20)
        self.name = "enemy"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
