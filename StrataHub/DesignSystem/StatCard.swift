import SwiftUI

struct StatCard: View {
    let label: String
    let value: String
    let systemImage: String
    let tone: BadgeTone

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(tone.background)
                    .frame(width: 44, height: 44)
                Image(systemName: systemImage)
                    .foregroundStyle(tone.foreground)
                    .font(.system(size: 18, weight: .semibold))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(label.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(0.5)
                Text(value)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
            }
            Spacer()
        }
    }
}
