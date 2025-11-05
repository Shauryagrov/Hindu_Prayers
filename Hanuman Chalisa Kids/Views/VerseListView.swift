import SwiftUI

struct VerseListView: View {
    @EnvironmentObject var viewModel: VersesViewModel
    @State private var showingVerseJumper = false
    @State private var navigationPath = NavigationPath()
    @State private var currentScrollProxy: ScrollViewProxy?
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            MainContent(
                viewModel: viewModel,
                showingVerseJumper: $showingVerseJumper,
                navigationPath: $navigationPath,
                currentScrollProxy: $currentScrollProxy
            )
        }
        .onAppear {
            // Don't reset navigation path on every appear
            // Only reset if coming from a specific source
            // This prevents multiple navigation updates
        }
        .onChange(of: navigationPath) { oldPath, newPath in
            // Avoid multiple navigation updates in the same frame
            if !oldPath.isEmpty && newPath.isEmpty {
                // We've just reset the path, no need for additional actions
                return
            }
        }
    }
}

// Version for use as navigation destination - receives parent's navigationPath
struct VerseListViewContent: View {
    @EnvironmentObject var viewModel: VersesViewModel
    @Binding var navigationPath: NavigationPath
    @State private var showingVerseJumper = false
    @State private var currentScrollProxy: ScrollViewProxy?
    
    var body: some View {
        MainContent(
            viewModel: viewModel,
            showingVerseJumper: $showingVerseJumper,
            navigationPath: $navigationPath,
            currentScrollProxy: $currentScrollProxy
        )
        .navigationDestination(for: Verse.self) { verse in
            VerseDetailView(navigationPath: $navigationPath, verse: verse)
                .onAppear {
                    if viewModel.isPlaying {
                        viewModel.stopAudio()
                    }
                }
        }
        .navigationDestination(for: String.self) { value in
            if value == "complete" {
                CompleteChalisaView()
                    .environmentObject(viewModel)
            }
        }
        .sheet(isPresented: $showingVerseJumper) {
            VerseJumperView { verseNumber in
                if let verse = viewModel.verses.first(where: { $0.number == verseNumber }) {
                    navigationPath.append(verse)
                }
                showingVerseJumper = false
            }
            .presentationDetents([.height(400)])
        }
    }
}

private struct MainContent: View {
    @ObservedObject var viewModel: VersesViewModel
    @Binding var showingVerseJumper: Bool
    @Binding var navigationPath: NavigationPath
    @Binding var currentScrollProxy: ScrollViewProxy?
    
