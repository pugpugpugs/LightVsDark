//
//  SpawnManager.swift
//  LightVsDark iOS
//
//  Created by chris on 12/30/25.
//

import SpriteKit

class SpawnManager {
    weak var scene: GameScene?
    var spawnInterval: TimeInterval = 1.5
    private var lastSpawnTime: TimeInterval = 0

    private let zoneCount = 6
    private var lastZone: Int? = nil

    var spawnDistance: CGFloat {
        guard let scene = scene else { return 300 }
        return min(scene.size.width, scene.size.height) / 2 + 50
    }

    init(scene: GameScene) {
        self.scene = scene
    }

    private func pickSpawnZone(excludePlayerZone: Bool = true) -> Int {
        var zone: Int
        repeat {
            zone = Int.random(in: 0..<zoneCount)
        } while zone == lastZone
        lastZone = zone
        return zone
    }

    func update(currentTime: TimeInterval) {
        guard let scene = scene, let player = scene.player else { return }

        if currentTime - lastSpawnTime > spawnInterval {
            spawnObstacle(player: player)
            lastSpawnTime = currentTime
        }
    }

    private func spawnObstacle(player: Player) {
        guard let scene = scene else { return }

        let zone = pickSpawnZone()

        // Use Player helper: angle at start of the zone
        let angle = CGFloat(zone) * player.anglePerZone

        // Compute spawn vector using CGPoint helpers
        var spawnPosition = player.position + CGPoint(x: cos(angle), y: sin(angle)) * spawnDistance

        // Ensure minimum distance from player
        let minDistance: CGFloat = player.radius + 50
        if spawnPosition.distance(to: player.position) < minDistance {
            let dir = (spawnPosition - player.position).normalized()
            spawnPosition = player.position + dir * minDistance
        }

        let obstacle = Obstacle(position: spawnPosition, zoneIndex: zone)
        scene.addChild(obstacle)
        scene.obstacles.append(obstacle)
    }
}
