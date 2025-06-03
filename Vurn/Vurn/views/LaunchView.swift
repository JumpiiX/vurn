import SwiftUI

struct LaunchView: View {
    @State private var isAnimating = false
    @State private var flameScale: CGFloat = 0.3
    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkRotation: Double = -45
    @State private var backgroundOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var pulseAnimation = false
    
    var onAnimationComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Animated background gradient
            RadialGradient(
                gradient: Gradient(colors: [
                    AppColors.darkGreen.opacity(backgroundOpacity),
                    AppColors.darkGreen.darker().opacity(backgroundOpacity)
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.0), value: backgroundOpacity)
            
            VStack(spacing: 30) {
                // Logo Animation
                ZStack {
                    // Flame part (appears first)
                    ZStack {
                        // Outer glow effect
                        Image("vurn-logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .scaleEffect(flameScale * 1.1)
                            .opacity(0.3)
                            .blur(radius: 10)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0), value: flameScale)
                        
                        // Main logo
                        Image("vurn-logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .scaleEffect(flameScale)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0), value: flameScale)
                    }
                    .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                    
                    // Sparkle effects around logo
                    ForEach(0..<8, id: \.self) { index in
                        SparkleView(delay: Double(index) * 0.2)
                            .offset(x: cos(Double(index) * .pi / 4) * 80,
                                   y: sin(Double(index) * .pi / 4) * 80)
                            .opacity(isAnimating ? 1 : 0)
                            .animation(.easeInOut(duration: 0.8).delay(1.5 + Double(index) * 0.1), value: isAnimating)
                    }
                }
                
                // App name with typewriter effect
                VStack(spacing: 8) {
                    Text("Vurn")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.lightGreen)
                        .opacity(textOpacity)
                        .animation(.easeInOut(duration: 0.8).delay(2.0), value: textOpacity)
                    
                    Text("Track your fitness journey")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.lightGreen.opacity(0.8))
                        .opacity(textOpacity)
                        .animation(.easeInOut(duration: 0.8).delay(2.5), value: textOpacity)
                }
            }
            
            // Floating particles
            ForEach(0..<15, id: \.self) { index in
                FloatingParticle(delay: Double(index) * 0.3)
                    .opacity(isAnimating ? 0.6 : 0)
                    .animation(.easeInOut(duration: 1.0).delay(1.0 + Double(index) * 0.2), value: isAnimating)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Background fade in
        withAnimation(.easeInOut(duration: 0.5)) {
            backgroundOpacity = 1.0
        }
        
        // Logo scale in with bounce
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                flameScale = 1.0
            }
        }
        
        // Start general animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isAnimating = true
            pulseAnimation = true
        }
        
        // Text fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            textOpacity = 1.0
        }
        
        // Complete animation and transition to main app
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                onAnimationComplete()
            }
        }
    }
}

// Sparkle effect view
struct SparkleView: View {
    let delay: Double
    @State private var isVisible = false
    @State private var scale: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Cross sparkle
            VStack {
                Rectangle()
                    .fill(AppColors.accentYellow)
                    .frame(width: 2, height: 12)
                Rectangle()
                    .fill(AppColors.accentYellow)
                    .frame(width: 12, height: 2)
            }
            .scaleEffect(scale)
            .animation(.easeInOut(duration: 0.6).delay(delay), value: scale)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    scale = 1.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        scale = 0
                    }
                }
            }
        }
    }
}

// Floating particle effect
struct FloatingParticle: View {
    let delay: Double
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var opacity: Double = 0
    
    private let startY = CGFloat.random(in: -100...100)
    private let startX = CGFloat.random(in: -150...150)
    
    var body: some View {
        Circle()
            .fill(AppColors.accentYellow.opacity(0.6))
            .frame(width: CGFloat.random(in: 3...8))
            .offset(x: startX + offsetX, y: startY + offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 3.0).delay(delay).repeatForever(autoreverses: false)) {
                    offsetY = -200
                    offsetX = CGFloat.random(in: -50...50)
                }
                withAnimation(.easeInOut(duration: 1.0).delay(delay)) {
                    opacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + delay + 2.0) {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        opacity = 0
                    }
                }
            }
    }
}

// Extension to create darker color
extension Color {
    func darker(by percentage: CGFloat = 0.2) -> Color {
        return self.opacity(1.0 - percentage)
    }
}

#Preview {
    LaunchView {
        print("Animation completed!")
    }
}