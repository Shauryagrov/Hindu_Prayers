import SwiftUI
import AVFoundation

struct WelcomeView: View {
    var showMainApp: (Int) -> Void
    @State private var showTapFlash = false
    @State private var hasStartedAmbientElements = false
    @State private var hasPlayedWelcomeSound = false
    private let audioService: AudioServiceProtocol = AudioService()
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundGradient: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [AppColors.nightBackground, AppColors.nightSurface],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        return AppGradients.background
    }
    
    private var haloGradient: RadialGradient {
        let topColor = colorScheme == .dark ? AppColors.nightHighlight.opacity(0.32) : AppColors.lightSaffron.opacity(0.35)
        return RadialGradient(
            colors: [topColor, .clear],
            center: .top,
            startRadius: 40,
            endRadius: 360
        )
    }

    var body: some View {
        ZStack {
            backgroundGradient
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    haloGradient
                    .offset(y: -120)
                )

            MantraParticleField()

            VStack(spacing: 28) {
                Spacer(minLength: 80)

                VStack(spacing: 6) {
                    Text("Hindu Prayers")
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .foregroundStyle(AppGradients.goldSaffron)

                    Text("हिंदू प्रार्थनाएं")
                        .font(AppFonts.hindiTitle)
                        .foregroundStyle(AppGradients.saffronGold)
                }

                Button(action: handleHeroTap) {
                    GlowingHero()
                        .frame(width: 240, height: 240)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Start • प्रारंभ")
                .accessibilityHint("Double-tap to open the Hanuman Chalisa journey")

                Button(action: handleHeroTap) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)

                        VStack(spacing: 2) {
                            Text("Start")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)

                            Text("प्रारंभ")
                                .font(AppFonts.hindiBody.weight(.semibold))
                                .foregroundColor(AppColors.warmWhite)
                        }
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: 240)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(AppGradients.saffronGold)
                            .shadow(color: AppColors.saffron.opacity(0.35), radius: 14, x: 0, y: 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(AppColors.gold.opacity(0.65), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Start • प्रारंभ")
                .accessibilityHint("Double-tap to open the Hanuman Chalisa journey")
                .padding(.top, 10)

                Spacer()
            }
            .padding(.horizontal, 24)

            if showTapFlash {
                TapFlashOverlay()
                    .frame(width: 340, height: 340)
                    .allowsHitTesting(false)
                    .transition(.scale)
            }

        }
        .onAppear {
            startAmbientElementsIfNeeded()
        }
    }

    private func handleHeroTap() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

        withAnimation(.easeOut(duration: 0.28)) {
            showTapFlash = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            showMainApp(0)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.35)) {
                showTapFlash = false
            }
        }
    }

    private func startAmbientElementsIfNeeded() {
        guard !hasStartedAmbientElements else { return }
        hasStartedAmbientElements = true

        playWelcomeSoundIfPossible()
    }

    private func playWelcomeSoundIfPossible() {
        guard !hasPlayedWelcomeSound else { return }
        hasPlayedWelcomeSound = true

        audioService.preloadAudio(fileNames: ["tanpura_intro"])

        let session = AVAudioSession.sharedInstance()
        guard !session.isOtherAudioPlaying, !session.secondaryAudioShouldBeSilencedHint else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            _ = try? audioService.playAudio(fileName: "tanpura_intro")
        }
    }
}

struct GlowingHero: View {
    @State private var outerPulse = false
    @State private var innerPulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    AngularGradient(
                        colors: [
                            AppColors.saffron,
                            AppColors.gold,
                            AppColors.deepRed,
                            AppColors.royalBlue,
                            AppColors.saffron
                        ],
                        center: .center
                    )
                )
                .frame(width: 240, height: 240)
                .overlay(
                    Circle()
                        .stroke(AppColors.warmWhite.opacity(0.6), lineWidth: 2)
                )
                .overlay(
                    Circle()
                        .fill(AppColors.gold.opacity(0.25))
                        .blur(radius: 45)
                        .scaleEffect(outerPulse ? 1.18 : 0.96)
                        .opacity(outerPulse ? 0.9 : 0.4)
                )
                .overlay(
                    Circle()
                        .stroke(AppColors.lightSaffron.opacity(0.25), lineWidth: 3)
                        .blur(radius: 22)
                        .scaleEffect(innerPulse ? 1.32 : 0.88)
                        .opacity(innerPulse ? 0.6 : 0.25)
                )
                .shadow(color: AppColors.gold.opacity(0.55), radius: 35, x: 0, y: 18)
                .scaleEffect(outerPulse ? 1.04 : 0.98)
                .onAppear {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        outerPulse = true
                    }

                    withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                        innerPulse = true
                    }
                }

            Text("ॐ")
                .font(.system(size: 94, weight: .semibold, design: .serif))
                .foregroundColor(.white)
                .shadow(color: AppColors.warmWhite.opacity(0.85), radius: 16, x: 0, y: 8)
                .overlay(
                    Text("ॐ")
                        .font(.system(size: 94, weight: .semibold, design: .serif))
                        .foregroundColor(AppColors.gold.opacity(0.6))
                        .blur(radius: 14)
                )
        }
    }
}

