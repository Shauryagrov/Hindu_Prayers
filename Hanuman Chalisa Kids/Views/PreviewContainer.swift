import SwiftUI

#if DEBUG
struct PreviewContainer<Content: View>: View {
    let content: Content
    @StateObject private var viewModel = VersesViewModel.preview
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .environmentObject(viewModel)
    }
}
#endif 