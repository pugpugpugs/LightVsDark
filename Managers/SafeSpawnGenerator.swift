import SpriteKit

class SafeSpawnGenerator {
    let sceneSize: CGSize
    let player: Player

    init(sceneSize: CGSize, player: Player) {
        self.sceneSize = sceneSize
        self.player = player
    }
    
    // MARK: - Gets a safe spawn point
    func generateSafeSpawnPoint(spriteSize: CGSize,
                                minDistance: CGFloat,
                                cone: LightCone) -> CGPoint {
        
        // Random direction vector
        let dir = randomDirectionVector()
        
        // Compute max distance along that vector
        let maxDistance = calculateMaxDistance(dir: dir, padding: max(spriteSize.width, spriteSize.height))
        
        // Pick a candidate point along the vector
        let distance = CGFloat.random(in: minDistance...maxDistance)
        var candidate = player.position + dir * distance
        
        if isPointInsideConeWithPadding(candidate, spriteSize: spriteSize, cone: cone) {
            // Rotate outside of the cone
            candidate = rotateSpawnOutsideCone(candidate: candidate,
                                               playerPosition: player.position,
                                               cone: cone,
                                               spriteSize: spriteSize,
                                               minDistance: minDistance,
                                               maxDistanceFunc: { dir in
                                                   self.calculateMaxDistance(dir: dir, padding: max(spriteSize.width, spriteSize.height))
                                               })
        }
        
        return candidate
    }
    
    // MARK: - Is spawn point in cone
    func isPointInsideConeWithPadding(_ point: CGPoint, spriteSize: CGSize, cone: LightCone) -> Bool {
        // Use sprite width/height as padding
        let padding = max(spriteSize.width, spriteSize.height) * 0.5
        return cone.containsPointWithPadding(point, padding: padding)
    }


    // MARK: - Get random vector that will be used to get a max distance
    private func randomDirectionVector() -> CGPoint {
        let angle = CGFloat.random(in: 0..<2 * .pi)
        return CGPoint(x: cos(angle), y: sin(angle))
    }

    // MARK: - Detemine maximum distance relative to the angle based on screen
    private func calculateMaxDistance(dir: CGPoint, padding: CGFloat) -> CGFloat {
        let maxX = dir.x > 0 ? (sceneSize.width - player.position.x - padding)/dir.x :
                   dir.x < 0 ? (0 - player.position.x + padding)/dir.x : CGFloat.infinity
        let maxY = dir.y > 0 ? (sceneSize.height - player.position.y - padding)/dir.y :
                   dir.y < 0 ? (0 - player.position.y + padding)/dir.y : CGFloat.infinity
        return min(maxX, maxY)
    }

    func rotateSpawnOutsideCone(candidate: CGPoint,
                                playerPosition: CGPoint,
                                cone: LightCone,
                                spriteSize: CGSize,
                                minDistance: CGFloat,
                                maxDistanceFunc: (CGPoint) -> CGFloat) -> CGPoint {
        
        let padding = max(spriteSize.width, spriteSize.height) * 0.5
        
        // Pick a random angle outside the current light cone
        let coneHalf = cone.currentAngle / 2 + padding
        let lower = min(coneHalf, 2 * .pi - 0.01)
        let upper = 2 * CGFloat.pi
    
        let angle: CGFloat
        if Bool.random() {
            // Sector after the cone
            angle = CGFloat.random(in: lower..<upper)
        } else {
            // Sector before the cone
            angle = CGFloat.random(in: 0..<(2 * .pi - lower))
        }
        
        let dir = CGPoint(x: cos(angle), y: sin(angle))
        
        // Compute max distance along this new direction
        let maxDistance = maxDistanceFunc(dir)
        let distance = CGFloat.random(in: minDistance...maxDistance)
        
        let newPoint = playerPosition + dir * distance

        // Debug log
        print("⚠️ Spawn rotated to avoid light cone")

        return newPoint
    }
}
