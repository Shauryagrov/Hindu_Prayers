import SwiftUI

/// A single-step onboarding screen that highlights the core experience and guides kids into the main app flow.
struct OnboardingIntroView: View {
    /// Action executed when the user chooses to continue into the main experience.
    let onContinue: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            overlayGradient

            MantraParticleField()
                .opacity(colorScheme == .dark ? 0.55 : 0.28)
                .blendMode(.plusLighter)
                .allowsHitTesting(false)

            VStack(spacing: 24) {
                header

                Spacer(minLength: 12)

                VStack(spacing: 14) {
                    Text("Chant. Learn. Grow.")
                        .font(.system(size: 30, weight: .bold, design: .serif))
                        .foregroundColor(titleColor)
                        .multilineTextAlignment(.center)

                    Text("Hindu prayers with interactive verses and audio guidance.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(descriptionColor)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("onboardingDescription")
                }
                .padding(.horizontal, 8)

                VStack(alignment: .leading, spacing: 16) {
                    OnboardingPoint(icon: "play.circle.fill", title: "Tap a glowing verse", detail: "Hear the mantra, read along, and learn.")
                    OnboardingPoint(icon: "sparkles", title: "Ask Hanuman ji", detail: "Ask questions and get friendly answers anytime.")
                    OnboardingPoint(icon: "star.fill", title: "Collect blessings", detail: "Complete prayers to earn badges and keep your streak glowing.")
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(cardBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(AppColors.gold.opacity(colorScheme == .dark ? 0.45 : 0.35), lineWidth: 1)
                        )
                        .shadow(color: cardShadowColor, radius: 16, x: 0, y: 10)
                )

                Button(action: onContinue) {
                    HStack(spacing: 10) {
                        Text("Let's Begin")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        Text("चलो शुरू करें")
                            .font(AppFonts.hindiBody.weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(AppGradients.saffronGold)
                    .cornerRadius(20)
                    .shadow(color: AppColors.saffron.opacity(colorScheme == .dark ? 0.45 : 0.35), radius: 14, x: 0, y: 10)
                }
                .accessibilityLabel("Let's begin. चलो शुरू करें")
                .accessibilityHint("Double-tap to open the Hanuman Chalisa library")

                Spacer(minLength: 24)
            }
            .padding(24)
            .onAppear {
            }
        }
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? AppColors.nightBackground : AppColors.warmWhite
    }

    private var titleColor: Color {
        colorScheme == .dark ? AppColors.nightHighlight : AppColors.saffronDark
    }

    private var descriptionColor: Color {
        colorScheme == .dark ? AppColors.warmWhite.opacity(0.82) : AppColors.textSecondary
    }

    private var cardBackgroundColor: Color {
        colorScheme == .dark ? AppColors.nightSurface.opacity(0.92) : AppColors.cream.opacity(0.98)
    }

    private var cardShadowColor: Color {
        colorScheme == .dark ? AppColors.nightHighlight.opacity(0.25) : AppColors.saffron.opacity(0.16)
    }

    private var overlayGradient: some View {
        ZStack {
            RadialGradient(
                colors: [overlayHighlight.opacity(colorScheme == .dark ? 0.4 : 0.28), .clear],
                center: .top,
                startRadius: 40,
                endRadius: 520
            )
            .ignoresSafeArea()

            LinearGradient(
                colors: [Color.clear, Color.clear, overlayHighlight.opacity(colorScheme == .dark ? 0.28 : 0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    private var overlayHighlight: Color {
        colorScheme == .dark ? AppColors.nightHighlight : AppColors.lightSaffron
    }

    private var header: some View {
        HStack {
            Spacer()

            Button(action: onContinue) {
                Text("Skip")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? AppColors.nightHighlight : AppColors.deepRed)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(cardBackgroundColor)
                    )
            }
            .accessibilityLabel("Skip onboarding")
            .accessibilityHint("Double-tap to open the Hanuman Chalisa library")
        }
    }
}

private struct OnboardingPoint: View {
    let icon: String
    let title: String
    let detail: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 30, height: 30)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(pointTitleColor)

                Text(detail)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(pointDetailColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(detail)")
    }

    private var iconColor: Color {
        colorScheme == .dark ? AppColors.nightHighlight : AppColors.saffronDark
    }

    private var pointTitleColor: Color {
        colorScheme == .dark ? AppColors.warmWhite : AppColors.saffronDark
    }

    private var pointDetailColor: Color {
        colorScheme == .dark ? AppColors.warmWhite.opacity(0.75) : AppColors.textSecondary
    }
}

#Preview {
    OnboardingIntroView(onContinue: {})
}

