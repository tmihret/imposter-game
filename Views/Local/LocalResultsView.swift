import SwiftUI

// ── Round Results ──
struct LocalResultsView: View {
    @ObservedObject var vm: LocalGameViewModel
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            Text(vm.lastEliminatedWasImpostor ? "✅" : "❌")
                .font(.system(size: 90))
            
            if let eliminated = vm.lastEliminated {
                Text("\(eliminated) was eliminated")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.primaryText)
                
                Text(vm.lastEliminatedWasImpostor
                     ? "They WERE the impostor!"
                     : "They were NOT the impostor...")
                    .font(.headline)
                    .foregroundStyle(
                        vm.lastEliminatedWasImpostor ? .green : AppTheme.accent
                    )
            }
            
            VStack(spacing: 8) {
                Text("Still alive:")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
                ForEach(vm.alivePlayers, id: \.self) { name in
                    Text(name)
                        .font(.body.bold())
                        .foregroundStyle(AppTheme.primaryText)
                }
            }
            .padding()
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            
            Spacer()
            
            Button {
                vm.continueAfterResults()
            } label: {
                Text(vm.lastEliminatedWasImpostor || vm.alivePlayers.count <= 2
                     ? "See Final Result"
                     : "Continue to Next Round")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
    }
}

// ── Game Over ──
struct LocalGameOverView: View {
    @ObservedObject var vm: LocalGameViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            Text(vm.crewWon ? "🎉" : "🕵️")
                .font(.system(size: 100))
            
            Text(vm.crewWon ? "Crew Wins!" : "Impostor Wins!")
                .font(.largeTitle.bold())
                .foregroundStyle(vm.crewWon ? .green : AppTheme.accent)
            
            VStack(spacing: 8) {
                Text("The impostor was:")
                    .foregroundStyle(AppTheme.secondaryText)
                Text(vm.impostorName)
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.primaryText)
            }
            .padding()
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Spacer()
            
            // ── Play Again ──
            Button {
                vm.resetGame()
                dismiss()
            } label: {
                Text("Play Again")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
            
            // ── Back to Home ──
            Button {
                vm.resetGame()
                dismiss()
            } label: {
                Text("Back to Home")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
    }
}
