import SwiftUI

struct HomeView: View {
    @State private var goToLocal = false
    @State private var goToOnline = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 8) {
                    Image("GameIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 26))
                        .shadow(
                            color: AppTheme.accent.opacity(0.3),
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                    Text("Who's the fake?")
                        .foregroundStyle(AppTheme.secondaryText)
                }
                
                Spacer()
                
                // ── Mode Buttons ──
                VStack(spacing: 16) {
                    Button {
                        goToLocal = true
                    } label: {
                        ModeCard(
                            icon: "iphone",
                            title: "Local / Pass & Play",
                            subtitle: "One phone · No internet needed",
                            color: AppTheme.accent
                        )
                    }
                    
                    Button {
                        goToOnline = true
                    } label: {
                        ModeCard(
                            icon: "wifi",
                            title: "Online Multiplayer",
                            subtitle: "Play with friends remotely",
                            color: AppTheme.accent
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.background)
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("")
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $goToLocal) {
                LocalSetupView()
            }
            .navigationDestination(isPresented: $goToOnline) {
                OnlineLobbyView()
            }
        }
    }
}

struct ModeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
