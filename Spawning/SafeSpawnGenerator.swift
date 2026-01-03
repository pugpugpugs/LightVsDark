import SpriteKit

final class SafeSpawnGenerator {

    let sceneSize: CGSize
    let player: Player

    #if DEBUG
    private let debugDrawer: DebugDrawer?
    #endif

    // Define 8 spawn zones around screen edges
    private var spawnZones: [CGRect] = []

    init(sceneSize: CGSize, player: Player) {
        self.sceneSize = sceneSize
        self.player = player
        #if DEBUG
        self.debugDrawer = player.scene.map { DebugDrawer(scene: $0) }
        #endif

        setupZones()
    }

    private func setupZones() {
        // 8 zones along screen edges, small margin to avoid clipping
        let margin: CGFloat = 50
        let zoneThickness: CGFloat = 100

        // Top edge
        spawnZones.append(CGRect(x: margin, y: sceneSize.height - zoneThickness, width: sceneSize.width - 2*margin, height: zoneThickness))
        // Bottom edge
        spawnZones.append(CGRect(x: margin, y: 0, width: sceneSize.width - 2*margin, height: zoneThickness))
        // Left edge
        spawnZones.append(CGRect(x: 0, y: margin, width: zoneThickness, height: sceneSize.height - 2*margin))
        // Right edge
        spawnZones.append(CGRect(x: sceneSize.width - zoneThickness, y: margin, width: zoneThickness, height: sceneSize.height - 2*margin))

        // Diagonal corner zones (optional: top-left, top-right, bottom-left, bottom-right)
        spawnZones.append(CGRect(x: 0, y: sceneSize.height - zoneThickness, width: zoneThickness, height: zoneThickness))
        spawnZones.append(CGRect(x: sceneSize.width - zoneThickness, y: sceneSize.height - zoneThickness, width: zoneThickness, height: zoneThickness))
        spawnZones.append(CGRect(x: 0, y: 0, width: zoneThickness, height: zoneThickness))
        spawnZones.append(CGRect(x: sceneSize.width - zoneThickness, y: 0, width: zoneThickness, height: zoneThickness))
    }

    // Pick a random point from one of the zones
    func generateSafeSpawnPoint(spriteSize: CGSize) -> CGPoint {
        guard !spawnZones.isEmpty else { return player.position + CGPoint(x: 0, y: 300) }

        let zone = spawnZones.randomElement()!
        let x = CGFloat.random(in: zone.minX...(zone.maxX - spriteSize.width))
        let y = CGFloat.random(in: zone.minY...(zone.maxY - spriteSize.height))

        let spawnPoint = CGPoint(x: x, y: y)

        #if DEBUG
        debugDrawer?.drawRect(zone, color: .cyan, persist: true)
        debugDrawer?.drawDot(at: spawnPoint, color: .magenta, persist: true)
        #endif

        return spawnPoint
    }
}

