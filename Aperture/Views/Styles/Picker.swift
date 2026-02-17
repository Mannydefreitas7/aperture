//
//  Picker.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-13.
//
import SwiftUI
import Engine


/// An Engine-powered segmented picker that renders each option as a segment.
///
/// This is useful when you want a segmented control where each segment can be a `Label`
/// (title + icon), rather than relying on `PickerStyle.segmented` (which can vary by platform).
///
/// This follows Engine's README "Variadic Views" example (Example 3): it turns the `content` builder
/// into a collection of subviews and binds selection using each subview's ID.
struct TabPicker<Selection: Hashable, Content: View>: View {
    @Binding var selection: Selection
    @ViewBuilder var content: Content
    @Namespace var animationNamespace

    init(selection: Binding<Selection>, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.content = content()
    }

    @ViewBuilder
    func subView(_ subview: VariadicView.Subview) -> some View {
        let isSelected: Bool = subview.id(as: Selection.self) == selection
            Button {
                if let id = subview.id(as: Selection.self) {
                    withAnimation(.bouncy) {
                        selection = id
                   }

                }
            } label: {
                subview
                // Ensure labels show both title + icon when the option is a `Label`.
                    .labelStyle(.titleAndIcon)
                    .padding(.horizontal, .small)
                    .padding(.vertical, .small)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color(isSelected ? .labelColor : .secondaryLabelColor))



            }

            .accessibilityAddTraits(isSelected ? .isSelected : [])
            .buttonStyle(.borderless)

            .matchedGeometryEffect(id: subview.id(as: Selection.self)!, in: animationNamespace, isSource: true)
            .padding(4)

        }




    var body: some View {
        VariadicViewAdapter {
            content
        } content: { source in
            HStack(spacing: 0) {
                ForEachSubview(source) { index, subview in
                    subView(subview)
                }
            }
            .padding(5)
            .background(
                ZStack {
                    Capsule()
                        .fill(.windowBackground.shadow(.inner(color: Color(.shadowColor), radius: 15)))

                    Capsule()
                        .fill(.fill)
                        .glassEffect(.regular)

                        .matchedGeometryEffect(id: selection, in: animationNamespace, isSource: false)

                    Capsule()
                        .fill(.clear)
                        .stroke(Color(.controlBackgroundColor), lineWidth: 1.5)
                }
            )
        }
    }
}


#Preview {
    @Previewable @State var selection: Int = 0
    TabPicker(selection: $selection) {
        Label("Audio", systemImage: "microphone")
            .id(0)
        Label("Video", systemImage: "video")
            .id(1)
    }
}

extension TabPicker {
    /// Convenience initializer that mirrors Picker's call site.
    init(_ titleKey: LocalizedStringKey, selection: Binding<Selection>, @ViewBuilder content: () -> Content) {
        self.init(selection: selection, content: content)
    }
}

/// Backwards-compatible alias for existing call sites that may have used the prior type name.
/// Prefer using `LabelAndImageSegmentedPicker` directly.
typealias SegmentedStyle = TabPicker

