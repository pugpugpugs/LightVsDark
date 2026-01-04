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
