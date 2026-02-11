import Foundation

struct FastingPlan: Identifiable, Hashable {
    let id: String
    let name: String
    let fastHours: Double
    let eatHours: Double
    let description: String
    
    var displayName: String { name }
    
    static let plans: [FastingPlan] = [
        FastingPlan(
            id: "16:8",
            name: "16:8",
            fastHours: 16,
            eatHours: 8,
            description: "The classic. Most popular."
        ),
        FastingPlan(
            id: "18:6",
            name: "18:6",
            fastHours: 18,
            eatHours: 6,
            description: "Intermediate fasting."
        ),
        FastingPlan(
            id: "20:4",
            name: "20:4",
            fastHours: 20,
            eatHours: 4,
            description: "The warrior diet."
        ),
        FastingPlan(
            id: "OMAD",
            name: "OMAD",
            fastHours: 23,
            eatHours: 1,
            description: "One meal a day."
        ),
        FastingPlan(
            id: "Custom",
            name: "Custom",
            fastHours: 0,
            eatHours: 0,
            description: "Set your own hours."
        )
    ]
    
    static func plan(for name: String) -> FastingPlan? {
        plans.first { $0.id == name }
    }
}
