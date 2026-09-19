import SwiftUI

enum Theme {
    static let navy = Color(red: 0.16, green: 0.29, blue: 0.45)
    static let navyDark = Color(red: 0.10, green: 0.19, blue: 0.32)
    static let background = Color(red: 0.96, green: 0.97, blue: 0.98)
    static let panelBackground = Color(red: 0.99, green: 0.99, blue: 1.0)
    static let border = Color(red: 0.88, green: 0.89, blue: 0.92)
    static let textPrimary = Color(red: 0.14, green: 0.16, blue: 0.2)
    static let textSecondary = Color(red: 0.45, green: 0.48, blue: 0.53)

    static let positive = Color(red: 0.06, green: 0.46, blue: 0.34)
    static let positiveBackground = Color(red: 0.85, green: 0.95, blue: 0.89)
    static let warning = Color(red: 0.6, green: 0.4, blue: 0.05)
    static let warningBackground = Color(red: 0.99, green: 0.93, blue: 0.8)
    static let negative = Color(red: 0.6, green: 0.13, blue: 0.13)
    static let negativeBackground = Color(red: 0.99, green: 0.87, blue: 0.87)
    static let info = Color(red: 0.15, green: 0.35, blue: 0.6)
    static let infoBackground = Color(red: 0.87, green: 0.92, blue: 0.99)
    static let neutralBackground = Color(red: 0.92, green: 0.93, blue: 0.95)

    static let cornerRadius: CGFloat = 20
}

extension BadgeTone {
    var foreground: Color {
        switch self {
        case .neutral: return Theme.textSecondary
        case .positive: return Theme.positive
        case .warning: return Theme.warning
        case .negative: return Theme.negative
        case .info: return Theme.info
        }
    }

    var background: Color {
        switch self {
        case .neutral: return Theme.neutralBackground
        case .positive: return Theme.positiveBackground
        case .warning: return Theme.warningBackground
        case .negative: return Theme.negativeBackground
        case .info: return Theme.infoBackground
        }
    }
}

extension Int {
    /// Formats a cents value (e.g. `amountCents`) as AUD currency: 12345 -> "$123.45".
    var centsAsCurrency: String {
        let amount = Decimal(self) / 100
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}
