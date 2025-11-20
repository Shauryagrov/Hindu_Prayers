//
//  HanumanIconRenderer.swift
//  DivinePrayers
//
//  Created by GPT-5 Codex on 11/11/25.
//

import SwiftUI
import UIKit

/// Utility responsible for rendering the `HanumanIconView` into PNG assets.
/// Usage:
/// ```swift
/// let url = try await HanumanIconRenderer.exportIcon()
/// ```
enum HanumanIconRenderer {
    /// Renders the icon to the Documents/Exports directory, making it easy to pull via Finder or the Files app.
    /// - Parameters:
    ///   - sideLength: Output side length (square export). Defaults to `1024`.
    ///   - fileName: Custom filename. Defaults to `"DivinePrayersIcon"`.
    ///   - scale: Backing scale for the rasterised image. Defaults to `3` (suitable for high-resolution assets).
    @MainActor
    static func exportIcon(
        sideLength: CGFloat = 1024,
        fileName: String = "DivinePrayersIcon",
        scale: CGFloat = 3
    ) throws -> URL {
        let image = try makeImage(sideLength: sideLength, scale: scale)
        let outputURL = try destinationURL(
            fileName: fileName,
            fileExtension: "png"
        )

        guard let data = image.pngData() else {
            throw IconRenderingError.encodeFailed
        }

        try data.write(to: outputURL, options: .atomic)
        try annotateMetadata(for: outputURL, size: CGSize(width: sideLength, height: sideLength))

        return outputURL
    }

    /// Allows in-memory access to the rendered icon, which can be useful for previews or tests.
    @MainActor
    static func makeImage(sideLength: CGFloat = 1024, scale: CGFloat = 3) throws -> UIImage {
        let renderer = ImageRenderer(
            content: HanumanIconView()
                .frame(width: sideLength, height: sideLength)
        )

        renderer.scale = scale
        renderer.proposedSize = .init(width: sideLength, height: sideLength)
        renderer.isOpaque = true

        guard let uiImage = renderer.uiImage else {
            throw IconRenderingError.renderFailed
        }

        return uiImage
    }
}

// MARK: - Private helpers

private extension HanumanIconRenderer {
    static func destinationURL(fileName: String, fileExtension: String) throws -> URL {
        let fm = FileManager.default
        let docs = try fm.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let exportsFolder = docs.appendingPathComponent("Exports", isDirectory: true)
        if !fm.fileExists(atPath: exportsFolder.path) {
            try fm.createDirectory(at: exportsFolder, withIntermediateDirectories: true)
        }

        let sanitizedName = fileName.replacingOccurrences(of: " ", with: "_")
        return exportsFolder.appendingPathComponent("\(sanitizedName).\(fileExtension)")
    }

    static func annotateMetadata(for url: URL, size: CGSize) throws {
        let attributes: [FileAttributeKey: Any] = [
            .creationDate: Date(),
            .modificationDate: Date()
        ]
        try FileManager.default.setAttributes(attributes, ofItemAtPath: url.path)

        let metadataURL = url.deletingPathExtension().appendingPathExtension("json")
        let metadata: [String: Any] = [
            "width": Int(size.width),
            "height": Int(size.height),
            "exportedAt": ISO8601DateFormatter().string(from: .now)
        ]

        let data = try JSONSerialization.data(withJSONObject: metadata, options: [.prettyPrinted])
        try data.write(to: metadataURL, options: .atomic)
    }
}

// MARK: - Error

enum IconRenderingError: Error, LocalizedError {
    case renderFailed
    case encodeFailed

    var errorDescription: String? {
        switch self {
        case .renderFailed:
            "Failed to render the Hanuman icon view."
        case .encodeFailed:
            "Failed to encode the rendered image."
        }
    }
}

