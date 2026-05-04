import SwiftUI

struct DiscussionView: View {
    @ObservedObject var vm: LocalGameViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            
            // ── Header ──
            Text("💬 Discuss!")
                .font(.largeTitle.bold())
                .foregroundStyle(AppTheme.primaryText)
            Text("Who do you think the impostor is?")
                .foregroundStyle(AppTheme.secondaryText)
            
            // ── Timer Ring ──
            TimerRingView(
                timeLeft: vm.discussionTimeLeft,
                total: 180
            )
            
            // ── Alive Players ──
            VStack(alignment: .leading, spacing: 8) {
                Text("Players")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
                    .padding(.horizontal)
                
                ForEach(vm.alivePlayers, id: \.self) { name in
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundStyle(AppTheme.accent)
                        Text(name)
                            .foregroundStyle(AppTheme.primaryText)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            
            Spacer()
            
            // ── Skip to vote ──
            Button("Start Voting Early") {
                vm.skipToVoting()
            }
            .buttonStyle(.bordered)
            .tint(AppTheme.accent)
            .padding(.bottom, 32)
        }
        .padding(.top, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
    }
}

// ── Countdown Ring ──
struct TimerRingView: View {
    let timeLeft: Int
    let total: Int
    
    var progress: CGFloat {
        CGFloat(timeLeft) / CGFloat(total)
    }
    
    var color: Color {
        if timeLeft > 60 { return .green }
        if timeLeft > 30 { return .orange }
        return .red
    }
    
    var timeString: String {
        let m = timeLeft / 60
        let s = timeLeft % 60
        return String(format: "%d:%02d", m, s)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.cardBackground, lineWidth: 14)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(
                    lineWidth: 14,
                    lineCap: .round
                ))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: timeLeft)
            Text(timeString)
                .font(.title.monospacedDigit().bold())
                .foregroundStyle(color)
        }
        .frame(width: 150, height: 150)
    }
}
