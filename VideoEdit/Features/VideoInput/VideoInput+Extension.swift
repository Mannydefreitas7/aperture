//
//  VideoInput+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-06.
//
import SwiftUI

extension VideoInputView {

    var imageWidth: CGFloat { .thumbnail / 2.5 }

    @ViewBuilder
    func ToolCloseButton() -> some View {
        Button {
            withAnimation(.bouncy) {
                device.showSettings.toggle()
            }
        } label: {
            Image(systemSymbol: .xmark)
        }
        .buttonStyle(.accessoryBarAction)
        .buttonBorderShape(.circle)
    }

    @ViewBuilder
    func ToolButton() -> some View {
        HStack(spacing: .small / 2) {
            Toggle(isOn: $device.isOn) {
                Image(systemSymbol: device.isOn ? .videoFill : .videoSlashFill)
                    .contentTransition(.symbolEffect(.replace))
                    .font(.title2)
                    .frame(width: .recordWidth)
            }
            .toggleStyle(.secondary)
            .animation(.bouncy, value: device.isOn)

            if device.isOn {
                Button {
                    withAnimation(.bouncy) {
                        device.showSettings.toggle()
                        if viewModel.microphone.showSettings {
                            viewModel.microphone.showSettings = false
                        }
                    }
                } label: {
                    Text(device.device?.localizedName)
                }
                .buttonStyle(.accessoryBar)
            }
        }

    }

    @ViewBuilder
    func ToolBarOptions() -> some View {
        ZStack(alignment: .topLeading) {

            Placeholder()

            if viewModel.videoInputViewModel.session.isRunning {
                VideoPreview(session: viewModel.videoInputViewModel.session)
               // VideoInputPreview(session: viewModel.videoInputViewModel.session)
                    .frame(width: .popoverWidth)
            }

            HStack {
                Image(.imac)
                    .resizable()
                    .scaledToFit()
                    .frame(width: .recordWidth)

                VStack(alignment: .leading) {
                    Text("Device")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(device.name.capitalized)
                        .font(.headline)
                        .bold()
                }
            }
            .padding(.medium)

        }
        .frame(minHeight: .zero)
        .frame(width: .popoverWidth * 1.2)
        .overlay(alignment: .topTrailing) {
            ToolCloseButton()
                .offset(x: .medium, y: .medium)
        }
    }

    @ViewBuilder
    func Placeholder() -> some View {
        ContentUnavailableView(.notAvailableTitle, systemSymbol: .videoSlashCircle, description: .init(verbatim: .notAvailbleDescription))
    }
}
