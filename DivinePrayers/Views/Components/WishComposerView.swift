import SwiftUI
import AVFoundation

struct WishComposerView: View {
    let onWishReleased: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var wishText: String = ""
    @State private var showingRelease = false
    @State private var releasedWish: String?
    @State private var showGuidance = false
    @State private var ambientPlayer: AVAudioPlayer? = nil
    @State private var isWishLocked = false
    @FocusState private var isTextFocused: Bool
    
    private var accentColor: Color {
        colorScheme == .dark ? AppColors.saffron : AppColors.saffronDark
    }
    
    private var isSendDisabled: Bool {
        wishText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || showingRelease
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 22) {
                dragIndicator
                header
                wishEditor
                actionControl
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .background(colorScheme == .dark ? AppColors.nightSurface : AppColors.warmWhite)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isTextFocused = true
                }
                startGuidance()
                playAmbientTone()
            }
            .onDisappear {
                ambientPlayer?.stop()
                ambientPlayer = nil
            }
            
            if showingRelease {
                WishReleaseExperience(
                    accentColor: accentColor,
                    reduceMotion: reduceMotion,
                    wishText: releasedWish ?? wishText,
                    onCompleted: {
                        showingRelease = false
                        wishText = ""
                        releasedWish = nil
                        isWishLocked = false
                        onWishReleased()
                        dismiss()
                    }
                )
                .transition(.opacity)
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
            
        Text("Close your eyes, let the heart speak, and whisper your wish. When you send it, the words dissolve—only the feeling remains.")
            .font(.system(size: 16, weight: .medium, design: .rounded))
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
                .disabled(isWishLocked)
            
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
    
    private var actionControl: some View {
        Group {
            if showingRelease {
                ShimmeringReleaseButton(accentColor: accentColor)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
            } else {
                MagicalSendButton(
                    accentColor: accentColor,
                    disabled: isSendDisabled,
                    pulse: showGuidance,
                    reduceMotion: reduceMotion,
                    colorScheme: colorScheme,
                    action: sendWish
                )
                .accessibilityLabel("Hold your wish gently. Send and release.")
                .padding(.top, 4)
                .padding(.bottom, 12)
            }
        }
    }
    
    private func sendWish() {
        let trimmed = wishText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        ambientPlayer?.setVolume(0, fadeDuration: 0.8)
        withAnimation(.easeInOut(duration: 0.3)) {
            showGuidance = false
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        releasedWish = wishText
        isWishLocked = true
        isTextFocused = false
        withAnimation(.easeInOut(duration: 0.4)) {
            showingRelease = true
        }
        MagicalAudioPlayer.shared.playWishWhoosh()
    }
    
    private func startGuidance() {
        withAnimation(.easeInOut(duration: 0.6)) {
            showGuidance = true
        }
    }
    
    private func playAmbientTone() {
        guard let url = Bundle.main.url(forResource: "ambient_twinkle", withExtension: "mp3") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = 0.25
            player.play()
            ambientPlayer = player
        } catch {
            ambientPlayer = nil
        }
    }
}

private struct MagicalSendButton: View {
    let accentColor: Color
    let disabled: Bool
    let pulse: Bool
    let reduceMotion: Bool
    let colorScheme: ColorScheme
    let action: () -> Void
    
