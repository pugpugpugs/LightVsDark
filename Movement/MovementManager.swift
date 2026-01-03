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

        // Perpendicular vector for lateral movement
        let perpendicular = CGVector(
            dx: -direction.dy,
            dy: direction.dx
        )

        enemy.timeElapsed += deltaTime

        let lateralOffset = sin(enemy.timeElapsed * frequency) * amplitude
        let speed: CGFloat = enemy.baseSpeed * enemy.speedMultiplier

        let forward = CGVector(
            dx: direction.dx * speed * deltaTime,
            dy: direction.dy * speed * deltaTime
        )

        let lateral = CGVector(
            dx: perpendicular.dx * lateralOffset,
            dy: perpendicular.dy * lateralOffset
        )

        return CGVector(
            dx: forward.dx + lateral.dx,
            dy: forward.dy + lateral.dy
        )
    }
}
