//
//  UsecaseValidateImplTests.swift
//  Zaimka
//
//  Created by Anton Solovev on 06.05.2026.
//

@testable import Zaimka
import SwiftUI
import Testing

// MARK: - UsecaseValidateImplTests

struct UsecaseValidateImplTests {
    @Test func execute_delegatesToRepositoryWithSameArguments() {
        let mock = MockRepositoryValidate()
        let useCase = UsecaseValidateImpl(repository: mock)

        var value: Double?
        var error = false
        let valueBinding = Binding<Double?>(
            get: { value },
            set: { value = $0 }
        )
        let errorBinding = Binding<Bool>(
            get: { error },
            set: { error = $0 }
        )

        useCase.execute(text: "99.9", value: valueBinding, error: errorBinding)

        #expect(mock.validateInputCallCount == 1)
        #expect(mock.capturedText == "99.9")
    }
}