    @State private var shimmer = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                VStack(spacing: 2) {
                    Text("✨ Hold your wish gently")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(textColor)
                    Text("Let the heart speak in kind whispers.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(textColor.opacity(0.85))
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(textColor)
                    Text("Send & Release")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(textColor)
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(gradientBackground.opacity(disabled ? 0.7 : 1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(borderGradient.opacity(disabled ? 0.75 : 1), lineWidth: 1.4)
                    )
                    .overlay(shimmerLayer.mask(RoundedRectangle(cornerRadius: 26, style: .continuous)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color.black.opacity(overlayOpacity))
                    )
            )
            .shadow(color: accentColor.opacity(disabled ? 0.12 : 0.25), radius: 18, x: 0, y: 10)
            .scaleEffect(scaleEffect)
            .animation(pulseAnimation, value: pulse)
        }
        .disabled(disabled)
        .buttonStyle(.plain)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(Animation.linear(duration: 2.6).repeatForever(autoreverses: false)) {
                shimmer = true
            }
        }
    }
    
    private var gradientBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.00, green: 0.54, blue: 0.25),
                Color(red: 1.00, green: 0.80, blue: 0.12),
                Color(red: 0.34, green: 0.86, blue: 0.67),
                Color(red: 0.39, green: 0.58, blue: 1.00),
                Color(red: 0.85, green: 0.55, blue: 1.00)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.99, green: 0.74, blue: 0.47),
                Color(red: 0.65, green: 0.78, blue: 0.98)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var shimmerLayer: some View {
        Group {
            if reduceMotion {
                EmptyView()
            } else {
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.0),
                        Color.white.opacity(disabled ? 0.25 : 0.45),
                        Color.white.opacity(0.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 140)
                .offset(x: shimmer ? 240 : -240)
            }
        }
    }
    
    private var scaleEffect: CGFloat {
        guard !reduceMotion, pulse else { return 1 }
        return 1.03
    }
    
    private var textColor: Color {
        colorScheme == .dark ? .white : AppColors.textPrimary
    }
    
    private var overlayOpacity: Double {
        colorScheme == .dark ? 0 : 0.08
    }
    
    private var pulseAnimation: Animation? {
        guard !reduceMotion else { return nil }
        return Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true)
    }
}

