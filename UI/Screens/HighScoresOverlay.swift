import SpriteKit

class HighScoresOverlay: SKNode {

    var onClose: (() -> Void)?

    private let dimBackground: SKShapeNode
    private let closeButton: SKShapeNode
    private let scores: [Int]

    init(size: CGSize, scores: [Int]) {
        self.scores = scores

        // Dim
        dimBackground = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        dimBackground.fillColor = .black
        dimBackground.alpha = 0.7
        dimBackground.strokeColor = .clear

        // Close
        closeButton = SKShapeNode(rectOf: CGSize(width: 140, height: 60), cornerRadius: 12)
        closeButton.fillColor = .white
        closeButton.position = CGPoint(x: 0, y: -size.height/2 + 80)
        let label = SKLabelNode(text: "CLOSE")
        label.fontName = "Helvetica-Bold"
        label.fontSize = 24
        label.verticalAlignmentMode = .center
        label.fontColor = .black
        closeButton.addChild(label)
        closeButton.name = "closeButton"

        super.init()
        zPosition = 1000
        isUserInteractionEnabled = true

        addChild(dimBackground)
        addChild(closeButton)

        // Render scores
        for (i, score) in scores.prefix(10).enumerated() {
            let scoreLabel = SKLabelNode(text: "\(i+1). \(score)")
            scoreLabel.fontName = "Helvetica-Bold"
            scoreLabel.fontSize = 28
            scoreLabel.position = CGPoint(x: 0, y: size.height/2 - CGFloat(i + 1) * 50 - 100)
            addChild(scoreLabel)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        if nodesAtPoint.contains(where: { $0.name == "closeButton" }) {
            isHidden = true
            onClose?()
        }
    }
}
