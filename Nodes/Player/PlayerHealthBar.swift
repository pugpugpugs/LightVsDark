import SpriteKit

final class PlayerHealthBar: SKNode {

    private let maxHP: Int
    private var currentHP: Int

    private var segments: [SKShapeNode] = []

    init(maxHP: Int, segmentSize: CGSize = CGSize(width: 20, height: 6), spacing: CGFloat = 4) {
        self.maxHP = maxHP
        self.currentHP = maxHP
        super.init()
        
        let totalWidth = CGFloat(maxHP) * segmentSize.width + CGFloat(maxHP - 1) * spacing

        for i in 0..<maxHP {
            let rect = SKShapeNode(rectOf: segmentSize, cornerRadius: 2)
            rect.strokeColor = .white
            rect.lineWidth = 1.5
            rect.fillColor = .red
            rect.position = CGPoint(
                x: CGFloat(i) * (segmentSize.width + spacing) - totalWidth / 2 + segmentSize.width / 2,
                y: 0
            )
            addChild(rect)
            segments.append(rect)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(hp: Int) {
        currentHP = max(0, min(hp, maxHP)) // clamp between 0 and maxHP
        for (index, segment) in segments.enumerated() {
            segment.fillColor = index < currentHP ? .red : .clear
        }
    }
}
