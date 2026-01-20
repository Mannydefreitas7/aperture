//
//  AudioInputView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-10.
//

import SwiftUI
import SFSafeSymbols

struct AudioInputView: View {

    var label: String
    var controlGroup: Namespace.ID
    @Binding var viewModel: ViewModel

    var body: some View {
        Group {
            if viewModel.isPresented {
                ToolBarOptions()
            } else {
                ToolbarButton(viewModel.isOn)
            }
        }
        .frame(
            height: viewModel.isPresented ? nil : .minHeight,
            alignment: .center
        )
        .glassEffect(
            .regular,
            in: viewModel.shape
        )
        .toolEffectUnion(
            id: viewModel.toolGroup,
            namespace: controlGroup
        )
    }
}

extension AudioInputView {

    @MainActor
    @Observable class ViewModel {

        var isOn: Bool = false
        var volume: Double = 0
        var isPresented: Bool = false
        var device: DeviceInfo?

        var shape: AnyShape {
            return isPresented || isOn ? AnyShape(.rect(cornerRadius: .large, style: .continuous)) : AnyShape(.capsule)
        }

        var toolGroup: ToolGroup {
            isPresented || isOn ? .audio : .options
        }

    }

    @ViewBuilder
    func ToolBarOptions() -> some View {
        if let device = viewModel.device {
            VolumeHUD(volume: $viewModel.volume, connectedDevice: device) {
                ToolbarButton(false)
            }
            .padding(.large)
        }
    }

    @ViewBuilder
    func ToolbarButton(_ displayLabel: Bool) -> some View {
        HStack(spacing: .small / 2) {
            Toggle(isOn: $viewModel.isOn) {
                Image(systemSymbol: viewModel.isOn ? .microphoneFill : .microphoneSlash)
                    .font(.title2)
            }
            .toggleStyle(.secondary)
            if displayLabel {
                Button {
                    withAnimation(.bouncy) {
                        viewModel.isPresented.toggle()
                    }
                } label: {
                    Text(label)
                }
                .labelStyle(.titleAndIcon)
                .buttonStyle(.accessoryBar)
            }
        }
        .padding(.horizontal, .small)
    }
}
