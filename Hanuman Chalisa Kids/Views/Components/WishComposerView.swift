import SwiftUI

struct WishComposerView: View {
    let onWishReleased: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var wishText: String = ""
    @State private var showingRelease = false
    @FocusState private var isTextFocused: Bool
    
    private var accentColor: Color {
        colorScheme == .dark ? AppColors.saffron : AppColors.saffronDark
    }
    
    private var isSendDisabled: Bool {
        wishText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || showingRelease
    }
    
    var body: some View {
        VStack(spacing: 22) {
            dragIndicator
            header
            wishEditor
            if showingRelease {
                ReleaseView(accentColor: accentColor)
                    .transition(.scale.combined(with: .opacity))
            }
            sendButton
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .background(colorScheme == .dark ? AppColors.nightSurface : AppColors.warmWhite)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isTextFocused = true
            }
        }
    }
    
    private var dragIndicator: some View {
        Capsule()
            .fill(Color.secondary.opacity(0.25))
            .frame(width: 40, height: 4)
            .padding(.top, 8)
            .accessibilityHidden(true)
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Make a Wish")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? AppColors.warmWhite : AppColors.textPrimary)
            
            Text("Close your eyes, breathe deep, and type a wish. When you send it, the words dissolve—only the feeling remains.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var wishEditor: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(colorScheme == .dark ? AppColors.nightCard : AppColors.cream.opacity(0.95))
            
            TextEditor(text: $wishText)
                .padding(14)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(colorScheme == .dark ? AppColors.warmWhite : AppColors.textPrimary)
                .background(Color.clear)
                .focused($isTextFocused)
                .scrollContentBackground(.hidden)
                .frame(height: 160)
            
            if wishText.isEmpty {
                Text("Type your wish here…")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.6))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .allowsHitTesting(false)
            }
        }
    }
    
    private var sendButton: some View {
        let buttonBackground = accentColor.opacity(isSendDisabled ? 0.35 : 1)
        return Button(action: sendWish) {
            HStack(spacing: 10) {
                Image(systemName: "paperplane.fill")
                Text("Send & Release")
            }
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(buttonBackground)
            .foregroundColor(.white)
            .cornerRadius(16)
        }
        .disabled(isSendDisabled)
        .animation(.easeInOut(duration: 0.2), value: isSendDisabled)
    }
    
    private func sendWish() {
        let trimmed = wishText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        wishText = ""
        withAnimation(.easeInOut(duration: 0.4)) {
            showingRelease = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            onWishReleased()
            dismiss()
        }
    }
    
    private struct ReleaseView: View {
        let accentColor: Color
        @State private var floatUp = false
        
        var body: some View {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.18))
                        .frame(width: 70, height: 70)
                    Image(systemName: "sparkles")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(accentColor)
                        .offset(y: floatUp ? -6 : 6)
                }
                
                Text("Your wish is riding the wind…")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(accentColor)
                Text("Hanuman ji hears the feeling in your heart.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    floatUp = true
                }
            }
        }
    }
}
