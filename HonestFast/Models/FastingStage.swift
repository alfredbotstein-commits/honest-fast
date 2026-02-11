import SwiftUI

enum FastingStage: CaseIterable {
    case risingBloodSugar      // 0-4h
    case bloodSugarFalling     // 4-8h
    case bloodSugarBaseline    // 8-12h
    case fatBurningBegins      // 12-14h
    case fatBurningMode        // 14-16h
    case ketosisAutophagy      // 16-24h+
    
    var title: String {
        switch self {
        case .risingBloodSugar: return "Rising blood sugar"
        case .bloodSugarFalling: return "Blood sugar falling"
        case .bloodSugarBaseline: return "Blood sugar baseline"
        case .fatBurningBegins: return "Fat burning begins"
        case .fatBurningMode: return "Fat burning mode"
        case .ketosisAutophagy: return "Ketosis / Autophagy"
        }
    }
    
    var icon: String {
        switch self {
        case .risingBloodSugar: return "🍽"
        case .bloodSugarFalling: return "📉"
        case .bloodSugarBaseline: return "⚖️"
        case .fatBurningBegins: return "🔥"
        case .fatBurningMode: return "🔥🔥"
        case .ketosisAutophagy: return "✨"
        }
    }
    
    var color: Color {
        switch self {
        case .risingBloodSugar: return Color(hex: "8A8A8E")
        case .bloodSugarFalling: return Color(hex: "8A8A8E")
        case .bloodSugarBaseline: return Color(hex: "5AC8C8")
        case .fatBurningBegins: return Color(hex: "F5A623")
        case .fatBurningMode: return Color(hex: "E8640F")
        case .ketosisAutophagy: return Color(hex: "7CB66A")
        }
    }
    
    static func stage(for hours: Double) -> FastingStage {
        switch hours {
        case 0..<4: return .risingBloodSugar
        case 4..<8: return .bloodSugarFalling
        case 8..<12: return .bloodSugarBaseline
        case 12..<14: return .fatBurningBegins
        case 14..<16: return .fatBurningMode
        default: return .ketosisAutophagy
        }
    }
}
