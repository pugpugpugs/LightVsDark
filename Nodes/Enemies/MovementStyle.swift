import SpriteKit

enum MovementStyle {
    case straight
    case zigZag(amplitude: CGFloat, frequency: CGFloat)
}
