#!/usr/bin/env swift
// Renders the Brandy app icon at every size the asset catalogs need.
// Usage: swift scripts/generate-app-icon.swift   (run from the repository root)

import AppKit
import CoreGraphics

/// All geometry is authored on Apple's 1024 pt macOS icon grid, y pointing down.
let canvas: CGFloat = 1024
let tileRect = CGRect(x: 100, y: 100, width: 824, height: 824)
let tileSquircleExponent: CGFloat = 5

let sunCenter = CGPoint(x: 640, y: 300)
let sunRadius: CGFloat = 70

/// One band of liquid: a sine wave across the tile, filled with a vertical gradient below it.
struct Stratum {
    let baseline: CGFloat
    let amplitude: CGFloat
    let wavelength: CGFloat
    let phase: CGFloat
    let topColor: UInt32
    let bottomColor: UInt32
    let crestColor: UInt32
}

/// Ordered from the top band down, distilling from deep wine at the bottom to gold at the top.
let strata: [Stratum] = [
    Stratum(baseline: 470, amplitude: 34, wavelength: 760, phase: 0.6, topColor: 0xFFE3A2, bottomColor: 0xF5A947, crestColor: 0xFFF6DA),
    Stratum(baseline: 568, amplitude: 38, wavelength: 700, phase: 2.2, topColor: 0xF6A443, bottomColor: 0xD0621D, crestColor: 0xFFD08A),
    Stratum(baseline: 664, amplitude: 40, wavelength: 820, phase: 3.9, topColor: 0xD8502A, bottomColor: 0x9A2420, crestColor: 0xF38A5A),
    Stratum(baseline: 758, amplitude: 36, wavelength: 740, phase: 5.3, topColor: 0x921A2A, bottomColor: 0x560B18, crestColor: 0xC8455A),
    Stratum(baseline: 848, amplitude: 30, wavelength: 680, phase: 1.4, topColor: 0x5A0C1A, bottomColor: 0x2E040C, crestColor: 0x8E2238)
]

let colorSpace = CGColorSpace(name: CGColorSpace.displayP3) ?? CGColorSpaceCreateDeviceRGB()

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(
        colorSpace: colorSpace,
        components: [
            CGFloat((hex >> 16) & 0xFF) / 255,
            CGFloat((hex >> 8) & 0xFF) / 255,
            CGFloat(hex & 0xFF) / 255,
            alpha
        ]
    ) ?? CGColor(gray: 0, alpha: alpha)
}

func gradient(_ stops: [(CGColor, CGFloat)]) -> CGGradient? {
    CGGradient(colorsSpace: colorSpace, colors: stops.map(\.0) as CFArray, locations: stops.map(\.1))
}

func fill(_ ctx: CGContext, _ path: CGPath, with gradient: CGGradient?, from start: CGPoint, to end: CGPoint) {
    guard let gradient else { return }
    ctx.saveGState()
    ctx.addPath(path)
    ctx.clip()
    ctx.drawLinearGradient(gradient, start: start, end: end, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    ctx.restoreGState()
}

func fillRadial(_ ctx: CGContext, _ path: CGPath, with gradient: CGGradient?, center: CGPoint, radius: CGFloat) {
    guard let gradient else { return }
    ctx.saveGState()
    ctx.addPath(path)
    ctx.clip()
    ctx.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: radius, options: [])
    ctx.restoreGState()
}

/// Superellipse tile, the continuous-corner shape macOS icons use.
func squirclePath(in rect: CGRect, exponent: CGFloat) -> CGPath {
    let path = CGMutablePath()
    let steps = 720
    for step in 0...steps {
        let angle = CGFloat(step) / CGFloat(steps) * 2 * .pi
        let cosine = cos(angle)
        let sine = sin(angle)
        let x = pow(abs(cosine), 2 / exponent) * (cosine < 0 ? -1 : 1)
        let y = pow(abs(sine), 2 / exponent) * (sine < 0 ? -1 : 1)
        let point = CGPoint(x: rect.midX + x * rect.width / 2, y: rect.midY + y * rect.height / 2)
        step == 0 ? path.move(to: point) : path.addLine(to: point)
    }
    path.closeSubpath()
    return path
}

extension Stratum {
    func surfaceY(atX x: CGFloat) -> CGFloat {
        let angle = 2 * .pi * x / wavelength + phase
        return baseline + amplitude * sin(angle) + amplitude * 0.3 * sin(angle * 2.1 + 1)
    }

    func crest() -> CGPath {
        let path = CGMutablePath()
        let range = stride(from: tileRect.minX - 20, through: tileRect.maxX + 20, by: 4)
        for x in range {
            let point = CGPoint(x: x, y: surfaceY(atX: x))
            path.isEmpty ? path.move(to: point) : path.addLine(to: point)
        }
        return path
    }

    func body() -> CGPath {
        let path = CGMutablePath()
        path.addPath(crest())
        path.addLine(to: CGPoint(x: tileRect.maxX + 20, y: canvas))
        path.addLine(to: CGPoint(x: tileRect.minX - 20, y: canvas))
        path.closeSubpath()
        return path
    }
}

