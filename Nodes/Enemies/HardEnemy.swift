import SpriteKit

class HardEnemy: Enemy {

    init(position: CGPoint) {
        let provider = SpriteSheetAnimationProvider(
            stateSheets: [
                .idle: SKTexture(imageNamed: "Lancer_Idle"),
                .moving: SKTexture(imageNamed: "Lancer_Run"),
                .takingDamage: SKTexture(imageNamed: "Lancer_Hit"),
                .dead: SKTexture(imageNamed: "Lancer_Die"),
                .attacking: SKTexture(imageNamed: "Lancer_Attack")
            ],
            rowsPerSheet: [
                .idle: 1,
                .moving: 1,
                .takingDamage: 1,
                .dead: 1,
                .attacking: 1
            ],
            columnsPerSheet: [
                .idle: 12,
                .moving: 6,
                .takingDamage: 6,
                .dead: 3,
                .attacking: 3
            ]
        )
        super.init(position: position, animationProvider: provider, movementStyle: .zigZag(amplitude: 40, frequency: 4.0), spriteSize: CGSize(width: 80, height: 80), attackRange: 20)
        self.name = "enemy"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
