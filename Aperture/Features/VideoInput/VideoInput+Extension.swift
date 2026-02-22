//
//  VideoInput+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-06.
//
import SwiftUI
import SFSafeSymbols

extension VideoInputView {

    var imageWidth: CGFloat { .thumbnail / 2.5 }

    @ViewBuilder
    func ToolCloseButton() -> some View {
        Button(.closeButton, systemImage: SFSymbol.xmark.rawValue, role: .close) {
            withAnimation(.bouncy) {
                viewModel.showSettings = false
            }
        }
        .labelStyle(.iconOnly)
        .buttonBorderShape(.circle)
        .fontWeight(.bold)
        .colorScheme(viewModel.videoLayer.visibility == .hidden ? .light : .dark)

    }

    @ViewBuilder
    func ToolButton() -> some View {
        HStack(spacing: .small / 2) {
            //
            Toggle(isOn: $viewModel.selectedDevice.isOn) {
                //
                Image(systemSymbol: .video)
                    .symbolVariant(viewModel.selectedDevice.isOn ? .none : .slash)
                    .contentTransition(.symbolEffect(.replace))
                    .font(.title2)
                    .frame(width: .recordWidth)
            }
            .toggleStyle(.secondary)
            .disabled(viewModel.showSettings)
            .animation(.bouncy, value: viewModel.selectedDevice.isOn)

            if viewModel.selectedDevice.isOn {
                Button {
                    withAnimation(.bouncy) {
                        viewModel.showSettings.toggle()
                    }
                } label: {
                    Text(viewModel.selectedDevice.name)
                }
                .buttonStyle(.accessoryBar)

                if viewModel.showSettings {

                    Spacer()

                    Button {
                        //
                    } label: {
                        Image(systemSymbol: .gearshape)
                    }
                    .buttonBorderShape(.circle)
                }
            }
        }
        .frame(maxWidth: viewModel.showSettings ? (.previewVideoWidth - .bottomPadding) : nil)
    }

    @ViewBuilder
    func ToolBarOptions() -> some View {
        ZStack(alignment: .bottom) {

            CapturePlaceholder(
                isConnecting: $viewModel.isConnecting,
                hasConnectionTimeout: $viewModel.hasConnectionTimeout,
                currentDevice: viewModel.selectedDevice
            )
            .onDisplay(layer: $viewModel.placeholderLayer)
            .onDisappear(layer: $viewModel.placeholderLayer)

            if viewModel.hasSession && viewModel.isConnecting {
                DeviceConnectionLoading(viewModel.selectedDevice)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            if viewModel.isRunning && viewModel.showSettings {

                VideoPreview(viewModel: $viewModel)
                        .clipShape(.rect(cornerRadius: .large, style: .continuous))
                        .animation(.bouncy, value: viewModel.isRunning)
                        .onDisplay(layer: $viewModel.videoLayer)
                        .onDisappear(layer: $viewModel.videoLayer)
            }

            HStack {

                Picker(viewModel.selectedDevice.name, selection: $viewModel.deviceId) {
                        ForEach(videoDevices, id: \.id) { device in
                            HStack(spacing: .medium) {
                                Image(systemSymbol: device.symbol)
                                Text(device.name)
                            }
                            .tag(device.id)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .controlSize(.extraLarge)
                    .glassEffect()


                    Spacer()

                Toggle("", systemImage: SFSymbol.trapezoidAndLineVertical.rawValue, isOn: $viewModel.isMirrored)
                    .labelsHidden()
                    .labelStyle(.iconOnly)
                    .controlSize(.extraLarge)
                    .toggleStyle(.button)
                    .buttonBorderShape(.circle)
                    .buttonSizing(.fitted)
                    .buttonStyle(.glassProminent)

            }
            .padding(.small)

            VStack {
                ToolCloseButton()
            }
            .padding(.medium)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

        }
        .frame(width: .previewVideoWidth, height: .popoverWidth)
        .animation(.bouncy, value: viewModel.showSettings)
    }
}
