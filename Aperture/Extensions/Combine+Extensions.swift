//
//  Combine+Extensions.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-26.
//

import Combine

extension Publisher where Failure == Never {
    var eraseToAnyPublisher: AnyPublisher<Output, Never> {
        return self.eraseToAnyPublisher()
    }
}
