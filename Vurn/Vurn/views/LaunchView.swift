import SwiftUI

struct LaunchView: View {
    @State private var flameBricks: [FlameBrick] = []
    @State private var isFlameBuilt = false
    @State private var flameIgnited = false
    @State private var backgroundOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var showCheckmark = false
    @State private var sparkles: [SparkleEffect] = []
    @State private var fireParticles: [FireParticle] = []
    
    var onAnimationComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Epic background with multiple gradients
            ZStack {
                // Base dark background
                AppColors.darkGreen.darker(by: 0.3)
                    .ignoresSafeArea()
                
                // Animated radial gradient
                RadialGradient(
                    gradient: Gradient(colors: [
                        AppColors.darkGreen.opacity(backgroundOpacity * 0.8),
                        AppColors.darkGreen.darker().opacity(backgroundOpacity),
                        Color.black.opacity(backgroundOpacity * 0.5)
                    ]),
                    center: .center,
                    startRadius: 50,
                    endRadius: 500
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 2.0), value: backgroundOpacity)
                
                // Fire glow effect when flame ignites
                if flameIgnited {
                    RadialGradient(
                        gradient: Gradient(colors: [
                            AppColors.accentYellow.opacity(0.4),
                            Color.orange.opacity(0.2),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 50,
                        endRadius: 300
                    )
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 1.0), value: flameIgnited)
                }
            }
            
            VStack(spacing: 40) {
                // Epic Flame Building Animation
                ZStack {
                    // Build flame brick by brick
                    ForEach(flameBricks.indices, id: \.self) { index in
                        flameBricks[index].view
                            .opacity(flameBricks[index].isVisible ? 1 : 0)
                            .scaleEffect(flameBricks[index].isVisible ? 1 : 0.3)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(flameBricks[index].delay), value: flameBricks[index].isVisible)
                    }
                    
                    // Fire effect overlay when ignited
                    if flameIgnited {
                        FlameFireEffect()
                            .opacity(flameIgnited ? 1 : 0)
                            .animation(.easeInOut(duration: 0.8), value: flameIgnited)
                    }
                    
                    // Checkmark appears after flame ignites
                    if showCheckmark {
                        CheckmarkEffect()
                            .opacity(showCheckmark ? 1 : 0)
                            .scaleEffect(showCheckmark ? 1 : 0.3)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.5), value: showCheckmark)
                    }
                    
                    // Epic sparkle explosions
                    ForEach(sparkles.indices, id: \.self) { index in
                        sparkles[index].view
                            .opacity(sparkles[index].isVisible ? 1 : 0)
                            .animation(.easeInOut(duration: sparkles[index].duration).delay(sparkles[index].delay), value: sparkles[index].isVisible)
                    }
                    
                    // Fire particles shooting upward
                    ForEach(fireParticles.indices, id: \.self) { index in
                        fireParticles[index].view
                            .opacity(fireParticles[index].isVisible ? 1 : 0)
                            .offset(y: fireParticles[index].offsetY)
                            .animation(.easeInOut(duration: fireParticles[index].duration).delay(fireParticles[index].delay), value: fireParticles[index].isVisible)
                    }
                }
                .frame(width: 140, height: 140)
                
                // "Vurn" text appears when flame ignites
                VStack(spacing: 12) {
                    // Main title with fire effect
                    ZStack {
                        // Fire glow behind text
                        if flameIgnited {
                            Text("Vurn")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundColor(AppColors.accentYellow)
                                .blur(radius: 8)
                                .opacity(0.6)
                        }
                        
                        // Main text
                        Text("Vurn")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundColor(AppColors.lightGreen)
                    }
                    .opacity(textOpacity)
                    .scaleEffect(textOpacity > 0 ? 1 : 0.8)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(4.0), value: textOpacity)
                    
                    // Tagline
                    Text("Ignite Your Fitness")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.accentYellow.opacity(0.9))
                        .opacity(textOpacity)
                        .animation(.easeInOut(duration: 0.8).delay(4.5), value: textOpacity)
                }
            }
        }
        .onAppear {
            startEpicAnimation()
        }
    }
    
    private func startEpicAnimation() {
        // Phase 1: Background emerges (0-1s)
        withAnimation(.easeInOut(duration: 1.0)) {
            backgroundOpacity = 1.0
        }
        
        // Phase 2: Build flame brick by brick (1-3s)
        createFlameBricks()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            buildFlameAnimation()
        }
        
        // Phase 3: Ignite the flame (3s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            igniteFlame()
        }
        
        // Phase 4: Show checkmark (3.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            showCheckmark = true
        }
        
        // Phase 5: Massive sparkle explosion (3.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.8) {
            createSparkleExplosion()
        }
        
        // Phase 6: "Vurn" text appears (4s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            textOpacity = 1.0
        }
        
        // Phase 7: Complete and transition (6s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            withAnimation(.easeInOut(duration: 0.8)) {
                onAnimationComplete()
            }
        }
    }
    
    private func createFlameBricks() {
        // Create flame shape using individual "bricks"
        let flamePositions: [(CGFloat, CGFloat)] = [
            // Bottom row (base)
            (-15, 40), (0, 40), (15, 40),
            // Second row
            (-10, 25), (0, 25), (10, 25),
            // Third row (wider)
            (-20, 10), (-5, 10), (5, 10), (20, 10),
            // Fourth row
            (-15, -5), (0, -5), (15, -5),
            // Top flames (organic shape)
            (-25, -20), (-10, -25), (0, -30), (10, -25), (25, -20),
            (-20, -35), (-5, -40), (5, -40), (20, -35),
            (-10, -50), (0, -55), (10, -50)
        ]
        
        flameBricks = flamePositions.enumerated().map { index, position in
            FlameBrick(
                id: index,
                position: CGPoint(x: position.0, y: position.1),
                delay: Double(index) * 0.08,
                isVisible: false
            )
        }
    }
    
    private func buildFlameAnimation() {
        // Animate each brick appearing
        for i in 0..<flameBricks.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + flameBricks[i].delay) {
                flameBricks[i].isVisible = true
            }
        }
    }
    
    private func igniteFlame() {
        withAnimation(.easeInOut(duration: 0.8)) {
            flameIgnited = true
        }
        
        // Create fire particles
        createFireParticles()
    }
    
    private func createFireParticles() {
        fireParticles = (0..<20).map { index in
            FireParticle(
                id: index,
                startPosition: CGPoint(
                    x: CGFloat.random(in: -30...30),
                    y: CGFloat.random(in: -20...20)
                ),
                delay: Double(index) * 0.1,
                isVisible: false,
                offsetY: -100
            )
        }
        
        // Animate particles
        for i in 0..<fireParticles.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + fireParticles[i].delay) {
                fireParticles[i].isVisible = true
            }
        }
    }
    
    private func createSparkleExplosion() {
        sparkles = (0..<24).map { index in
            let angle = Double(index) * (2 * .pi / 24)
            let radius = CGFloat.random(in: 60...120)
            SparkleEffect(
                id: index,
                position: CGPoint(
                    x: cos(angle) * radius,
                    y: sin(angle) * radius
                ),
                delay: Double(index) * 0.05,
                duration: 1.5,
                isVisible: false
            )
        }
        
        // Trigger sparkle explosion
        for i in 0..<sparkles.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + sparkles[i].delay) {
                sparkles[i].isVisible = true
            }
        }
    }
}