func drawTile(_ ctx: CGContext, _ tile: CGPath) {
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: 10), blur: 22, color: color(0x000000, 0.3))
    ctx.addPath(tile)
    ctx.setFillColor(color(0x1C080C))
    ctx.fillPath()
    ctx.restoreGState()

    fill(
        ctx, tile,
        with: gradient([(color(0x17070B), 0), (color(0x2E0F14), 0.5), (color(0x5A2218), 1)]),
        from: CGPoint(x: 512, y: tileRect.minY),
        to: CGPoint(x: 512, y: strata[0].baseline)
    )
}

func drawSun(_ ctx: CGContext, _ tile: CGPath) {
    fillRadial(
        ctx, tile,
        with: gradient([(color(0xFFC36A, 0.55), 0), (color(0xF58A3A, 0.18), 0.45), (color(0xF58A3A, 0), 1)]),
        center: sunCenter,
        radius: 330
    )
    let sun = CGPath(
        ellipseIn: CGRect(x: sunCenter.x - sunRadius, y: sunCenter.y - sunRadius, width: sunRadius * 2, height: sunRadius * 2),
        transform: nil
    )
    fill(
        ctx, sun,
        with: gradient([(color(0xFFF7E2), 0), (color(0xFFD892), 0.6), (color(0xFFB862), 1)]),
        from: CGPoint(x: sunCenter.x, y: sunCenter.y - sunRadius),
        to: CGPoint(x: sunCenter.x, y: sunCenter.y + sunRadius)
    )
}

func drawStratum(_ ctx: CGContext, _ stratum: Stratum) {
    let body = stratum.body()

    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -8), blur: 26, color: color(0x0A0204, 0.55))
    ctx.addPath(body)
    ctx.setFillColor(color(stratum.bottomColor))
    ctx.fillPath()
    ctx.restoreGState()

    fill(
        ctx, body,
        with: gradient([(color(stratum.topColor), 0), (color(stratum.bottomColor), 1)]),
        from: CGPoint(x: 512, y: stratum.baseline - stratum.amplitude),
        to: CGPoint(x: 512, y: stratum.baseline + 150)
    )

    ctx.saveGState()
    ctx.addPath(body)
    ctx.clip()
    ctx.addPath(stratum.crest())
    ctx.setLineWidth(7)
    ctx.setStrokeColor(color(stratum.crestColor, 0.75))
    ctx.strokePath()
    ctx.restoreGState()
}

func drawTileEdge(_ ctx: CGContext) {
    let edge = squirclePath(in: tileRect.insetBy(dx: 1.5, dy: 1.5), exponent: tileSquircleExponent)
        .copy(strokingWithWidth: 3, lineCap: .round, lineJoin: .round, miterLimit: 10)
    fill(
        ctx, edge,
        with: gradient([(color(0xFFE2C0, 0.22), 0), (color(0xFFE2C0, 0.03), 0.5), (color(0xFFE2C0, 0.08), 1)]),
        from: CGPoint(x: 512, y: tileRect.minY),
        to: CGPoint(x: 512, y: tileRect.maxY)
    )
}

func renderIcon(pixels: Int) -> Data? {
    guard let ctx = CGContext(
        data: nil, width: pixels, height: pixels, bitsPerComponent: 8, bytesPerRow: 0,
        space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    let scale = CGFloat(pixels) / canvas
    ctx.translateBy(x: 0, y: CGFloat(pixels))
    ctx.scaleBy(x: scale, y: -scale)

    let tile = squirclePath(in: tileRect, exponent: tileSquircleExponent)
    drawTile(ctx, tile)

    ctx.saveGState()
    ctx.addPath(tile)
    ctx.clip()
    drawSun(ctx, tile)
    strata.forEach { drawStratum(ctx, $0) }
    ctx.restoreGState()

    drawTileEdge(ctx)

    guard let image = ctx.makeImage() else { return nil }
    return NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:])
}

let outputs: [(path: String, pixels: Int)] = [
    ("Whisky/Assets.xcassets/AppIcon.appiconset/icon_16x16.png", 16),
    ("Whisky/Assets.xcassets/AppIcon.appiconset/icon_16x16@2x.png", 32),
    ("Whisky/Assets.xcassets/AppIcon.appiconset/icon_32x32.png", 32),
    ("Whisky/Assets.xcassets/AppIcon.appiconset/icon_32x32@2x.png", 64),
    ("Whisky/Assets.xcassets/AppIcon.appiconset/icon_128x128.png", 128),
    ("Whisky/Assets.xcassets/AppIcon.appiconset/icon_128x128@2x.png", 256),
    ("Whisky/Assets.xcassets/AppIcon.appiconset/icon_256x256.png", 256),
    ("Whisky/Assets.xcassets/AppIcon.appiconset/icon_256x256@2x.png", 512),
    ("Whisky/Assets.xcassets/AppIcon.appiconset/icon_512x512.png", 512),
    ("Whisky/Assets.xcassets/AppIcon.appiconset/icon_512x512@2x.png", 1024),
    ("WhiskyThumbnail/Icons.xcassets/Icon.imageset/512R512x1.png", 512),
    ("images/brandy-icon.png", 1024)
]

for output in outputs {
    guard let png = renderIcon(pixels: output.pixels) else {
        FileHandle.standardError.write(Data("Failed to render \(output.path)\n".utf8))
        exit(1)
    }
    do {
        try png.write(to: URL(fileURLWithPath: output.path))
    } catch {
        FileHandle.standardError.write(Data("Failed to write \(output.path): \(error)\n".utf8))
        exit(1)
    }
}
