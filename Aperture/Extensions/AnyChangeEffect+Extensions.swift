//
//  AnyEffect+Extensions.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-06.
//

import SwiftUI
import Pow
import SwiftSyntax



typealias ChangeEffect = AnyChangeEffect

//private var modifier: (Int) -> AnyViewModifier
//
//private var animation: Animation?
//
//internal var cooldown: Double
//
//internal var delay: Double = 0
//
//fileprivate init(modifier: @escaping (Int) -> AnyViewModifier, animation: Animation?, cooldown: Double) {
//    self.modifier = modifier
//    self.animation = animation
//    self.cooldown = cooldown
//}
//
//internal func viewModifier(changeCount: Int) -> some ViewModifier {
//    modifier(changeCount)
//        .animation(animation)
//}
//
//public func delay(_ delay: Double) -> Self {
//    var copy = self
//    copy.delay = delay
//
//    return copy
//}


extension ChangeEffect {


    var changeEffect: AnyChangeEffect {
        self.delay(0)
    }

    init(_ modifier: HeartBeatModifier) {

    }

    func modifier(_ effect: HeartBeatModifier) -> AnyChangeEffect {
        return changeEffect
    }

    func body(content: HeartBeatModifier.Content) -> AnyView {
        _body(content)
    }


}

extension ViewModifier where Self == HeartBeatModifier {


    /// A simple pulse/heartbeat effect that scales the view in and out forever.
    /// - Parameters:
    ///   - interval: Total time for one full beat cycle (grow + shrink).
    ///   - minScale: Scale at the "rest" part of the beat.
    ///   - maxScale: Scale at the peak of the beat.
    static func heartBeat(
        interval: Double = 0.8,
        minScale: CGFloat = 0.95,
        maxScale: CGFloat = 1.05
    ) -> AnyChangeEffect<HeartBeatModifier> {
        let modifier =  HeartBeatModifier(interval: interval, minScale: minScale, maxScale: maxScale)
        guard let modifierValue = modifier as? AnyChangeEffect else {
            return .glow(color: .accent)
        }
        return modifierValue
    }
}
