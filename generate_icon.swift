#!/usr/bin/env swift

import AppKit
import SwiftUI

// MARK: - Icon Configuration

struct IconConfig {
    let topColor: Color
    let bottomColor: Color
    let dropletColor: Color
    let filename: String

    static let light = IconConfig(
        topColor: Color(red: 0.0, green: 0.4, blue: 0.7),
        bottomColor: Color(red: 0.0, green: 0.6, blue: 0.85),
        dropletColor: Color.white.opacity(0.95),
        filename: "AppIcon.png"
    )

    static let dark = IconConfig(
        topColor: Color(red: 0.0, green: 0.3, blue: 0.6),
        bottomColor: Color(red: 0.0, green: 0.5, blue: 0.75),
        dropletColor: Color.cyan.opacity(0.9),
        filename: "AppIcon-dark.png"
    )

    static let tinted = IconConfig(
        topColor: Color(red: 0.0, green: 0.45, blue: 0.7),
        bottomColor: Color(red: 0.0, green: 0.45, blue: 0.7),
        dropletColor: Color.white.opacity(0.9),
        filename: "AppIcon-tinted.png"
    )
}

// MARK: - Icon View

struct IconView: View {
    let config: IconConfig

    var body: some View {
        ZStack {
            // Radial gradient background (ocean depth effect)
            RadialGradient(
                gradient: Gradient(colors: [config.bottomColor, config.topColor]),
                center: .center,
                startRadius: 200,
                endRadius: 600
            )

            // Water droplet icon
            Image(systemName: "drop.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 614, height: 614) // ~60% of 1024
                .foregroundStyle(config.dropletColor)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                .shadow(color: Color.white.opacity(0.3), radius: 10, x: 0, y: -5)
        }
        .frame(width: 1024, height: 1024)
    }
}

// MARK: - Icon Generator

class IconGenerator {
    @MainActor
    static func generateIcon(config: IconConfig, outputPath: String) {
        let iconView = IconView(config: config)
        let renderer = ImageRenderer(content: iconView)

        // Set scale to 1.0 for exact 1024x1024 output
        renderer.scale = 1.0

        guard let cgImage = renderer.cgImage else {
            print("❌ Failed to render image for \(config.filename)")
            return
        }

        // Convert CGImage to NSBitmapImageRep and save as PNG
        let bitmap = NSBitmapImageRep(
            cgImage: cgImage
        )

        guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
            print("❌ Failed to create PNG data for \(config.filename)")
            return
        }

        let fileURL = URL(fileURLWithPath: outputPath + "/" + config.filename)

        do {
            try pngData.write(to: fileURL)
            print("✅ Generated: \(config.filename) (\(cgImage.width)x\(cgImage.height))")
        } catch {
            print("❌ Failed to write \(config.filename): \(error.localizedDescription)")
        }
    }
}

// MARK: - Main Execution

@MainActor
func main() {
    print("🎨 Starting app icon generation...\n")

    // Determine output path
    let currentDir = FileManager.default.currentDirectoryPath
    let outputPath = currentDir + "/toma-aguita/Assets.xcassets/AppIcon.appiconset"

    print("📁 Output directory: \(outputPath)\n")

    // Verify output directory exists
    if !FileManager.default.fileExists(atPath: outputPath) {
        print("❌ Error: AppIcon.appiconset directory not found at \(outputPath)")
        exit(1)
    }

    // Generate all three appearance variants
    IconGenerator.generateIcon(config: .light, outputPath: outputPath)
    IconGenerator.generateIcon(config: .dark, outputPath: outputPath)
    IconGenerator.generateIcon(config: .tinted, outputPath: outputPath)

    print("\n✨ Icon generation complete!")
    print("📋 Next steps:")
    print("   1. Open Xcode and refresh the asset catalog")
    print("   2. Build and run the app")
    print("   3. Check the Home screen icon in light and dark mode")
}

// Run on main actor
await main()
