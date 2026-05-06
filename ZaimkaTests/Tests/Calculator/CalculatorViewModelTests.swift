//
//  CalculatorViewModelTests.swift
//  Zaimka
//
//  Created by Anton Solovev on 27.04.2024.
//

@testable import Zaimka
import Testing

// MARK: - CalculatorViewModelTests

@MainActor
struct CalculatorViewModelTests {
    @Test func validateAmount_withValidInput_updatesAmount() {
        let mockRepository = MockCalculatorRepository()
        let useCase = CalculatorUseCase(repository: mockRepository)
        let viewModel = CalculatorViewModel(useCase: useCase)

        viewModel.validateAmount("100000")

        #expect(viewModel.amount == 100_000)
        #expect(!viewModel.amountError)
    }

    @Test func validateAmount_withInvalidInput_setsError() {
        let mockRepository = MockCalculatorRepository()
        let useCase = CalculatorUseCase(repository: mockRepository)
        let viewModel = CalculatorViewModel(useCase: useCase)

        viewModel.validateAmount("invalid")

        #expect(viewModel.amount == nil)
        #expect(viewModel.amountError)
    }

    @Test func calculate_withValidInputs_updatesResults() {
        let mockRepository = MockCalculatorRepository()
        mockRepository.monthlyPaymentToReturn = 8884.88
        mockRepository.overpaymentToReturn = 6618.56
        mockRepository.totalPaidToReturn = 106_618.56

        let useCase = CalculatorUseCase(repository: mockRepository)
        let viewModel = CalculatorViewModel(useCase: useCase)

        viewModel.validateAmount("100000")
        viewModel.validateTerm("12")
        viewModel.validateRate("12")
        viewModel.calculate()

        #expect(abs(viewModel.monthlyPayment - 8884.88) < 0.01)
        #expect(abs(viewModel.overpayment - 6618.56) < 0.01)
        #expect(abs(viewModel.totalPaid - 106_618.56) < 0.01)
    }

    @Test func calculate_withInvalidAmountText_setsAmountError() {
        let mockRepository = MockCalculatorRepository()
        let useCase = CalculatorUseCase(repository: mockRepository)
        let viewModel = CalculatorViewModel(useCase: useCase)

        viewModel.amountText = "not-a-number"
        viewModel.validateAmount("not-a-number")
        viewModel.validateTerm("12")
        viewModel.validateRate("12")
        viewModel.calculate()

        #expect(viewModel.amountError)
        #expect(mockRepository.calculateMonthlyPaymentCallCount == 0)
    }
}
