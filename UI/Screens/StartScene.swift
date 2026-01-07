import SpriteKit

// MARK: - Start Scene
class StartScene: SKScene {

    private var playButton: SKShapeNode!
    private var howToPlayButton: SKShapeNode!
    private var highScoresButton: SKShapeNode!

    private var howToPlayOverlay: HowToPlayOverlay!
    private var highScoresOverlay: HighScoresOverlay!

    override func didMove(to view: SKView) {
        backgroundColor = .darkGray

        setupButtons()
        setupOverlays()
    }

    private func setupButtons() {
        let buttonSize = CGSize(width: 250, height: 70)
        let spacing: CGFloat = 100
        let midY = frame.midY

        // Play
        playButton = SKShapeNode(rectOf: buttonSize, cornerRadius: 12)
        playButton.fillColor = .white
        playButton.position = CGPoint(x: frame.midX, y: midY + spacing)
        playButton.name = "playButton"
        addChild(playButton)
        addLabel(to: playButton, text: "PLAY")

        // How To Play
        howToPlayButton = SKShapeNode(rectOf: buttonSize, cornerRadius: 12)
        howToPlayButton.fillColor = .white
        howToPlayButton.position = CGPoint(x: frame.midX, y: midY)
        howToPlayButton.name = "howToPlayButton"
        addChild(howToPlayButton)
        addLabel(to: howToPlayButton, text: "HOW TO PLAY")

        // High Scores
        highScoresButton = SKShapeNode(rectOf: buttonSize, cornerRadius: 12)
        highScoresButton.fillColor = .white
        highScoresButton.position = CGPoint(x: frame.midX, y: midY - spacing)
        highScoresButton.name = "highScoresButton"
        addChild(highScoresButton)
        addLabel(to: highScoresButton, text: "HIGH SCORES")
    }

    private func addLabel(to button: SKShapeNode, text: String) {
        let label = SKLabelNode(text: text)
        label.fontName = "Helvetica-Bold"
        label.fontSize = 24
        label.verticalAlignmentMode = .center
        label.fontColor = .black
        button.addChild(label)
    }

    private func setupOverlays() {
        // How To Play slides
        let slides = [
            HowToPlaySlide(imageName: "slide1", description: "Move your light cone to damage enemies."),
            HowToPlaySlide(imageName: "slide2", description: "Collect power-ups to boost your damage."),
            HowToPlaySlide(imageName: "slide3", description: "Avoid being hit to keep combos alive.")
        ]
        howToPlayOverlay = HowToPlayOverlay(size: frame.size, slides: slides)
        howToPlayOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
        howToPlayOverlay.isHidden = true
        addChild(howToPlayOverlay)

        // High Scores placeholder
        let scores = [1000, 900, 800, 700, 600, 500, 400, 300, 200, 100]
        highScoresOverlay = HighScoresOverlay(size: frame.size, scores: scores)
        highScoresOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
        highScoresOverlay.isHidden = true
        addChild(highScoresOverlay)
    }

    // MARK: - Touch Handling
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)

        if nodesAtPoint.contains(where: { $0.name == "playButton" }) {
            startGame()
        } else if nodesAtPoint.contains(where: { $0.name == "howToPlayButton" }) {
            howToPlayOverlay.isHidden = false
        } else if nodesAtPoint.contains(where: { $0.name == "highScoresButton" }) {
            highScoresOverlay.isHidden = false
        }
    }

    private func startGame() {
        guard let view = self.view else { return }
        let gameScene = GameScene(size: view.bounds.size)
        gameScene.scaleMode = .resizeFill
        view.presentScene(gameScene, transition: .fade(withDuration: 0.5))
    }
}
