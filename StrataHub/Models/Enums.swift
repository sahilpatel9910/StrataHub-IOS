import Foundation

enum BadgeTone {
    case neutral, positive, warning, negative, info
}

enum Priority: String, Codable, CaseIterable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    case urgent = "URGENT"

    var label: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .urgent: return "Urgent"
        }
    }

    var badgeTone: BadgeTone {
        switch self {
        case .low: return .neutral
        case .medium: return .info
        case .high: return .warning
        case .urgent: return .negative
        }
    }
}

enum MaintenanceCategory: String, Codable, CaseIterable {
    case plumbing = "PLUMBING"
    case electrical = "ELECTRICAL"
    case hvac = "HVAC"
    case structural = "STRUCTURAL"
    case appliance = "APPLIANCE"
    case pestControl = "PEST_CONTROL"
    case cleaning = "CLEANING"
    case security = "SECURITY"
    case lift = "LIFT"
    case commonArea = "COMMON_AREA"
    case other = "OTHER"

    var label: String {
        switch self {
        case .plumbing: return "Plumbing"
        case .electrical: return "Electrical"
        case .hvac: return "HVAC"
        case .structural: return "Structural"
        case .appliance: return "Appliance"
        case .pestControl: return "Pest Control"
        case .cleaning: return "Cleaning"
        case .security: return "Security"
        case .lift: return "Lift"
        case .commonArea: return "Common Area"
        case .other: return "Other"
        }
    }
}

enum MaintenanceStatus: String, Codable, CaseIterable {
    case submitted = "SUBMITTED"
    case acknowledged = "ACKNOWLEDGED"
    case inProgress = "IN_PROGRESS"
    case awaitingParts = "AWAITING_PARTS"
    case scheduled = "SCHEDULED"
    case completed = "COMPLETED"
    case closed = "CLOSED"
    case cancelled = "CANCELLED"

    var label: String {
        switch self {
        case .submitted: return "Submitted"
        case .acknowledged: return "Acknowledged"
        case .inProgress: return "In Progress"
        case .awaitingParts: return "Awaiting Parts"
        case .scheduled: return "Scheduled"
        case .completed: return "Completed"
        case .closed: return "Closed"
        case .cancelled: return "Cancelled"
        }
    }

    var badgeTone: BadgeTone {
        switch self {
        case .submitted, .acknowledged: return .info
        case .inProgress, .awaitingParts, .scheduled: return .warning
        case .completed, .closed: return .positive
        case .cancelled: return .neutral
        }
    }

    /// Ordered steps for a progress timeline; cancelled requests fall outside this flow.
    static let timelineSteps: [MaintenanceStatus] = [.submitted, .acknowledged, .inProgress, .scheduled, .completed]
}

enum PaymentStatus: String, Codable, CaseIterable {
    case pending = "PENDING"
    case paid = "PAID"
    case overdue = "OVERDUE"
    case partial = "PARTIAL"
    case waived = "WAIVED"

    var label: String {
        switch self {
        case .pending: return "Pending"
        case .paid: return "Paid"
        case .overdue: return "Overdue"
        case .partial: return "Partial"
        case .waived: return "Waived"
        }
    }

    var badgeTone: BadgeTone {
        switch self {
        case .pending: return .warning
        case .paid: return .positive
        case .overdue: return .negative
        case .partial: return .info
        case .waived: return .neutral
        }
    }
}