    var body: some View {
        VStack(spacing: 0) {
            TopNavigationButtons(
                showingVerseJumper: $showingVerseJumper
            )
            
            Text("Tap on any verse to learn more")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
                .padding(.bottom, 4)
            
            VersesList(
                viewModel: viewModel,
                navigationPath: $navigationPath,
                currentScrollProxy: $currentScrollProxy,
                showingVerseJumper: $showingVerseJumper
            )
        }
        .navigationTitle("Hanuman Chalisa")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    viewModel.stopAudio()
                    navigationPath.removeLast()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

private struct TopNavigationButtons: View {
    @Binding var showingVerseJumper: Bool
    
    var body: some View {
        HStack {
            NavigationLink(value: "complete") {
                Label("Complete Chalisa", systemImage: "book.circle.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// Helper functions to get Doha content
private func getDohaText(number: Int) -> String {
    switch number {
    case 1: return "श्रीगुरु चरन सरोज रज निज मनु मुकुरु सुधारि ।\nबरनउँ रघुबर बिमल जसु जो दायकु फल चारि ॥"
    case 2: return "बुद्धिहीन तनु जानिके, सुमिरौं पवन कुमार\nबल बुधि विद्या देहु मोहि, हरहु कलेश विकार"
    case 3: return "पवन तनय संकट हरन, मंगल मूरति रूप।\nराम लखन सीता सहित, हृदय बसहु सुर भूप॥"
    default: return ""
    }
}

private func getDohaTranslation(number: Int) -> String {
    switch number {
    case 1: return "After cleaning the mirror of my mind with the pollen dust of holy Guru's Lotus feet, I describe the pure glory of Shri Ram which bestows the four fruits of life."
    case 2: return "Knowing myself to be ignorant, I urge you, O Hanuman, the son of Wind, to give me strength, intelligence and true knowledge. Remove my blemishes and shortcomings."
    case 3: return "O Son of Wind, remover of troubles, embodiment of auspiciousness, reside in my heart together with Ram, Lakshman and Sita, O king of gods."
    default: return ""
    }
}

private func getDohaExplanation(number: Int) -> String {
    switch number {
    case 1: return "This verse teaches us about respect for our teachers and how they help us learn better. Just like we clean a mirror to see clearly, when we learn from our teachers, our mind becomes clear to understand good things."
    case 2: return "When we know we need to learn something, we should ask for help. Hanuman ji can help us become stronger and smarter, and help us become better people."
    case 3: return "This final prayer asks Hanuman ji, along with Ram, Lakshman and Sita, to stay in our hearts and bless us."
    default: return ""
    }
}

// Add a new view for verse selection
struct VerseJumperView: View {
    let onSelect: (Int) -> Void
    @Environment(\.dismiss) var dismiss
    
    let columns = [
        GridItem(.adaptive(minimum: 60))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(1...40, id: \.self) { number in
                        Button(action: { onSelect(number) }) {
                            Text("\(number)")
                                .font(.headline)
                                .frame(width: 50, height: 50)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Jump to Verse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// 1. Create a separate component for verse rows
private struct VerseRowView: View {
    let verse: Verse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Verse \(verse.number)")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(verse.text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

// Update the DohaRowView to match the VerseRowView style
private struct DohaRowView: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

// 2. Create a separate component for the main verses section
private struct MainVersesSection: View {
    let verses: [Verse]
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        Section(header: Text("चौपाई")
            .font(.title2.bold())
            .foregroundColor(.orange)
            .padding(.vertical, 8)
        ) {
            ForEach(verses) { verse in
                NavigationLink(value: verse) {
                    VerseRowView(verse: verse)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
    }
}

// Update the OpeningDohasSection to completely remove default chevrons
private struct OpeningDohasSection: View {
    let verses: [Verse]
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        Section(header: Text("दोहा")
            .font(.title2.bold())
            .foregroundColor(.orange)
            .padding(.vertical, 8)
        ) {
            ForEach(verses) { verse in
                NavigationLink(value: verse) {
                    DohaRowView(
                        title: verse.number == -1 ? "Opening Prayer 1" : "Opening Prayer 2",
                        text: verse.text
                    )
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
    }
}

// Update the ClosingDohaSection to completely remove default chevrons
private struct ClosingDohaSection: View {
    let verse: Verse
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        Section(header: Text("दोहा")
            .font(.title2.bold())
            .foregroundColor(.orange)
            .padding(.vertical, 8)
        ) {
            NavigationLink(value: verse) {
                DohaRowView(
                    title: "Closing Prayer",
                    text: verse.text
                )
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
    }
}

// Update the VersesList to use a different list style
private struct VersesList: View {
    @ObservedObject var viewModel: VersesViewModel
    @Binding var navigationPath: NavigationPath
    @Binding var currentScrollProxy: ScrollViewProxy?
    @Binding var showingVerseJumper: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                // Opening Dohas section - pass navigationPath
                OpeningDohasSection(verses: viewModel.sections[0].verses, navigationPath: $navigationPath)
                
                // Main Verses section - pass navigationPath
                MainVersesSection(verses: viewModel.verses, navigationPath: $navigationPath)
                
                // Closing Doha section - pass navigationPath
                ClosingDohaSection(verse: viewModel.sections[2].verses[0], navigationPath: $navigationPath)
                
                // Bottom spacing
                Color.clear
                    .frame(height: 60)
                    .listRowBackground(Color.clear)
            }
            .listStyle(PlainListStyle())
            .environment(\.defaultMinListRowHeight, 0)
            .onAppear {
                currentScrollProxy = proxy
            }
        }
        .sheet(isPresented: $showingVerseJumper) {
            VerseJumperView { verseNumber in
                // For VerseJumperView, we'll use a different approach since we're nested
                // The navigation will be handled by the parent NavigationStack
                showingVerseJumper = false
                // TODO: Implement programmatic navigation from sheet
            }
            .presentationDetents([.height(400)])
        }
    }
}

#Preview {
    NavigationView {
        VerseListView()
            .environmentObject(VersesViewModel())
    }
}

// Add extension to VersesViewModel instead
extension VersesViewModel {
    var completeHanumanChalisa: String {
        verses.map { $0.text }.joined(separator: "\n\n")
    }
    
    var englishTranslation: String {
        verses.map { $0.meaning }.joined(separator: "\n\n")
    }
} 