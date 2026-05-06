//
//  CalculatorRepositoryTests.swift
//  Zaimka
//
//  Created by Anton Solovev on 27.04.2024.
//

@testable import Zaimka
import Testing

// MARK: - CalculatorRepositoryTests

struct CalculatorRepositoryTests {
    @Test func calculateMonthlyPayment_withValidInput_returnsCorrectAmount() {
        let repository = CalculatorRepository()
        let amount: Double = 100_000
        let term: Double = 12
        let interestRate: Double = 12

        let monthlyPayment = repository.calculateMonthlyPayment(
            amount: amount,
            term: term,
            interestRate: interestRate
        )

        #expect(abs(monthlyPayment - 8884.88) < 0.01)
    }

    @Test func calculateOverpayment_withValidInput_returnsCorrectAmount() {
        let repository = CalculatorRepository()
        let monthlyPayment = 8884.88
        let term: Double = 12
        let amount: Double = 100_000

        let overpayment = repository.calculateOverpayment(
            monthlyPayment: monthlyPayment,
            term: term,
            amount: amount
        )

        #expect(abs(overpayment - 6618.56) < 0.01)
    }

    @Test func calculateTotalPaid_multipliesPaymentByTerm() {
        let repository = CalculatorRepository()

        let totalPaid = repository.calculateTotalPaid(
            monthlyPayment: 100,
            term: 24
        )

        #expect(totalPaid == 2400)
    }
}
