import Foundation
import SpriteKit

final class PowerUpManager {

    // MARK: - Active power-up wrapper
    private struct ActivePowerUp {
        let powerUp: PowerUp
        let target: PowerUpAccepting
        let startTime: TimeInterval
    }

    // MARK: - Properties
    private let player: Player
    private let weapon: PlayerWeapon

    // All currently active power-ups
    private var active: [ActivePowerUp] = []

    // Expose active PowerUps to the scene
    var activePowerUps: [PowerUp] {
        return active.map { $0.powerUp }
    }

    // MARK: - Init
    init(player: Player, weapon: PlayerWeapon) {
        self.player = player
        self.weapon = weapon
    }

    // MARK: - Public API

    /// Returns all eligible power-up types that can spawn now
    func eligiblePowerUpTypes() -> [PowerUpType] {
        // Only spawn if no active duplicate of the type exists
        let activeTypes = Set(active.map { $0.powerUp.type })

        return PowerUpType.allCases.filter { type in
            isEligible(type) && !activeTypes.contains(type)
        }
    }

    /// Called when a player touches a PowerUp node
    func handlePickup(_ powerUp: PowerUp, currentTime: TimeInterval) {
        // Determine valid target
        guard let target = target(for: powerUp.type) else { return }

        // Activate visuals/effect
        powerUp.activate(currentTime: currentTime)
        target.applyPowerUp(powerUp: powerUp.type)
        
        if powerUp.type.isInstant {
            return
        }
        
        guard !active.contains(where: { $0.powerUp === powerUp }) else { return }

        // Track active power-up
        active.append(ActivePowerUp(powerUp: powerUp, target: target, startTime: currentTime))
    }

    /// Called each frame to update expiration
    func update(currentTime: TimeInterval) {
        for activePowerUp in active {
            activePowerUp.powerUp.update(currentTime: currentTime)
        }
        
        var expiredIndices: [Int] = []

        for (index, activePowerUp) in active.enumerated() {
            let elapsed = currentTime - activePowerUp.startTime
            let duration = activePowerUp.powerUp.effectDuration

            if elapsed >= duration {
                activePowerUp.target.removePowerUp(powerUp: activePowerUp.powerUp.type)
                expiredIndices.append(index)
            }
        }

        for index in expiredIndices.reversed() {
            active.remove(at: index)
        }
    }


    /// Remove a power-up manually (optional)
    func remove(_ powerUp: PowerUp) {
        guard let index = active.firstIndex(where: { $0.powerUp === powerUp }) else { return }
        let activePowerUp = active[index]

        // Remove effect & visuals
        activePowerUp.target.removePowerUp(powerUp: activePowerUp.powerUp.type)

        active.remove(at: index)
    }

    // MARK: - Rules (Private)

    /// Determine if a type is eligible for spawn
    private func isEligible(_ type: PowerUpType) -> Bool {
        switch type {
        case .heal:
            return player.hitPoints < player.stats.maxHealth
        default:
            // Only allow if current weapon supports this type
            return (weapon as PowerUpAccepting).supportedPowerUps.contains(type)
        }
    }

    /// Determine the target for a power-up type
    private func target(for type: PowerUpType) -> PowerUpAccepting? {
        switch type {
        case .heal:
            return player
        default:
            return weapon as PowerUpAccepting
        }
    }
}
