import AppKit
import SwiftUI

@main
struct IconExporter {
    static func main() async throws {
        let side: CGFloat = 1024
        let view = HanumanIconView()
            .frame(width: side, height: side)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 3
        renderer.isOpaque = true
        renderer.proposedSize = ProposedViewSize(width: side, height: side)

        guard let image = renderer.nsImage else {
            throw ExportError.renderFailed
        }

        let outputURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("HanumanIconPreview.png")

        try image.writePNG(to: outputURL)
        print("Icon exported to \(outputURL.path)")
    }
}

private enum ExportError: Error {
    case renderFailed
    case encodingFailed
}

private extension NSImage {
    func writePNG(to url: URL) throws {
        guard let data = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: data),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw ExportError.encodingFailed
        }

        try pngData.write(to: url, options: .atomic)
    }
}

