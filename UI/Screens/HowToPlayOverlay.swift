import SpriteKit

// MARK: - Models
struct HowToPlaySlide {
    let imageName: String
    let description: String
}

// MARK: - Overlays
class HowToPlayOverlay: SKNode {

    var onClose: (() -> Void)?

    private let size: CGSize
    private var slides: [HowToPlaySlide] = []
    private var currentIndex = 0

    private let dimBackground: SKShapeNode
    private let imageNode: SKSpriteNode
    private let descriptionLabel: SKLabelNode
    private let closeButton: SKShapeNode
    private var dots: [SKShapeNode] = []

    init(size: CGSize, slides: [HowToPlaySlide]) {
        self.size = size
        self.slides = slides

        // Dim background
        dimBackground = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        dimBackground.fillColor = .black
        dimBackground.alpha = 0.7
        dimBackground.strokeColor = .clear

        // Image node
        imageNode = SKSpriteNode()
        imageNode.position = CGPoint(x: 0, y: 100)
        imageNode.size = CGSize(width: size.width * 0.7, height: size.height * 0.5)

        // Description label
        descriptionLabel = SKLabelNode(text: "")
        descriptionLabel.fontName = "Helvetica"
        descriptionLabel.fontSize = 24
        descriptionLabel.preferredMaxLayoutWidth = size.width - 80
        descriptionLabel.numberOfLines = 0
        descriptionLabel.horizontalAlignmentMode = .center
        descriptionLabel.verticalAlignmentMode = .center
        descriptionLabel.position = CGPoint(x: 0, y: -150)

        // Close button
        closeButton = SKShapeNode(rectOf: CGSize(width: 140, height: 60), cornerRadius: 12)
        closeButton.fillColor = .white
        closeButton.position = CGPoint(x: 0, y: -250)
        let closeLabel = SKLabelNode(text: "CLOSE")
        closeLabel.fontName = "Helvetica-Bold"
        closeLabel.fontSize = 24
        closeLabel.verticalAlignmentMode = .center
        closeLabel.fontColor = .black
        closeButton.addChild(closeLabel)
        closeButton.name = "closeButton"

        super.init()
        zPosition = 1000
        isUserInteractionEnabled = true

        // Add nodes
        addChild(dimBackground)
        addChild(imageNode)
        addChild(descriptionLabel)
        addChild(closeButton)

        // Page dots
        setupDots()

        // Show first slide
        showSlide(at: currentIndex)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupDots() {
        dots.forEach { $0.removeFromParent() }
        dots = []
        let spacing: CGFloat = 20
        let totalWidth = CGFloat(slides.count - 1) * spacing
        for i in 0..<slides.count {
            let dot = SKShapeNode(circleOfRadius: 6)
            dot.fillColor = (i == currentIndex) ? .white : .gray
            dot.position = CGPoint(x: CGFloat(i) * spacing - totalWidth/2, y: -200)
            addChild(dot)
            dots.append(dot)
        }
    }

    private func updateDots() {
        for (i, dot) in dots.enumerated() {
            dot.fillColor = (i == currentIndex) ? .white : .gray
        }
    }

    private func showSlide(at index: Int) {
        guard slides.indices.contains(index) else { return }
        let slide = slides[index]
        imageNode.texture = SKTexture(imageNamed: slide.imageName)
        descriptionLabel.text = slide.description
        updateDots()
    }

    // MARK: - Touch / Swipe
    private var touchStartX: CGFloat?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStartX = touches.first?.location(in: self).x
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let startX = touchStartX, let touch = touches.first else { return }
        let endX = touch.location(in: self).x
        let deltaX = endX - startX

        if abs(deltaX) > 30 { // Swipe threshold
            if deltaX < 0 { nextSlide() }   // Swipe left → next
            else { previousSlide() }       // Swipe right → previous
        }

        // Close button
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        if nodesAtPoint.contains(where: { $0.name == "closeButton" }) {
            isHidden = true
            onClose?()
        }
    }

    func nextSlide() {
        currentIndex = min(currentIndex + 1, slides.count - 1)
        showSlide(at: currentIndex)
    }

    func previousSlide() {
        currentIndex = max(currentIndex - 1, 0)
        showSlide(at: currentIndex)
    }
}
