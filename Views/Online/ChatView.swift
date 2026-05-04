import SwiftUI

struct ChatView: View {
    @ObservedObject var chatService: ChatService
    let gameId: String
    let isLocked: Bool
    
    @State private var inputText: String = ""
    @State private var isSending: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Message List ──
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(chatService.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .background(AppTheme.background)
                .onChange(of: chatService.messages.count) { _ in
                    if let last = chatService.messages.last?.id {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(last, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
                .background(AppTheme.cardBackground)
            
            // ── Input or Lock Banner ──
            if isLocked {
                HStack {
                    Image(systemName: "lock.fill")
                    Text("Chat locked during voting")
                        .font(.caption)
                }
                .foregroundStyle(AppTheme.secondaryText)
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(AppTheme.cardBackground)
            } else {
                ChatInputBar(
                    inputText: $inputText,
                    isSending: isSending,
                    onSend: sendMessage
                )
            }
        }
        .background(AppTheme.background)
    }
    
    private func sendMessage() {
        let text = inputText
        guard !text.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty else { return }
        
        inputText = ""
        isSending = true
        
        Task {
            try? await chatService.sendMessage(
                gameId: gameId,
                text: text
            )
            isSending = false
        }
    }
}

// ── Message Bubble Router ──
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        switch message.type {
        case .system:
            SystemMessageView(text: message.text)
        case .user:
            UserMessageView(message: message)
        }
    }
}

// ── User Bubble ──
struct UserMessageView: View {
    let message: ChatMessage
    private var isMe: Bool { message.isCurrentUser }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if isMe { Spacer(minLength: 40) }
            
            VStack(alignment: isMe ? .trailing : .leading, spacing: 2) {
                if !isMe {
                    Text(message.senderName)
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.secondaryText)
                        .padding(.leading, 4)
                }
                
                Text(message.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isMe ? AppTheme.accent : AppTheme.cardBackground)
                    .foregroundStyle(isMe ? .white : AppTheme.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text(message.timestamp.dateValue(), style: .time)
                    .font(.caption2)
                    .foregroundStyle(AppTheme.secondaryText)
                    .padding(.horizontal, 4)
            }
            
            if !isMe { Spacer(minLength: 40) }
        }
    }
}

// ── System Message ──
struct SystemMessageView: View {
    let text: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppTheme.cardBackground)
                .clipShape(Capsule())
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

// ── Input Bar ──
struct ChatInputBar: View {
    @Binding var inputText: String
    let isSending: Bool
    let onSend: () -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            TextField("Message...", text: $inputText, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .focused($isFocused)
            
            Button(action: onSend) {
                Image(systemName: isSending
                      ? "clock" : "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(
                        inputText.isEmpty ? Color.gray : AppTheme.accent
                    )
            }
            .disabled(inputText.isEmpty || isSending)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppTheme.background)
    }
}
