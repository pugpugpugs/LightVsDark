import SpriteKit

final class SafeSpawnGenerator {

    let sceneSize: CGSize
    let player: Player

    #if DEBUG
    private let debugDrawer: DebugDrawer?
    var debugDrawEnabled: Bool = true
    #endif

    private(set) var spawnZones: [CGRect] = []

    init(sceneSize: CGSize, player: Player) {
        self.sceneSize = sceneSize
        self.player = player

        #if DEBUG
        self.debugDrawer = player.scene.map { DebugDrawer(scene: $0) }
        #endif

        setupZones()
        #if DEBUG
        if debugDrawEnabled { drawAllZones() }
        #endif
    }

    private func setupZones(edge: CGFloat = 50) {
        spawnZones.removeAll()

        // --- Corners ---
        // bottom-left
        spawnZones.append(CGRect(x: 0, y: 0, width: edge, height: edge))
        // bottom-right
        spawnZones.append(CGRect(x: sceneSize.width - edge, y: 0, width: edge, height: edge))
        // top-left
        spawnZones.append(CGRect(x: 0, y: sceneSize.height - edge, width: edge, height: edge))
        // top-right
        spawnZones.append(CGRect(x: sceneSize.width - edge, y: sceneSize.height - edge, width: edge, height: edge))

        // --- Vertical edges (excluding corners) ---
        let verticalZonesCount = 4 // total per side including corners = 6, we already added 2 corners
        let verticalZoneHeight = (sceneSize.height - 2 * edge) / CGFloat(verticalZonesCount)

        for i in 0..<(verticalZonesCount) {
            let y = edge + CGFloat(i) * verticalZoneHeight
            // left edge
            spawnZones.append(CGRect(x: 0, y: y, width: edge, height: verticalZoneHeight))
            // right edge
            spawnZones.append(CGRect(x: sceneSize.width - edge, y: y, width: edge, height: verticalZoneHeight))
        }

        // --- Horizontal edges (excluding corners) ---
        let horizontalZonesCount = 4 // total per side including corners
        let horizontalZoneWidth = (sceneSize.width - 2 * edge) / CGFloat(horizontalZonesCount - 2)

        for i in 0..<(horizontalZonesCount - 2) {
            let x = edge + CGFloat(i) * horizontalZoneWidth
            // top edge
            spawnZones.append(CGRect(x: x, y: sceneSize.height - edge, width: horizontalZoneWidth, height: edge))
            // bottom edge
            spawnZones.append(CGRect(x: x, y: 0, width: horizontalZoneWidth, height: edge))
        }
    }


    #if DEBUG
    private func drawAllZones() {
        for zone in spawnZones {
            debugDrawer?.drawRect(zone, color: .cyan, persist: true)
        }

        // Optional: show player safe zone
        let safeRadius: CGFloat = 120
        let playerRect = CGRect(
            x: player.position.x - safeRadius,
            y: player.position.y - safeRadius,
            width: safeRadius*2,
            height: safeRadius*2
        )
        debugDrawer?.drawRect(playerRect, color: .red, persist: true)
    }
    #endif

    // Pick a random point in a random zone
    func generateSafeSpawnPoint(spriteSize: CGSize) -> CGPoint {
        guard !spawnZones.isEmpty else {
            return player.position + CGPoint(x: 0, y: 300)
        }

        // Pick a random zone
        let zone = spawnZones.randomElement()!

        // Clamp the available width/height to at least 1
        let maxX = max(zone.maxX - spriteSize.width, zone.minX)
        let maxY = max(zone.maxY - spriteSize.height, zone.minY)

        let x = CGFloat.random(in: zone.minX...maxX)
        let y = CGFloat.random(in: zone.minY...maxY)

        return CGPoint(x: x, y: y)
    }

}
