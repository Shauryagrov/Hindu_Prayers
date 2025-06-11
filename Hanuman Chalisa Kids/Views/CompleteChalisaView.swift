import SwiftUI
import AVFoundation
import SafariServices

struct CompleteChalisaView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var viewModel: VersesViewModel
    
    // YouTube video ID for full Hanuman Chalisa
    private let youtubeVideoID = "UzdLbpQ-enM"
    @State private var showingSafariView = false
    
    // Existing state variables
    @State private var showingContent = true
    @State private var currentVerseId = UUID()
    @State private var currentWordId = UUID()
    @State private var scrollProxy: ScrollViewProxy?
    @State private var showingVerseDetails = false
    @State private var selectedVerse: Verse?
    
    // Add a toggle to switch between interactive and simple view
    @State private var showSimpleView = true // Default to simple view
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Complete Hanuman Chalisa")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .padding(.top)
            
            // Playback controls
            VStack(spacing: 16) {
                // Play/Pause button
                Button(action: {
                    print("Play/Pause button tapped")
                    
                    if viewModel.isCompletePlaying {
                        if viewModel.isCompletePaused {
                            viewModel.resumeAudio(for: .completeView)
                        } else {
                            viewModel.pauseAudio(for: .completeView)
                        }
                    } else {
                        print("Starting complete chalisa playback")
                        viewModel.startCompleteChalisaPlayback()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: viewModel.isCompletePlaying ? 
                              (viewModel.isCompletePaused ? "play.circle.fill" : "pause.circle.fill") : 
                              "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text(viewModel.isCompletePlaying ? 
                             (viewModel.isCompletePaused ? "Resume" : "Pause") : 
                             "Play Complete Chalisa")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(15)
                }
                .buttonStyle(PlainButtonStyle())
                
                // YouTube video button - following Apple HIG
                Button(action: {
                    showingSafariView = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.red)
                        
                        Text("Watch on YouTube")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                .accessibilityLabel("Watch Hanuman Chalisa on YouTube")
                .sheet(isPresented: $showingSafariView) {
                    SafariView(url: URL(string: "https://www.youtube.com/watch?v=\(youtubeVideoID)")!)
                        .edgesIgnoringSafeArea(.all)
                }
                
                // Progress indicator
                if viewModel.isCompletePlaying {
                    VStack(spacing: 8) {
                        // Show current verse being played
                        if let currentVerse = viewModel.currentCompleteVerse {
                            let verseTitle = currentVerse.number > 0 ? "Verse \(currentVerse.number)" : 
                                            (currentVerse.number == -1 ? "Opening Prayer 1" :
                                             currentVerse.number == -2 ? "Opening Prayer 2" : "Closing Prayer")
                            
                            Text("Now playing: " + verseTitle)
                                .font(.headline)
                                .foregroundColor(.orange)
                        }
                        
                        // Progress bar
                        ProgressView(value: Double(viewModel.currentPlaybackProgress), total: 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.05))
                    .cornerRadius(10)
                }
            }
            .padding()
            
            // Simple text view with ScrollViewReader
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Opening prayers
                        Text("Opening Prayers")
                            .font(.headline)
                            .foregroundColor(.orange)
                            .padding(.vertical, 8)
                            .id("section-opening")
                        
                        ForEach(viewModel.sections[0].verses) { verse in
                            Text(verse.text)
                                .font(.title3)
                                .lineSpacing(8)
                                .padding(.vertical, 8)
                                .id("verse-\(verse.number)")
                                .background(
                                    (viewModel.isCompletePlaying && 
                                     viewModel.currentCompleteVerse?.id == verse.id) ||
                                    (viewModel.isPlaying && 
                                     viewModel.currentVerse?.id == verse.id && 
                                     viewModel.currentPlaybackSource == .completeView) ?
                                        Color.orange.opacity(0.1) : Color.clear
                                )
                                .cornerRadius(8)
                        }
                        
                        // Main verses
                        Text("Main Verses")
                            .font(.headline)
                            .foregroundColor(.orange)
                            .padding(.vertical, 8)
                            .id("section-main")
                        
                        ForEach(viewModel.verses) { verse in
                            Text(verse.text)
                                .font(.title3)
                                .lineSpacing(8)
                                .padding(.vertical, 4)
                                .id("verse-\(verse.number)")
                                .background(
                                    (viewModel.isCompletePlaying && 
                                     viewModel.currentCompleteVerse?.id == verse.id) ||
                                    (viewModel.isPlaying && 
                                     viewModel.currentVerse?.id == verse.id && 
                                     viewModel.currentPlaybackSource == .completeView) ?
                                        Color.orange.opacity(0.1) : Color.clear
                                )
                                .cornerRadius(8)
                        }
                        
                        // Closing prayer
                        Text("Closing Prayer")
                            .font(.headline)
                            .foregroundColor(.orange)
                            .padding(.vertical, 8)
                            .id("section-closing")
                        
                        ForEach(viewModel.sections[2].verses) { verse in
                            Text(verse.text)
                                .font(.title3)
                                .lineSpacing(8)
                                .padding(.vertical, 8)
                                .id("verse-\(verse.number)")
                                .background(
                                    (viewModel.isCompletePlaying && 
                                     viewModel.currentCompleteVerse?.id == verse.id) ||
                                    (viewModel.isPlaying && 
                                     viewModel.currentVerse?.id == verse.id && 
                                     viewModel.currentPlaybackSource == .completeView) ?
                                        Color.orange.opacity(0.1) : Color.clear
                                )
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.currentCompleteVerse) { oldVerse, newVerse in
                    if let verse = newVerse {
                        print("Scrolling to verse \(verse.number)")
                        // Scroll to the current verse with animation
                        withAnimation {
                            proxy.scrollTo("verse-\(verse.number)", anchor: .top)
                        }
                    }
                }
                .onChange(of: viewModel.currentVerse) { oldVerse, newVerse in
                    if let verse = newVerse, viewModel.currentPlaybackSource == .completeView {
                        print("Scrolling to verse \(verse.number) from currentVerse change")
                        // Scroll to the current verse with animation
                        withAnimation {
                            proxy.scrollTo("verse-\(verse.number)", anchor: .top)
                        }
                    }
                }
                .onAppear {
                    // Store the proxy for later use
                    scrollProxy = proxy
                    
                    // If already playing, scroll to current verse
                    if let currentVerse = viewModel.currentCompleteVerse {
                        proxy.scrollTo("verse-\(currentVerse.number)", anchor: .top)
                    }
                }
            }
        }
        .navigationTitle("Complete Chalisa")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            // Stop audio when leaving the view
            if viewModel.isCompletePlaying || viewModel.isPlayingCompleteVersion {
                print("CompleteChalisaView disappeared - stopping audio")
                viewModel.stopAudio(for: .completeView)
            }
        }
        .onAppear {
            // Track screen view
            print("CompleteChalisaView appeared")
            
            // Reset any intentional stopping state
            viewModel.resetIntentionalStoppingState()
            
            // Set the preventAutoStop flag to true to prevent other views from stopping our audio
            viewModel.preventAutoStop = true
            
            // Track screen view
            AnalyticsService.shared.trackScreen("CompleteChalisaView")
        }
    }
}

#Preview {
    NavigationView {
        CompleteChalisaView()
            .environmentObject(VersesViewModel())
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = UIColor.orange
        safariViewController.preferredBarTintColor = UIColor.systemBackground
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        // No update needed
    }
} 