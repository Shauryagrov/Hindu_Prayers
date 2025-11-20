//
//  HanumanIconRendererTests.swift
//  DivinePrayersTests
//
//  Created by GPT-5 Codex on 11/11/25.
//

import CoreGraphics
import XCTest
@testable import DivinePrayers

final class HanumanIconRendererTests: XCTestCase {
    @MainActor
    func testMakeImageProducesCorrectDimensions() throws {
        let side: CGFloat = 256
        let image = try HanumanIconRenderer.makeImage(sideLength: side, scale: 2)

        XCTAssertEqual(image.size.width, side, accuracy: 0.5)
        XCTAssertEqual(image.size.height, side, accuracy: 0.5)
        XCTAssertEqual(image.scale, 2, accuracy: 0.01)
    }
}

