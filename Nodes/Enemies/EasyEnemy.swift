import SpriteKit

class EasyEnemy: Enemy {

    init(position: CGPoint) {
        // Pass the exact specs your old Enemy had
        super.init(position: position,
                   spriteSheetName: "green_octonid",
                   rowIndex: 0,
                   rows: 5,
                   columns: 8,
                   spriteSize: CGSize(width: 80, height: 80),
                   speedMultiplierRange: 0.8...1.3)
        self.name = "enemy"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
