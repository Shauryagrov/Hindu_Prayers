//
//  HanumanIconView.swift
//  DivinePrayers
//
//  Created by GPT-5 Codex on 11/11/25.
//

import SwiftUI

/// A SwiftUI illustration designed for use as the app icon artwork.
/// Combines warm tones with a playful depiction of young Hanuman
/// to align with the kid-friendly positioning of the app.
struct HanumanIconView: View {
    var body: some View {
        ZStack {
            background
            decorativeHalo
            character
            floatingElements
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: 96, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.99, green: 0.63, blue: 0.20),
                        Color(red: 0.96, green: 0.45, blue: 0.22),
                        Color(red: 0.88, green: 0.35, blue: 0.37)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 96, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 6)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 16)
            .padding(12)
    }

    private var decorativeHalo: some View {
        Circle()
            .strokeBorder(
                AngularGradient(
                    colors: [
                        Color.white.opacity(0.0),
                        Color.white.opacity(0.18),
                        Color.white.opacity(0.0)
                    ],
                    center: .center
                ),
                lineWidth: 22
            )
            .frame(width: 220, height: 220)
            .blendMode(.softLight)
            .padding(.bottom, 48)
    }

    private var character: some View {
        VStack(spacing: 0) {
            face
            torso
            tail
        }
        .padding(.bottom, 42)
    }

    private var face: some View {
        ZStack {
            Circle()
                .fill(Color(red: 1.0, green: 0.86, blue: 0.68))
                .frame(width: 128, height: 128)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 4)
                )

            VStack(spacing: 6) {
                eyes
                mouth
            }

            headgear
        }
        .offset(y: -6)
    }

    private var eyes: some View {
        HStack(spacing: 24) {
            eye
            eye
        }
    }

    private var eye: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 24, height: 24)
            .overlay(
                Circle()
                    .fill(Color.black.opacity(0.75))
                    .frame(width: 12, height: 12)
                    .offset(x: 1, y: 2)
            )
            .overlay(
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 6, height: 6)
                    .offset(x: -3, y: -4)
            )
    }

    private var mouth: some View {
        Capsule()
            .fill(Color(red: 0.91, green: 0.42, blue: 0.36))
            .frame(width: 58, height: 18)
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.25), lineWidth: 3)
            )
    }

    private var headgear: some View {
        VStack(spacing: -6) {
            Circle()
                .fill(Color(red: 0.93, green: 0.65, blue: 0.15))
                .frame(width: 42, height: 42)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.25), lineWidth: 3)
                )
                .overlay(
                    Circle()
                        .fill(Color(red: 0.99, green: 0.86, blue: 0.32))
                        .frame(width: 16, height: 16)
                )

            Capsule()
                .fill(Color(red: 0.93, green: 0.65, blue: 0.15))
                .frame(width: 96, height: 42)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.25), lineWidth: 3)
                )
                .overlay(
                    Text("ૐ")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.99, green: 0.86, blue: 0.32))
                        .accessibilityLabel("Om symbol")
                )
        }
        .offset(y: -94)
    }

    private var torso: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.74, blue: 0.52),
                            Color(red: 0.99, green: 0.68, blue: 0.43)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 96, height: 86)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 3)
                )
                .overlay(
                    VStack(spacing: 2) {
                        Text("श्री")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(red: 0.74, green: 0.17, blue: 0.18))
                        Text("हनुमान")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(red: 0.74, green: 0.17, blue: 0.18))
                    }
                    .multilineTextAlignment(.center)
                )

            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .fill(Color(red: 0.99, green: 0.58, blue: 0.29))
                .frame(width: 116, height: 52)
                .overlay(
                    RoundedRectangle(cornerRadius: 42, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 3)
                )
                .overlay(
                    HStack(spacing: 16) {
                        arm(side: .left)
                        mace
                        arm(side: .right)
                    }
                )
        }
    }

    private enum ArmSide {
        case left
        case right
    }

    private func arm(side: ArmSide) -> some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color(red: 1.0, green: 0.74, blue: 0.52))
            .frame(width: 28, height: 72)
            .rotationEffect(.degrees(side == .left ? -18 : 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.25), lineWidth: 2)
            )
            .offset(y: 12)
    }

    private var mace: some View {
        VStack(spacing: -6) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(red: 0.93, green: 0.65, blue: 0.15))
                .frame(width: 16, height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.99, green: 0.86, blue: 0.32),
                            Color(red: 0.93, green: 0.65, blue: 0.15)
                        ],
                        center: .center,
                        startRadius: 6,
                        endRadius: 34
                    )
                )
                .frame(width: 48, height: 48)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.25), lineWidth: 3)
                )
        }
        .offset(y: -6)
    }

    private var tail: some View {
        Path { path in
            path.move(to: CGPoint(x: 172, y: 260))
            path.addCurve(
                to: CGPoint(x: 110, y: 190),
                control1: CGPoint(x: 206, y: 210),
                control2: CGPoint(x: 150, y: 186)
            )
            path.addCurve(
                to: CGPoint(x: 190, y: 140),
                control1: CGPoint(x: 80, y: 194),
                control2: CGPoint(x: 146, y: 146)
            )
            path.addCurve(
                to: CGPoint(x: 210, y: 220),
                control1: CGPoint(x: 230, y: 134),
                control2: CGPoint(x: 242, y: 196)
            )
        }
        .trim(from: 0, to: 1)
        .stroke(
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.86, blue: 0.32),
                    Color(red: 0.93, green: 0.65, blue: 0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            ),
            style: StrokeStyle(lineWidth: 14, lineCap: .round, lineJoin: .round)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 4, x: 3, y: 3)
        .padding(.leading, 60)
        .padding(.top, -50)
    }

    private var floatingElements: some View {
        ZStack {
            sparkle(at: CGPoint(x: 86, y: 78), scale: 1.0, opacity: 0.9)
            sparkle(at: CGPoint(x: 242, y: 86), scale: 0.8, opacity: 0.75)
            sparkle(at: CGPoint(x: 72, y: 224), scale: 0.9, opacity: 0.6)
            sparkle(at: CGPoint(x: 256, y: 246), scale: 1.1, opacity: 0.8)
        }
    }

    private func sparkle(at point: CGPoint, scale: CGFloat, opacity: Double) -> some View {
        StarShape(points: 6, innerRadiusRatio: 0.5)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.95),
                        Color(red: 1.0, green: 0.84, blue: 0.43)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 28 * scale, height: 28 * scale)
            .opacity(opacity)
            .shadow(color: Color.white.opacity(opacity * 0.6), radius: 6, x: 0, y: 0)
            .position(point)
    }
}

// MARK: - Supporting Shape

private struct StarShape: Shape {
    let points: Int
    let innerRadiusRatio: CGFloat

    func path(in rect: CGRect) -> Path {
        guard points >= 2 else { return Path() }

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * innerRadiusRatio

        var path = Path()
        let angle = .pi / Double(points)

        for i in 0..<(points * 2) {
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let rotation = Double(i) * angle - .pi / 2
            let x = center.x + CGFloat(cos(rotation)) * radius
            let y = center.y + CGFloat(sin(rotation)) * radius
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#if DEBUG
struct HanumanIconView_Previews: PreviewProvider {
    static var previews: some View {
        HanumanIconView()
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
    }
}
#endif