private struct ShimmeringReleaseButton: View {
    let accentColor: Color
    @State private var shimmer = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(rainbowGlow)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(rainbowBorder, lineWidth: 1.4)
                )
                .overlay(shimmerLayer.mask(RoundedRectangle(cornerRadius: 26, style: .continuous)))
                .shadow(color: accentColor.opacity(0.28), radius: 18, x: 0, y: 10)
            HStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.1)
                Text("Releasing…")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .onAppear {
            withAnimation(Animation.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                shimmer = true
            }
        }
        .accessibilityLabel("Releasing wish")
    }
    
    private var shimmerLayer: some View {
        LinearGradient(
            colors: [Color.white.opacity(0.0), Color.white.opacity(0.55), Color.white.opacity(0.0)],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: 200)
        .offset(x: shimmer ? 220 : -220)
    }
    
    private var rainbowGlow: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.00, green: 0.54, blue: 0.25),
                Color(red: 1.00, green: 0.80, blue: 0.12),
                Color(red: 0.34, green: 0.86, blue: 0.67),
                Color(red: 0.39, green: 0.58, blue: 1.00),
                Color(red: 0.85, green: 0.55, blue: 1.00)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var rainbowBorder: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.00, green: 0.75, blue: 0.35),
                Color(red: 0.68, green: 0.78, blue: 1.00)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private struct WishReleaseExperience: View {
    let accentColor: Color
    let reduceMotion: Bool
    let wishText: String
    let onCompleted: () -> Void
    @State private var animateOrb = false
    @State private var fadeOut = false
    private let sparkles = Sparkle.randomSet(count: 18)
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                RadialGradient(colors: [accentColor.opacity(0.55), .clear], center: .center, startRadius: 60, endRadius: geo.size.width)
                    .ignoresSafeArea()
                    .opacity(fadeOut ? 0 : 1)
                
                ForEach(sparkles) { sparkle in
                    Circle()
                        .fill(accentColor.opacity(0.18 + sparkle.opacityBoost))
                        .frame(width: sparkle.size, height: sparkle.size)
                        .position(x: sparkle.position(in: geo.size).x,
                                  y: animateOrb ? sparkle.endPosition(in: geo.size).y : sparkle.position(in: geo.size).y)
                        .opacity(fadeOut ? 0 : 1)
                        .blur(radius: 0.6)
                        .animation(
                            reduceMotion ? .default : .easeInOut(duration: sparkle.duration).repeatForever(autoreverses: true).delay(sparkle.delay),
                            value: animateOrb
                        )
                }
                
                VStack(spacing: 18) {
                    Circle()
                        .fill(
                            RadialGradient(colors: [Color.white.opacity(0.92), accentColor], center: .center, startRadius: 2, endRadius: 48)
                        )
                        .frame(width: 88, height: 88)
                        .shadow(color: accentColor.opacity(0.45), radius: 18, x: 0, y: 12)
                        .offset(y: animateOrb ? -geo.size.height * 0.5 : 0)
                        .rotationEffect(.degrees(animateOrb ? 320 : 0))
                        .opacity(fadeOut ? 0 : 1)
                        .animation(reduceMotion ? .default : .easeInOut(duration: 1.6), value: animateOrb)
                        .animation(reduceMotion ? .default : .easeInOut(duration: 0.6), value: fadeOut)
                    
                    Text("Hanuman ji carries your wish on the wind.")
                        .font(.system(size: 18, weight: .semibold, design: .serif))
                        .foregroundStyle(accentColor)
                        .multilineTextAlignment(.center)
                        .opacity(fadeOut ? 0 : 1)
                        .padding(.horizontal, 24)
                    
                    Text("Trust that the feeling in your heart has been heard.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(fadeOut ? 0 : 1)
                        .padding(.horizontal, 24)

                    if !wishText.isEmpty {
                        Text(wishText)
                            .font(.system(size: 17, weight: .medium, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(accentColor.opacity(0.35))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(Color.white.opacity(0.65), lineWidth: 1)
                                    )
                            )
                            .shadow(color: accentColor.opacity(0.35), radius: 16, x: 0, y: 8)
                            .opacity(fadeOut ? 0 : 1)
                            .offset(y: fadeOut ? -90 : 0)
                            .scaleEffect(fadeOut ? 0.92 : 1)
                            .blur(radius: fadeOut ? 6 : 0)
                            .animation(
                                reduceMotion ? .default :
                                    .easeInOut(duration: 0.8),
                                value: fadeOut
                            )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .ignoresSafeArea()
            .onAppear {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                guard !reduceMotion else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        onCompleted()
                    }
                    return
                }
                withAnimation(.easeInOut(duration: 1.6)) {
                    animateOrb = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        fadeOut = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.8) {
                    onCompleted()
                }
            }
        }
    }
    
    private struct Sparkle: Identifiable {
        let id = UUID()
        let baseX: CGFloat
        let baseY: CGFloat
        let drift: CGFloat
        let size: CGFloat
        let delay: Double
        let duration: Double
        let opacityBoost: Double
        
        static func randomSet(count: Int) -> [Sparkle] {
            (0..<count).map { _ in
                Sparkle(
                    baseX: .random(in: 0.1...0.9),
                    baseY: .random(in: 0.25...0.9),
                    drift: .random(in: -0.18...0.18),
                    size: .random(in: 6...18),
                    delay: .random(in: 0...0.8),
                    duration: .random(in: 2.0...3.6),
                    opacityBoost: .random(in: 0...0.25)
                )
            }
        }
        
        func position(in size: CGSize) -> CGPoint {
            CGPoint(x: baseX * size.width, y: baseY * size.height)
        }
        
        func endPosition(in size: CGSize) -> CGPoint {
            CGPoint(x: (baseX + drift) * size.width, y: max(40, (baseY - 0.45) * size.height))
        }
    }
}

private final class MagicalAudioPlayer {
    static let shared = MagicalAudioPlayer()
    private var whooshPlayer: AVAudioPlayer?
    
    private init() {}
    
    func playWishWhoosh() {
        guard let url = Bundle.main.url(forResource: "wish_whoosh", withExtension: "mp3") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0.45
            player.play()
            whooshPlayer = player
        } catch {
            whooshPlayer = nil
        }
    }
}
