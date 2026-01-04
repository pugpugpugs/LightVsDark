import SpriteKit

class EasyEnemy: Enemy {
    init(position: CGPoint) {
        let sheet = SKTexture(imageNamed: "green_octonid")
        let provider = SpriteSheetAnimationProvider(
            spriteSheet: sheet,
            stateRows: [.idle: 0, .moving: 1, .takingDamage: 2, .dead: 3],
            totalRows: 5,
            columns: 8
        )
        super.init(position: position, animationProvider: provider, spriteSize: CGSize(width: 80, height: 80), attackRange: 20)
        self.name = "enemy"
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}
