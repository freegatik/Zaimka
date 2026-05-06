//
//  RepositoryValidateImplTests.swift
//  Zaimka
//
//  Created by Anton Solovev on 06.05.2026.
//

@testable import Zaimka
import SwiftUI
import Testing

// MARK: - RepositoryValidateImplTests

struct RepositoryValidateImplTests {
    private func validate(
        text: String,
        initialValue: Double? = nil
    ) -> (value: Double?, error: Bool) {
        let repo = RepositoryValidateImpl()
        var value = initialValue
        var error = false
        let valueBinding = Binding<Double?>(
            get: { value },
            set: { value = $0 }
        )
        let errorBinding = Binding<Bool>(
            get: { error },
            set: { error = $0 }
        )
        repo.validateInput(text: text, value: valueBinding, error: errorBinding)
        return (value, error)
    }

    @Test func emptyText_clearsValueAndError() {
        let result = validate(text: "", initialValue: 42)
        #expect(result.value == nil)
        #expect(result.error == false)
    }

    @Test func loneDot_setsError() {
        let result = validate(text: ".")
        #expect(result.error == true)
    }

    @Test func loneComma_setsError() {
        let result = validate(text: ",")
        #expect(result.error == true)
    }

    @Test func invalidCharacters_setsError() {
        let result = validate(text: "12a3")
        #expect(result.error == true)
    }

    @Test func multipleDots_setsError() {
        let result = validate(text: "1.2.3")
        #expect(result.error == true)
    }

    @Test func integer_parses() {
        let result = validate(text: "1200")
        #expect(result.value == 1200)
        #expect(result.error == false)
    }

    @Test func decimalWithDot_parses() {
        let result = validate(text: "12.5")
        #expect(result.value == 12.5)
        #expect(result.error == false)
    }

    @Test func decimalWithComma_unifiesAndParses() {
        let result = validate(text: "12,75")
        #expect(result.value == 12.75)
        #expect(result.error == false)
    }

    @Test func leadingDot_normalizesToZeroPrefix() {
        let result = validate(text: ".5")
        #expect(result.value == 0.5)
        #expect(result.error == false)
    }

    @Test func leadingComma_unifiesLikeDotPrefix() {
        let result = validate(text: ",5")
        #expect(result.value == 0.5)
        #expect(result.error == false)
    }
}
