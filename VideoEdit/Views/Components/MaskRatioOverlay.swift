//
//  AspectMaskOverlay.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-24.
//
import SwiftUI

/// Visual overlay showing the selected aspect ratio as a centered mask.
/// The window remains freely resizable; this is purely a guide.
struct MaskRatioOverlay: View {

    var aspectPreset: AspectPreset = .youtube
    var showGuides: Bool = false
    var showMask: Bool = false
    var showPlatformSafe: Bool = true

        var body: some View {
            GeometryReader { geo in
                let container = geo.size
                let negativeSpace = .topPadding + .bottomPadding
                let paddedContainer = CGSize(
                    width: container.width,
                    height: max(0, container.height - negativeSpace)
                )

                let target = fittedSize(container: paddedContainer, ratio: aspectPreset.ratio)
                // Centered target rect inside the padded container.
                let originX = (container.width - target.width) / 2
                let originY = .topPadding + (paddedContainer.height - target.height) / 2

                ZStack {
                    if showMask {
                        // Dim everything outside the target rect.
                        AnimatableEvenOddMask(
                            outerSize: container,
                            innerRect: CGRect(x: originX, y: originY, width: target.width, height: target.height),
                            cornerRadius: .cornerRadius
                        )
                        .fill(
                            .thickMaterial,
                            style: FillStyle(eoFill: true)
                        )


                        if showPlatformSafe, let avoid = aspectPreset.platformAvoidance {
                            // Top avoid area
                            if avoid.top > 0 {
                                UnevenRoundedRectangle(
                                    cornerRadii: .init(topLeading: .cornerRadius, topTrailing: .cornerRadius)
                                )
                                .fill(Color.maskColor)
                                .frame(width: target.width, height: target.height * avoid.top)
                                .position(x: originX + target.width / 2, y: originY + (target.height * avoid.top) / 2)
                            }

                            // Bottom avoid area
                            if avoid.bottom > 0 {
                                UnevenRoundedRectangle(
                                    cornerRadii: .init(bottomLeading: .cornerRadius, bottomTrailing: .cornerRadius)
                                )
                                .fill(Color.maskColor)
                                .frame(width: target.width, height: target.height * avoid.bottom)
                                .position(x: originX + target.width / 2, y: originY + target.height - (target.height * avoid.bottom) / 2)
                            }

                            // Left avoid area
                            if avoid.left > 0 {
                                UnevenRoundedRectangle(
                                    cornerRadii: .init(topLeading: .cornerRadius, bottomLeading: .cornerRadius)
                                )
                                .fill(Color.maskColor)
                                .frame(width: target.width * avoid.left, height: target.height)
                                .position(x: originX + (target.width * avoid.left) / 2, y: originY + target.height / 2)
                            }

                            // Right avoid area
                            if avoid.right > 0 {
                                UnevenRoundedRectangle(
                                    cornerRadii: .init(bottomTrailing: .cornerRadius, topTrailing: .cornerRadius)
                                )
                                .fill(Color.maskColor)
                                .frame(width: target.width * avoid.right, height: target.height)
                                .position(x: originX + target.width - (target.width * avoid.right) / 2, y: originY + target.height / 2)
                            }
                        }

                        // Border for the target rect.
                        RoundedRectangle(cornerRadius: .cornerRadius, style: .continuous)
                            .stroke(.ultraThickMaterial.quinary, lineWidth: .borderWidth * 2)
                            .frame(width: target.width, height: target.height)
                            .position(x: originX + target.width / 2, y: originY + target.height / 2)
                    }

                    if showGuides {
                        // Inner safe guides.
                        let insetX = target.width * 0.05
                        let insetY = target.height * 0.05

                        RoundedRectangle(cornerRadius: .cornerRadius / 1.5, style: .continuous)
                            .stroke(.ultraThickMaterial, style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
                            .frame(width: target.width - (insetX * 2), height: target.height - (insetY * 2))
                            .position(x: originX + target.width / 2, y: originY + target.height / 2)

                        // Crosshair guides.
                        Path { p in
                            p.move(to: CGPoint(x: originX + target.width / 2, y: originY))
                            p.addLine(to: CGPoint(x: originX + target.width / 2, y: originY + target.height))
                            p.move(to: CGPoint(x: originX, y: originY + target.height / 2))
                            p.addLine(to: CGPoint(x: originX + target.width, y: originY + target.height / 2))
                        }
                        .stroke(.thickMaterial, style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
                    }
                }
            }
            // Animate when the selected preset changes.
            .animation(.interactiveSpring, value: aspectPreset)
        }

        /// An even-odd shape (outer rect with an inner rounded-rect cutout) whose inner rect animates.
        struct AnimatableEvenOddMask: Shape {
            var outerSize: CGSize
            var innerRect: CGRect
            var cornerRadius: CGFloat

            // Animate using center + size (CGRect itself isn't animatable).
            var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>> {
                get {
                    .init(
                        .init(innerRect.midX, innerRect.midY),
                        .init(innerRect.width, innerRect.height)
                    )
                }
                set {
                    let midX = newValue.first.first
                    let midY = newValue.first.second
                    let width = max(0, newValue.second.first)
                    let height = max(0, newValue.second.second)
                    innerRect = CGRect(x: midX - width / 2, y: midY - height / 2, width: width, height: height)
                }
            }

            func path(in rect: CGRect) -> Path {
                var path = Path()
                path.addRect(CGRect(origin: .zero, size: outerSize))
                path.addRoundedRect(in: innerRect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius), style: .continuous)
                return path
            }
        }

        private func fittedSize(container: CGSize, ratio: CGSize) -> CGSize {
            guard ratio.width > 0, ratio.height > 0 else { return container }
            let containerAspect = container.width / max(container.height, 1)
            let targetAspect = ratio.width / ratio.height

            // Fit the target rect fully inside the container.
            if containerAspect >= targetAspect {
                // Container is wider than target → limit by height.
                let height = container.height
                let width = height * targetAspect
                return CGSize(width: width, height: height)
            } else {
                // Container is taller than target → limit by width.
                let width = container.width
                let height = width / targetAspect
                return CGSize(width: width, height: height)
            }
        }
    }
