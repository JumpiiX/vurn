import SwiftUI

struct LaunchView: View {
    @State private var showWhiteFlame = false
    @State private var showYellowCheck = false
    @State private var showGreenLeaf = false
    @State private var topTextOpacity: Double = 0
    @State private var bottomTextOpacity: Double = 0
    @State private var backgroundOpacity: Double = 0
    
    var onAnimationComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            AppColors.darkGreen
                .ignoresSafeArea()
                .opacity(backgroundOpacity)
                .animation(.easeInOut(duration: 0.5), value: backgroundOpacity)
            
            VStack {
                // Top text "VURN"
                Text("VURN")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(AppColors.lightGreen)
                    .opacity(topTextOpacity)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: topTextOpacity)
                
                Spacer()
                
                // Center logo animation
                ZStack {
                    // EPIC Logo build animation using PNG images
                    Group {
                        // 1. WHITE FLAME (Biggest piece) - dramatic entrance
                        Image("flame-white")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                            .opacity(showWhiteFlame ? 1 : 0)
                            .scaleEffect(showWhiteFlame ? 1 : 0.1)
                            .rotationEffect(.degrees(showWhiteFlame ? 0 : 45))
                            .animation(.spring(response: 1.0, dampingFraction: 0.6), value: showWhiteFlame)
                        
                        // 2. YELLOW CHECKMARK (Medium piece) - slides in from right
                        Image("checkmark-yellow")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                            .opacity(showYellowCheck ? 1 : 0)
                            .scaleEffect(showYellowCheck ? 1 : 0.2)
                            .offset(x: showYellowCheck ? 0 : 100)
                            .animation(.spring(response: 0.8, dampingFraction: 0.7), value: showYellowCheck)
                        
                        // 3. GREEN LEAF (Smallest piece) - pops in with bounce
                        Image("leaf-green")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                            .opacity(showGreenLeaf ? 1 : 0)
                            .scaleEffect(showGreenLeaf ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.5), value: showGreenLeaf)
                    }
                }
                .frame(height: 200)
                
                Spacer()
                
                // Bottom text "LET IT BURN"
                Text("LET IT BURN")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.accentYellow)
                    .opacity(bottomTextOpacity)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: bottomTextOpacity)
            }
            .padding(.vertical, 80)
        }
        .onAppear {
            startLogoAnimation()
        }
    }
    
    private func startLogoAnimation() {
        // Phase 1: Background (0.2s)
        withAnimation(.easeInOut(duration: 0.5)) {
            backgroundOpacity = 1.0
        }
        
        // Phase 2: White flame shape comes in (0.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showWhiteFlame = true
        }
        
        // Phase 3: Yellow checkmark slides in (1.2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showYellowCheck = true
        }
        
        // Phase 4: Green leaf appears (1.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            showGreenLeaf = true
        }
        
        
        // Phase 6: Show top text "VURN" first (2.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            topTextOpacity = 1.0
        }
        
        // Phase 7: Show bottom text "LET IT BURN" later (3.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            bottomTextOpacity = 1.0
        }
        
        // Phase 8: Complete animation (4.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            onAnimationComplete()
        }
    }
    
}

#Preview {
    LaunchView {
        print("Animation completed!")
    }
}