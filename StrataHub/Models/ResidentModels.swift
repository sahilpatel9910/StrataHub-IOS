import Foundation

struct ResidentProfile: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let ownerships: [Membership]
    let tenancies: [Membership]

    struct Membership: Codable {
        let unit: UnitWithBuilding
    }

    struct UnitWithBuilding: Codable {
        let id: String
        let unitNumber: String
        let building: BuildingSummary
    }

    struct BuildingSummary: Codable {
        let id: String
        let name: String
        let suburb: String
    }

    var primaryUnit: UnitWithBuilding? {
        ownerships.first?.unit ?? tenancies.first?.unit
    }
}

struct ResidentAccess: Codable {
    let hasOwnership: Bool
    let hasTenancy: Bool
}

struct Levy: Codable, Identifiable {
    let id: String
    let amountCents: Int
    let dueDate: Date
    let status: PaymentStatus
    let unitNumber: String
}

struct CustomBill: Codable, Identifiable {
    let id: String
    let title: String
    let amountCents: Int
    let dueDate: Date
    let status: PaymentStatus
}

struct Announcement: Codable, Identifiable {
    let id: String
    let title: String
    let content: String
    let priority: Priority
    let publishedAt: Date?
    let expiresAt: Date?
    let author: Author?

    struct Author: Codable {
        let firstName: String
        let lastName: String
    }
}

struct MaintenanceRequestSummary: Codable, Identifiable {
    let id: String
    let title: String
    let category: MaintenanceCategory
    let priority: Priority
    let status: MaintenanceStatus
    let createdAt: Date
    let unit: RequestUnit?

    struct RequestUnit: Codable {
        let unitNumber: String
        let buildingId: String
    }
}

struct MaintenanceRequestDetail: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let category: MaintenanceCategory
    let priority: Priority
    let status: MaintenanceStatus
    let createdAt: Date
    let scheduledDate: Date?
    let completedDate: Date?
    let unit: DetailUnit
    let images: [MaintenanceImage]
    let comments: [MaintenanceComment]

    struct DetailUnit: Codable {
        let unitNumber: String
        let buildingId: String
        let building: DetailBuilding
    }

    struct DetailBuilding: Codable {
        let name: String
    }
}

struct MaintenanceImage: Codable, Identifiable {
    let id: String
    let displayUrl: String?
    let caption: String?
}

struct MaintenanceComment: Codable, Identifiable {
    let id: String
    let content: String
    let createdAt: Date
    let user: CommentUser

    struct CommentUser: Codable {
        let firstName: String
        let lastName: String
        let avatarUrl: String?
    }
}
