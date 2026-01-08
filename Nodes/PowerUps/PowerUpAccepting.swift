import SpriteKit

protocol PowerUpAccepting: AnyObject {
    var supportedPowerUps: [PowerUpType] { get }
    
    func applyPowerUp(powerUp: PowerUpType)
    
    func removePowerUp(powerUp: PowerUpType)
}
