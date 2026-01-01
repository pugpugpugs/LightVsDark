import SpriteKit

final class DebugDrawer {
    private weak var scene: SKScene?

    private let persistantRoot = SKNode()
    
    private let temporaryRoot = SKNode()
    
    init(scene: SKScene) {
        self.scene = scene
        scene.addChild(persistantRoot)
        scene.addChild(temporaryRoot)
    }
    
    func clearTemporary() {
         temporaryRoot.removeAllChildren()
    }

    // MARK: - Draw a persistent dot
    func drawDot(at position: CGPoint, color: SKColor, persist: Bool, radius: CGFloat = 6, zPosition: CGFloat = 10_001) {

        let node = SKShapeNode(circleOfRadius: radius)
        node.fillColor = color
        node.strokeColor = .black
        node.lineWidth = 1
        node.position = position
        node.zPosition = zPosition
        
        handlePersist(node: node, shouldPersist: persist)
    }

    // MARK: - Draw a line from origin to points
    func drawLines(origin: CGPoint, points: [CGPoint], color: SKColor, persist: Bool, lineWidth: CGFloat = 2, zPosition: CGFloat = 9_999) {

        let path = CGMutablePath()
        for point in points {
            path.move(to: origin)
            path.addLine(to: point)
        }
        let node = SKShapeNode(path: path)
        node.strokeColor = color
        node.lineWidth = lineWidth
        node.zPosition = zPosition
        
        handlePersist(node: node, shouldPersist: persist)
    }
    
    private func handlePersist(node: SKNode, shouldPersist: Bool) {
        if shouldPersist {
            persistantRoot.addChild(node)
        } else {
            temporaryRoot.addChild(node)
        }
    }
}