//import SpriteKit
//
//final class SafeSpawnGenerator {
//
//    let sceneSize: CGSize
//    let player: Player
//
//    #if DEBUG
//    private let debugDrawer: DebugDrawer?
//    #endif
//
//    init(sceneSize: CGSize, player: Player) {
//        self.sceneSize = sceneSize
//        self.player = player
//        #if DEBUG
//        self.debugDrawer = player.scene.map { DebugDrawer(scene: $0) }
//        #endif
//    }
//
//    // MARK: - Generate test spawn and debug candidate
//    func generateSafeSpawnPoint(spriteSize: CGSize, minDistance: CGFloat, cone: LightCone, debugColor: SKColor) -> CGPoint {
//
//        let origin = player.position
//        let spawnPoint = addPoints(origin, CGPoint(x: 0, y: 100))
//
//        guard let scene = cone.scene else { return spawnPoint }
//
//        let halfAngle = cone.currentAngle / 2
//        let length: CGFloat = 160
//        let paddingAngle: CGFloat = 0.15 // radians
//
//        // --- Cone edges ---
//        let leftScene = cone.convert(CGPoint(x: cos(-halfAngle) * length,
//                                             y: sin(-halfAngle) * length),
//                                     to: scene)
//        let rightScene = cone.convert(CGPoint(x: cos(halfAngle) * length,
//                                              y: sin(halfAngle) * length),
//                                      to: scene)
//
//        // --- Padded points in scene space ---
//        let leftDir = CGVector(dx: leftScene.x - origin.x, dy: leftScene.y - origin.y)
//        let rightDir = CGVector(dx: rightScene.x - origin.x, dy: rightScene.y - origin.y)
//        let paddedLeft = vectorWithPadding(leftDir, padding: -paddingAngle)
//        let paddedRight = vectorWithPadding(rightDir, padding: paddingAngle)
//        let paddedLeftPoint  = addPoints(origin, CGPoint(x: paddedLeft.dx, y: paddedLeft.dy))
//        let paddedRightPoint = addPoints(origin, CGPoint(x: paddedRight.dx, y: paddedRight.dy))
//
//        let candidate = candidatePointOutsideCone(origin: origin,
//                                                  paddedLeftPoint: paddedLeftPoint,
//                                                  paddedRightPoint: paddedRightPoint,
//                                                  minDistance: 100)
//
//        #if DEBUG
//        debugDrawer?.clearTemporary()
//        debugDrawer?.drawLines(origin: origin, points: [leftScene, rightScene], color: .cyan, persist: false)
//        debugDrawer?.drawLines(origin: origin, points: [paddedLeftPoint, paddedRightPoint], color: .magenta, persist: false)
//        #endif
//
//        return candidate
//    }
//
//    private func vectorWithPadding(_ v: CGVector, padding: CGFloat) -> CGVector {
//        let len = sqrt(v.dx*v.dx + v.dy*v.dy)
//        let angle = atan2(v.dy, v.dx) + padding
//        return CGVector(dx: cos(angle) * len, dy: sin(angle) * len)
//    }
//
//    // Helper for adding points
//    private func addPoints(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
//        CGPoint(x: a.x + b.x, y: a.y + b.y)
//    }
//
//    // MARK: - Candidate generation — every call returns a point outside padded cone
//    private func candidatePointOutsideCone(origin: CGPoint,
//                                           paddedLeftPoint: CGPoint,
//                                           paddedRightPoint: CGPoint,
//                                           minDistance: CGFloat = 100) -> CGPoint {
//
//        let twoPi = 2 * CGFloat.pi
//
//        // 1. Get angles of padded points
//        var leftAngle  = atan2(paddedLeftPoint.y - origin.y, paddedLeftPoint.x - origin.x)
//        var rightAngle = atan2(paddedRightPoint.y - origin.y, paddedRightPoint.x - origin.x)
//
//        // Normalize to 0..2π
//        leftAngle  = (leftAngle + twoPi).truncatingRemainder(dividingBy: twoPi)
//        rightAngle = (rightAngle + twoPi).truncatingRemainder(dividingBy: twoPi)
//
//        // 2. Determine safe angular ranges (outside cone)
//        let safeRanges: [(CGFloat, CGFloat)]
//        if leftAngle < rightAngle {
//            // cone [leftAngle, rightAngle], safe: [0, leftAngle] ∪ [rightAngle, 2π]
//            safeRanges = [(0, leftAngle), (rightAngle, twoPi)]
//        } else if leftAngle > rightAngle {
//            // cone crosses 0: safe: [rightAngle, leftAngle]
//            safeRanges = [(rightAngle, leftAngle)]
//        } else {
//            // zero-width cone → full circle safe
//            safeRanges = [(0, twoPi)]
//        }
//
//        // 3. Pick a random angle from a random safe range
//        let range = safeRanges.randomElement()!
//        let spawnAngle = CGFloat.random(in: range.0..<range.1)
//
//        // 4. Generate unit vector along that angle
//        let dx = cos(spawnAngle)
//        let dy = sin(spawnAngle)
//
//        // 5. Determine max distance along this vector within screen bounds
//        let maxX = dx > 0 ? (sceneSize.width - origin.x - 10)/dx :
//                   dx < 0 ? (0 - origin.x + 10)/dx : CGFloat.infinity
//        let maxY = dy > 0 ? (sceneSize.height - origin.y - 10)/dy :
//                   dy < 0 ? (0 - origin.y + 10)/dy : CGFloat.infinity
//        let maxDistance = max(minDistance, min(maxX, maxY))
//
//        // Random distance between minDistance and maxDistance
//        let distance = CGFloat.random(in: minDistance...maxDistance)
//
//        // Return final point
//        return CGPoint(x: origin.x + dx * distance,
//                       y: origin.y + dy * distance)
//    }
//
//
//    private func pathForConeEdges(origin: CGPoint, leftScene: CGPoint, rightScene: CGPoint) -> CGPath {
//        let path = CGMutablePath()
//        path.move(to: origin)
//        path.addLine(to: leftScene)
//        path.move(to: origin)
//        path.addLine(to: rightScene)
//        return path
//    }
//
//    private func pathForPaddedEdges(origin: CGPoint, paddedLeftPoint: CGPoint, paddedRightPoint: CGPoint) -> CGPath {
//        let path = CGMutablePath()
//        path.move(to: origin)
//        path.addLine(to: paddedLeftPoint)
//        path.move(to: origin)
//        path.addLine(to: paddedRightPoint)
//        return path
//    }
//}
