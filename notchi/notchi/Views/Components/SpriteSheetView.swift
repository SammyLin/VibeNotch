import SwiftUI

struct EmojiView: View {
    let emoji: String
    var fontSize: CGFloat = 28

    var body: some View {
        Text(emoji)
            .font(.system(size: fontSize))
    }
}
