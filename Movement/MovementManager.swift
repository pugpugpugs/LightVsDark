import CoreGraphics

final class MovementManager {

    // MARK: - Public API

    func movementDelta(
        for enemy: Enemy,
        toward target: CGPoint,
        deltaTime: CGFloat
    ) -> CGVector {

        switch enemy.movementStyle {
        case .straight:
            return straightMovement(enemy: enemy, toward: target, deltaTime: deltaTime)
            
        case .zigZag(let amplitude, let frequency):
            return zigZagMovement(
                enemy: enemy,
                toward: target,
                amplitude: amplitude,
                frequency: frequency,
                deltaTime: deltaTime
            )
        case .edgeSkater(let offset, let speedVariation):
            return edgeSkaterMovement(
                enemy: enemy,
                toward: target,
                offset: offset,
                speedVariation: speedVariation,
                deltaTime: deltaTime
            )
    }
}

    // MARK: - Movement Types

    private func straightMovement(
        enemy: Enemy,
        toward target: CGPoint,
        deltaTime: CGFloat
    ) -> CGVector {

        let direction = CGVector(
            dx: target.x - enemy.position.x,
            dy: target.y - enemy.position.y
        ).normalized()

        let speed: CGFloat = enemy.baseSpeed * enemy.speedMultiplier

        return CGVector(
            dx: direction.dx * speed * deltaTime,
            dy: direction.dy * speed * deltaTime
        )
    }

    private func zigZagMovement(
        enemy: Enemy,
        toward target: CGPoint,
        amplitude: CGFloat,
        frequency: CGFloat,
        deltaTime: CGFloat
    ) -> CGVector {

        let direction = CGVector(
            dx: target.x - enemy.position.x,
            dy: target.y - enemy.position.y
        ).normalized()

        let perpendicular = CGVector(
            dx: -direction.dy,
            dy: direction.dx
        )

        enemy.timeElapsed += deltaTime

        let speed = enemy.baseSpeed * enemy.speedMultiplier

        // Forward movement (same as straight)
        let forward = CGVector(
            dx: direction.dx * speed * deltaTime,
            dy: direction.dy * speed * deltaTime
        )

        // Lateral velocity (THIS is the fix)
        let lateralStrength = sin(enemy.timeElapsed * frequency) * amplitude
        let lateral = CGVector(
            dx: perpendicular.dx * lateralStrength * deltaTime,
            dy: perpendicular.dy * lateralStrength * deltaTime
        )

        return CGVector(
            dx: forward.dx + lateral.dx,
            dy: forward.dy + lateral.dy
        )
    }
    
    private func edgeSkaterMovement(
        enemy: Enemy,
        toward target: CGPoint,
        offset: CGFloat,
        speedVariation: CGFloat,
        deltaTime: CGFloat
    ) -> CGVector {

        // 1. Forward vector toward target
        let direction = CGVector(
            dx: target.x - enemy.position.x,
            dy: target.y - enemy.position.y
        ).normalized()

        // 2. Forward speed
        let speed = (enemy.baseSpeed * enemy.speedMultiplier) * (1.0 + CGFloat.random(in: -speedVariation...speedVariation))

        let forward = CGVector(
            dx: direction.dx * speed * deltaTime,
            dy: direction.dy * speed * deltaTime
        )

        // 3. Perpendicular vector for lateral offset along the cone edge
        let perpendicular = CGVector(dx: -direction.dy, dy: direction.dx).normalized()

        // 4. Lateral position offset is relative to the original path, not per frame
        let lateralOffset = sin(enemy.timeElapsed * 2.0) * offset  // wobble around center line
        let lateral = CGVector(
            dx: perpendicular.dx * lateralOffset * deltaTime,  // scale by deltaTime!
            dy: perpendicular.dy * lateralOffset * deltaTime
        )

        // 5. Accumulate time
        enemy.timeElapsed += deltaTime

        return CGVector(
            dx: forward.dx + lateral.dx,
            dy: forward.dy + lateral.dy
        )
    }


}
