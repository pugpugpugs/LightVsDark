enum PowerUpType: CaseIterable{
    case narrowCone
    case widenCone
    case heal
    
    var isInstant: Bool {
        switch self {
        case .heal:
            return true
        default:
            return false
        }
    }
}
