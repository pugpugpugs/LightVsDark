import SpriteKit

final class GameOverOverlay: SKNode {

    var onRestart: (() -> Void)?

    override init() {
        super.init()
        zPosition = 1000
        isHidden = true

        setupUI()
        
        let title = SKLabelNode(text: "GAME OVER")
        title.fontName = "Helvetica-Bold"
        title.fontSize = 48
        title.position = CGPoint(x: 0, y: 100)
        addChild(title)

        let button = SKShapeNode(rectOf: CGSize(width: 200, height: 60), cornerRadius: 12)
        button.fillColor = .white
        button.name = "restartButton"
        button.position = CGPoint(x: 0, y: -40)
        addChild(button)

        let label = SKLabelNode(text: "RESTART")
        label.fontColor = .black
        label.fontSize = 24
        label.verticalAlignmentMode = .center
        button.addChild(label)

        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        let nodes = nodes(at: location)
        if nodes.contains(where: { $0.name == "restartButton" }) {
            onRestart?()
        }
    }
    
    private func setupUI() {
        let dim = SKShapeNode(rectOf: CGSize(width: 2000, height: 2000))
        dim.fillColor = .black
        dim.alpha = 0.7
        dim.strokeColor = .clear
        addChild(dim)
    }

}