struct MantraParticleField: View {
    private let particles: [Particle] = Particle.generate(count: 26)
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            GeometryReader { geometry in
                ZStack {
                    ForEach(particles) { particle in
                        ParticleSprite(
                            particle: particle,
                            containerSize: geometry.size,
                            timeline: time,
                            colorScheme: colorScheme
                        )
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }

    private struct ParticleSprite: View {
        let particle: Particle
        let containerSize: CGSize
        let timeline: TimeInterval
        let colorScheme: ColorScheme

        var travelDistance: CGFloat {
            containerSize.height + particle.startOffset + particle.endOffset
        }

        var xPosition: CGFloat {
            containerSize.width * particle.xFactor
        }

        var progress: Double {
            let time = timeline + particle.timeOffset
            let base = time.truncatingRemainder(dividingBy: particle.duration)
            return base / particle.duration
        }

        var yPosition: CGFloat {
            let startY = containerSize.height + particle.startOffset
            return startY - (CGFloat(progress) * travelDistance)
        }

        var fade: Double {
            let leading = min(progress / 0.15, 1)
            let trailing = min((1 - progress) / 0.2, 1)
            return Double(leading * trailing)
        }

        var body: some View {
            Group {
                switch particle.kind {
                case .spark:
                    Circle()
                        .fill(particleSparkColor)
                        .frame(width: particle.size, height: particle.size)
                case .glyph:
                    Text("ॐ")
                        .font(.system(size: particle.size, weight: .light, design: .serif))
                        .foregroundStyle(particleGlyphStyle)
                        .shadow(color: AppColors.gold.opacity(0.35), radius: 4, x: 0, y: 0)
                }
            }
            .position(x: xPosition, y: yPosition)
            .scaleEffect(particle.scale)
            .opacity(particle.opacity * fade)
            .blendMode(.screen)
            .animation(nil, value: timeline)
        }
        
        var particleSparkColor: Color {
            let base = colorScheme == .dark ? AppColors.nightHighlight : AppColors.lightSaffron
            return base.opacity(particle.opacity)
        }
        
        var particleGlyphStyle: some ShapeStyle {
            colorScheme == .dark ? LinearGradient(
                colors: [AppColors.nightHighlight, AppColors.gold],
                startPoint: .top,
                endPoint: .bottom
            ) : AppGradients.saffronGold
        }
    }

    private struct Particle: Identifiable {
        enum Kind {
            case spark
            case glyph
        }

        let id = UUID()
        let xFactor: CGFloat
        let startOffset: CGFloat
        let endOffset: CGFloat
        let size: CGFloat
        let opacity: Double
        let duration: Double
        let scale: CGFloat
        let timeOffset: Double
        let kind: Kind

        static func generate(count: Int) -> [Particle] {
            (0..<count).map { index in
                let randomX = CGFloat.random(in: 0.05...0.95)
                let startOffset = CGFloat.random(in: 60...260)
                let endOffset = CGFloat.random(in: 60...220)
                let size = CGFloat.random(in: 7...20)
                let opacity = Double.random(in: 0.18...0.4)
                let duration = Double.random(in: 12...20)
                let scale = CGFloat.random(in: 0.75...1.22)
                let timeOffset = Double(index) * Double.random(in: 0.35...0.8)
                let glyphChance = Double.random(in: 0...1)
                let kind: Kind = glyphChance < 0.42 ? .glyph : .spark

                return Particle(
                    xFactor: randomX,
                    startOffset: startOffset,
                    endOffset: endOffset,
                    size: size,
                    opacity: opacity,
                    duration: duration,
                    scale: scale,
                    timeOffset: timeOffset,
                    kind: kind
                )
            }
        }
    }
}

private struct TapFlashOverlay: View {
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        AppColors.warmWhite.opacity(0.85),
                        AppColors.gold.opacity(0.6),
                        .clear
                    ],
                    center: .center,
                    startRadius: 20,
                    endRadius: 200
                )
            )
            .opacity(0.95)
            .scaleEffect(1.35)
            .blur(radius: 12)
    }
}

#Preview {
    WelcomeView(showMainApp: { _ in })
}
