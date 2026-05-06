//
//  CalculatorUseCaseTests.swift
//  Zaimka
//
//  Created by Anton Solovev on 27.04.2024.
//

@testable import Zaimka
import Testing

// MARK: - CalculatorUseCaseTests

struct CalculatorUseCaseTests {
    @Test func calculate_callsRepositoryMethods() {
        let mockRepository = MockCalculatorRepository()
        let useCase = CalculatorUseCase(repository: mockRepository)

        _ = useCase.calculate(amount: 100_000, term: 12, interestRate: 12)

        #expect(mockRepository.calculateMonthlyPaymentCallCount == 1)
        #expect(mockRepository.calculateOverpaymentCallCount == 1)
        #expect(mockRepository.calculateTotalPaidCallCount == 1)
    }

    @Test func calculate_returnsCorrectCalculation() {
        let mockRepository = MockCalculatorRepository()
        mockRepository.monthlyPaymentToReturn = 8884.88
        mockRepository.overpaymentToReturn = 6618.56
        mockRepository.totalPaidToReturn = 106_618.56

        let useCase = CalculatorUseCase(repository: mockRepository)

        let result = useCase.calculate(amount: 100_000, term: 12, interestRate: 12)

        #expect(abs(result.monthlyPayment - 8884.88) < 0.01)
        #expect(abs(result.overpayment - 6618.56) < 0.01)
        #expect(abs(result.totalPaid - 106_618.56) < 0.01)
    }

    @Test func saveCalculation_invokesRepositoryOnce() async throws {
        let mockRepository = MockCalculatorRepository()
        let useCase = CalculatorUseCase(repository: mockRepository)
        let calculation = DebtCalculation(
            totalAmount: 100_000,
            term: 12,
            interestRate: 12,
            monthlyPayment: 1,
            overpayment: 2,
            totalPaid: 3
        )

        try await useCase.saveCalculation(calculation)

        #expect(mockRepository.saveCalculationCallCount == 1)
    }

    @Test func saveCalculation_propagatesRepositoryErrors() async throws {
        struct StubError: Error {}

        let mockRepository = MockCalculatorRepository()
        mockRepository.saveCalculationError = StubError()
        let useCase = CalculatorUseCase(repository: mockRepository)
        let calculation = DebtCalculation(
            totalAmount: 1,
            term: 1,
            interestRate: 1,
            monthlyPayment: 1,
            overpayment: 1,
            totalPaid: 2
        )

        await #expect(throws: StubError.self) {
            try await useCase.saveCalculation(calculation)
        }
    }
}
