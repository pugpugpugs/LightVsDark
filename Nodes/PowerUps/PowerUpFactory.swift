import SpriteKit

final class PowerUpFactory {

    func make(type: PowerUpType) -> PowerUp {
        switch type {
        case .widenCone:
            return WidenConePowerUp()
        case .narrowCone:
            return NarrowConePowerUp()
        case .heal:
            return HealPowerUp()
        }
    }

    func makeRandom(from candidates: [PowerUpType]) -> PowerUp? {
        guard let type = candidates.randomElement() else { return nil }
        return make(type: type)
    }
}
