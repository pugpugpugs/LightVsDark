import SpriteKit

class EdgeSkaterEnemy: Enemy {

    init(position: CGPoint) {
        let sheet = SKTexture(imageNamed: "white_octonid")
        let provider = SpriteSheetAnimationProvider(
            spriteSheet: sheet,
            stateRows: [.idle: 0, .moving: 1, .takingDamage: 2, .dead: 3],
            totalRows: 5,
            columns: 8
        )
        super.init(position: position, animationProvider: provider, movementStyle: .edgeSkater(offset: 50, speedVariation: 0.2), spriteSize: CGSize(width: 80, height: 80), attackRange: 20)
        self.name = "enemy"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
