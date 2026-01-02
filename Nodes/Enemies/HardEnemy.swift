import SpriteKit

class HardEnemy: Enemy {

    init(position: CGPoint) {
        super.init(
            position: position,
            spriteSheetName: "red_octonid",
            rowIndex: 0,
            rows: 5,
            columns: 8,
            spriteSize: CGSize(width: 100, height: 100),
            speedMultiplierRange: 1.2...1.6
        )

        self.name = "enemy"

        // Hard enemies zig-zag aggressively
        self.movementStyle = .zigZag(amplitude: 120, frequency: 8)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