// Data structures for epic effects
struct FlameBrick {
    let id: Int
    let position: CGPoint
    let delay: Double
    var isVisible: Bool
    
    var view: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.lightGreen,
                    AppColors.mediumGreen
                ]),
                startPoint: .top,
                endPoint: .bottom
            ))
            .frame(width: 8, height: 12)
            .offset(x: position.x, y: position.y)
    }
}

struct SparkleEffect {
    let id: Int
    let position: CGPoint
    let delay: Double
    let duration: Double
    var isVisible: Bool
    
    var view: some View {
        ZStack {
            // Star burst effect
            ForEach(0..<8, id: \.self) { ray in
                Rectangle()
                    .fill(AppColors.accentYellow)
                    .frame(width: 2, height: CGFloat.random(in: 15...25))
                    .rotationEffect(.degrees(Double(ray) * 45))
            }
            
            // Center glow
            Circle()
                .fill(AppColors.accentYellow)
                .frame(width: 6, height: 6)
                .blur(radius: 2)
        }
        .offset(x: position.x, y: position.y)
        .scaleEffect(isVisible ? 1.0 : 0.3)
    }
}

struct FireParticle {
    let id: Int
    let startPosition: CGPoint
    let delay: Double
    let duration: Double = 2.0
    var isVisible: Bool
    var offsetY: CGFloat
    
    var view: some View {
        Circle()
            .fill(RadialGradient(
                gradient: Gradient(colors: [
                    AppColors.accentYellow,
                    Color.orange,
                    Color.red.opacity(0.8)
                ]),
                center: .center,
                startRadius: 1,
                endRadius: 4
            ))
            .frame(width: CGFloat.random(in: 4...8))
            .offset(x: startPosition.x, y: startPosition.y)
            .blur(radius: 1)
    }
}

// Flame fire effect overlay
struct FlameFireEffect: View {
    @State private var flicker = false
    
    var body: some View {
        ZStack {
            // Multiple fire layers for realistic effect
            ForEach(0..<6, id: \.self) { layer in
                Ellipse()
                    .fill(RadialGradient(
                        gradient: Gradient(colors: [
                            AppColors.accentYellow.opacity(0.8),
                            Color.orange.opacity(0.6),
                            Color.red.opacity(0.4),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: 40
                    ))
                    .frame(width: 60 + CGFloat(layer * 5), height: 80 + CGFloat(layer * 8))
                    .scaleEffect(flicker ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true).delay(Double(layer) * 0.1), value: flicker)
            }
        }
        .onAppear {
            flicker = true
        }
    }
}

// Checkmark effect
struct CheckmarkEffect: View {
    @State private var drawCheckmark = false
    
    var body: some View {
        ZStack {
            // Glow behind checkmark
            Circle()
                .fill(AppColors.accentYellow.opacity(0.3))
                .frame(width: 50, height: 50)
                .blur(radius: 8)
            
            // Checkmark path
            Path { path in
                path.move(to: CGPoint(x: 10, y: 20))
                path.addLine(to: CGPoint(x: 18, y: 28))
                path.addLine(to: CGPoint(x: 30, y: 12))
            }
            .trim(from: 0, to: drawCheckmark ? 1.0 : 0)
            .stroke(AppColors.accentYellow, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            .frame(width: 40, height: 40)
            .animation(.easeInOut(duration: 0.8), value: drawCheckmark)
            .onAppear {
                drawCheckmark = true
            }
        }
        .offset(x: 25, y: 25) // Position like original logo
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