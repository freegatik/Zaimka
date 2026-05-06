//
//  CreditStorageTests.swift
//  Zaimka
//
//  Created by Anton Solovev on 06.05.2026.
//

@testable import Zaimka
import Foundation
import SwiftData
import Testing

// MARK: - CreditStorageTests

@MainActor
struct CreditStorageTests {
    private func makeStorage() throws -> CreditStorage {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: CreditModel.self, PaymentModel.self,
            configurations: configuration
        )
        return CreditStorage(modelContainer: container, modelContext: container.mainContext)
    }

    private func sampleCredit(id: String) -> CreditModel {
        CreditModel(
            id: id,
            name: "Test credit",
            amount: 1000,
            depositedAmount: 0,
            percentage: 12,
            creditType: .consumer,
            creditTarget: .taken,
            startDate: Date(timeIntervalSince1970: 1_704_067_200),
            period: 12,
            payments: []
        )
    }

    @Test func saveCredit_loadCredits_returnsInsertedRow() throws {
        let storage = try makeStorage()
        storage.saveCredit(sampleCredit(id: "id-1"))

        let rows = storage.loadCredits()
        #expect(rows.count == 1)
        #expect(rows.first?.id == "id-1")
        #expect(rows.first?.amount == 1000)
    }

    @Test func addPayment_updatesDepositedAmount() throws {
        let storage = try makeStorage()
        storage.saveCredit(sampleCredit(id: "id-2"))

        let payment = PaymentModel(
            id: "pay-1",
            amount: 250,
            date: Date(timeIntervalSince1970: 1_704_153_600),
            paymentType: .earlyPayment
        )
        storage.addPayment(for: "id-2", with: payment)

        let updated = storage.loadCredits().first { $0.id == "id-2" }
        #expect(updated?.depositedAmount == 250)
        #expect(updated?.payments.count == 1)
    }

    @Test func deleteCredit_removesRow() throws {
        let storage = try makeStorage()
        storage.saveCredit(sampleCredit(id: "id-3"))

        storage.deleteCredit(for: "id-3")

        #expect(storage.loadCredits().isEmpty)
    }

    @Test func clearAllCredits_removesEveryRow() throws {
        let storage = try makeStorage()
        storage.saveCredit(sampleCredit(id: "a"))
        storage.saveCredit(sampleCredit(id: "b"))

        storage.clearAllCredits()

        #expect(storage.loadCredits().isEmpty)
    }

    @Test func loadCreditAfterUpdate_findsById() async throws {
        let storage = try makeStorage()
        storage.saveCredit(sampleCredit(id: "id-4"))
        await storage.updateCredits()

        let found = storage.loadCredit(by: "id-4")
        #expect(found?.name == "Test credit")
    }

    @Test func setValueAndGetValue_roundTripForAmount() throws {
        let storage = try makeStorage()
        storage.saveCredit(sampleCredit(id: "id-5"))
        guard let credit = storage.loadCredits().first(where: { $0.id == "id-5" }) else {
            Issue.record("Expected saved credit")
            return
        }

        storage.setValue(3333.0, forKey: "amount", in: credit)

        let amount: Double? = storage.getValue(forKey: "amount", from: credit)
        #expect(amount == 3333)
    }
}
