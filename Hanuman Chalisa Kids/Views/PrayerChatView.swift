import SwiftUI

/// Chat view for asking questions about prayers
struct PrayerChatView: View {
    let prayer: Prayer
    var onClose: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) private var colorScheme
    private let ragService = RAGService.shared
    private let localQAService = LocalQAService.shared
    private let llmService = LLMService.shared
    
    @State private var messages: [ChatMessage] = []
    @State private var currentQuestion: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    private var backgroundGradient: LinearGradient {
        colorScheme == .dark ? LinearGradient(
            colors: [AppColors.nightBackground, AppColors.nightSurface],
            startPoint: .top,
            endPoint: .bottom
        ) : AppGradients.background
    }
    
    private var inputBackground: Color {
        colorScheme == .dark ? AppColors.nightCard : AppColors.warmWhite
    }
    
    private var errorBackground: Color {
        colorScheme == .dark ? AppColors.nightSurface : AppColors.cream
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    if let onClose {
                        onClose()
                    } else {
                        presentationMode.wrappedValue.dismiss()
                        dismiss()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                    Text("Done")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundStyle(AppGradients.saffronGold)
                
                Spacer()
            }
            .padding(.top, 20)
            .padding(.horizontal)
            .padding(.bottom, 12)
            
            Text("Ask about \(prayer.title)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)

            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Welcome message
                        if messages.isEmpty {
                            WelcomeMessageView()
                                .padding()
                        }
                        
                        // Chat messages
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                        
                        // Loading indicator
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Thinking...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .id("loading")
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: isLoading) { _, newValue in
                    if newValue {
                        withAnimation {
                            proxy.scrollTo("loading", anchor: .bottom)
                        }
                    }
                }
            }
            
            // Error message
            if let error = errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(AppColors.saffron)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(errorBackground)
            }
            
            // Input area
            HStack(spacing: 12) {
                TextField("Ask a question about \(prayer.title)...", text: $currentQuestion, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                    .disabled(isLoading)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(
                            currentQuestion.isEmpty || isLoading ?
                            AnyShapeStyle(Color.gray) :
                            AnyShapeStyle(AppGradients.saffronGold)
                        )
                }
                .disabled(currentQuestion.isEmpty || isLoading)
            }
            .padding()
            .background(inputBackground)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private func checkAPIKey() {
        // No longer needed - using local QA service
        // Keep for potential future API fallback option
    }
    
    private func sendMessage() {
        guard !currentQuestion.isEmpty, !isLoading else { return }
        
        let question = currentQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
        currentQuestion = ""
        errorMessage = nil
        
        // Add user message
        let userMessage = ChatMessage(role: .user, content: question)
        messages.append(userMessage)
        
        // Show loading
        isLoading = true
        
        // Retrieve context using RAG
        let context = ragService.retrieveRelevantContext(query: question, prayer: prayer)
        
        // Use local QA service (no API key required)
        // This runs entirely on-device
        Task {
            // Small delay to show loading state
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
            let answer = localQAService.generateAnswer(
                question: question,
                prayer: prayer,
                context: context
            )
            
            await MainActor.run {
                let assistantMessage = ChatMessage(role: .assistant, content: answer)
                messages.append(assistantMessage)
                isLoading = false
            }
        }
    }
}

// MARK: - Chat Bubble
private struct ChatBubble: View {
    let message: ChatMessage
    @Environment(\.colorScheme) private var colorScheme
    
    var userGradient: LinearGradient {
        colorScheme == .dark
        ? LinearGradient(colors: [AppColors.nightHighlight, AppColors.gold], startPoint: .topLeading, endPoint: .bottomTrailing)
        : AppGradients.saffronGold
    }
    
    var assistantBackground: Color {
        colorScheme == .dark ? AppColors.nightCard : AppColors.warmWhite
    }
    
    var assistantStroke: Color {
        colorScheme == .dark ? AppColors.nightHighlight.opacity(0.4) : AppColors.gold.opacity(0.3)
    }
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 40)
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(message.role == .user ?
                                  AnyShapeStyle(userGradient) :
                                  AnyShapeStyle(assistantBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(
                                message.role == .user ?
                                Color.clear :
                                assistantStroke,
                                lineWidth: 1
                            )
                    )
            }
            
            if message.role == .assistant {
                Spacer(minLength: 40)
            }
        }
    }
}

// MARK: - Welcome Message
private struct WelcomeMessageView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var panelBackground: Color {
        colorScheme == .dark ? AppColors.nightCard : AppColors.cream
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: AppIcons.lotus)
                .font(.system(size: 48))
                .foregroundStyle(AppGradients.saffronGold)
            
            Text("Ask me anything about this prayer!")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("I can help explain verses, meanings, pronunciation, and more.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Try asking:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                ForEach([
                    "What does this prayer mean?",
                    "How do I pronounce this verse?",
                    "When should I recite this prayer?",
                    "What is the significance of this prayer?"
                ], id: \.self) { example in
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .font(.caption)
                            .foregroundColor(AppColors.saffron)
                        Text(example)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(panelBackground)
            .cornerRadius(12)
        }
        .padding()
    }
}

#Preview {
    PrayerChatView(prayer: Prayer(
        title: "Hanuman Chalisa",
        type: .chalisa,
        category: .hanuman,
        description: "A devotional hymn",
        verses: []
    ))
}

