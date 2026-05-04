import SwiftUI

// ── Router — picks which screen to show ──
struct LocalGameFlowView: View {
    @ObservedObject var vm: LocalGameViewModel
    
    var body: some View {
        switch vm.currentPhase {
        case .setup:
            Text("Setup")
        case .roleReveal:
            RoleRevealView(vm: vm)
        case .discussion:
            DiscussionView(vm: vm)
        case .voting:
            LocalVoteView(vm: vm)
        case .results:
            LocalResultsView(vm: vm)
        case .gameOver:
            LocalGameOverView(vm: vm)
        }
    }
}

// ── Main Role Reveal Coordinator ──
struct RoleRevealView: View {
    @ObservedObject var vm: LocalGameViewModel
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea(edges: .bottom)
            
            if vm.isScreenLocked {
                PassPhoneScreen(vm: vm)
            } else if vm.isRoleRevealed {
                RoleCardView(vm: vm)
            } else {
                TapToRevealView(vm: vm)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: vm.isRoleRevealed)
        .animation(.easeInOut(duration: 0.3), value: vm.isScreenLocked)
        .navigationBarBackButtonHidden(true)
    }
}

// ── Step 1: Pass the phone screen ──
struct PassPhoneScreen: View {
    @ObservedObject var vm: LocalGameViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "iphone.and.arrow.forward")
                .font(.system(size: 70))
                .foregroundStyle(.orange)
            
            Text("Pass the phone to")
                .font(.title2)
                .foregroundStyle(AppTheme.secondaryText)
            
            Text(vm.currentPlayerName)
                .font(.largeTitle.bold())
                .foregroundStyle(AppTheme.primaryText)
            
            Text("Don't show anyone else!")
                .font(.subheadline)
                .foregroundStyle(AppTheme.accent)
            
            Spacer()
            
            Button {
                vm.confirmPassed()
            } label: {
                Text("I have the phone ✓")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .ignoresSafeArea(edges: .bottom)
    }
}

// ── Step 2: Tap to reveal ──
struct TapToRevealView: View {
    @ObservedObject var vm: LocalGameViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text(vm.currentPlayerName)
                .font(.largeTitle.bold())
                .foregroundStyle(AppTheme.primaryText)
            
            Text("Tap below to see your word")
                .foregroundStyle(AppTheme.secondaryText)
            
            Button {
                vm.revealRole()
            } label: {
                VStack(spacing: 12) {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 40))
                    Text("Reveal My Word")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(28)
                .background(AppTheme.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .ignoresSafeArea(edges: .bottom)
    }
}

// ── Step 3: Word card — same for everyone ──
struct RoleCardView: View {
    @ObservedObject var vm: LocalGameViewModel
    
    var role: LocalGameViewModel.LocalRole? {
        vm.roleFor(vm.currentPlayerName)
    }
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            if let role {
                Text("🔵")
                    .font(.system(size: 90))
                
                Text("Category: \(role.category)")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
                
                Text(role.word)
                    .font(.system(size: 44, weight: .black))
                    .foregroundStyle(AppTheme.primaryText)
                
                Text("Remember your word.\nDiscuss with the group!")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.secondaryText)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            Button {
                vm.doneViewing()
            } label: {
                Text("Done — Lock Screen")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.cardBackground)
                    .foregroundStyle(AppTheme.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .ignoresSafeArea(edges: .bottom)
    }
}
