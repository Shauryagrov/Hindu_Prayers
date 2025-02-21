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
            
            VersesList(
                viewModel: viewModel,
                navigationPath: $navigationPath,
                currentScrollProxy: $currentScrollProxy,
                showingVerseJumper: $showingVerseJumper
            )
        }
        .navigationTitle("Hanuman Chalisa")
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
            
            Button(action: { showingVerseJumper = true }) {
                Label("Jump to Verse", systemImage: "list.number.circle.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
            }
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

struct VerseRowView: View {
    let verse: Verse
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Verse \(verse.number)")
                    .font(.title3)
                    .foregroundColor(.orange)
                Text(verse.text)
                    .font(.title3)
                    .lineLimit(2)
                    .lineSpacing(6)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// Add DohaRowView similar to VerseRowView
struct DohaRowView: View {
    let title: String
    let text: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(title.replacingOccurrences(of: "दोहा १", with: "Opening Prayer 1")
                         .replacingOccurrences(of: "दोहा २", with: "Opening Prayer 2")
                         .replacingOccurrences(of: "दोहा ३", with: "Closing Prayer"))
                    .font(.title3)
                    .foregroundColor(.orange)
                Text(text)
                    .font(.title3)
                    .lineLimit(2)
                    .lineSpacing(6)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

private struct VersesList: View {
    @ObservedObject var viewModel: VersesViewModel
    @Binding var navigationPath: NavigationPath
    @Binding var currentScrollProxy: ScrollViewProxy?
    @Binding var showingVerseJumper: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                // Opening Dohas section
                Section(header: Text("दोहा")
                    .font(.title2.bold())
                    .foregroundColor(.orange)
                    .padding(.vertical, 8)
                ) {
                    ForEach(viewModel.sections[0].verses) { verse in
                        NavigationLink(value: verse) {
                            DohaRowView(
                                title: verse.number == -1 ? "Opening Prayer 1" : "Opening Prayer 2",
                                text: verse.text
                            )
                        }
                    }
                }
                
                // Main Verses section
                Section(header: Text("चौपाई")
                    .font(.title2.bold())
                    .foregroundColor(.orange)
                    .padding(.vertical, 8)
                ) {
                    ForEach(viewModel.verses) { verse in
                        NavigationLink(value: verse) {
                            VerseRowView(verse: verse)
                        }
                        .id(verse.number)
                    }
                }
                
                // Closing Doha section
                Section(header: Text("दोहा")
                    .font(.title2.bold())
                    .foregroundColor(.orange)
                    .padding(.vertical, 8)
                ) {
                    NavigationLink(value: viewModel.sections[2].verses[0]) {
                        DohaRowView(
                            title: "Closing Prayer",
                            text: viewModel.sections[2].verses[0].text
                        )
                    }
                }
                
                // Bottom spacing
                Color.clear
                    .frame(height: 60)
                    .listRowBackground(Color.clear)
            }
            .listStyle(PlainListStyle())
            .onAppear {
                currentScrollProxy = proxy
            }
        }
        .navigationDestination(for: Verse.self) { verse in
            VerseDetailView(navigationPath: $navigationPath, verse: verse)
                .onAppear {
                    if viewModel.isPlaying {
                        viewModel.stopAudio {
                            print("Audio stopped, showing verse detail")
                        }
                    }
                }
        }
        .navigationDestination(for: String.self) { value in
            if value == "complete" {
                CompleteChalisaView()
                    .onAppear {
                        if viewModel.isPlaying {
                            viewModel.stopAudio {
                                print("Audio stopped, showing complete chalisa")
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $showingVerseJumper) {
            VerseJumperView { verseNumber in
                withAnimation {
                    currentScrollProxy?.scrollTo(verseNumber, anchor: .top)
                }
                showingVerseJumper = false
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