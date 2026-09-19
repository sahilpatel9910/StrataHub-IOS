import SwiftUI

struct StatusBadge: View {
    let text: String
    let tone: BadgeTone

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(tone.background)
            .foregroundStyle(tone.foreground)
            .clipShape(Capsule())
    }
}
