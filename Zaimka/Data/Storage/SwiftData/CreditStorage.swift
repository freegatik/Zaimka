//
//  CreditStorage.swift
//  Zaimka
//
//  Created by Anton Solovev on 14.04.2024.
//

import Foundation
import SwiftData

// swiftlint:disable type_body_length
@MainActor
final class CreditStorage: ObservableObject {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    private var needsUpdate: Bool = true

    @Published var credits: [CreditModel] = []

    init() {
        let container: ModelContainer
        let context: ModelContext
        do {
            container = try ModelContainer(
                for: CreditModel.self, PaymentModel.self,
                configurations: ModelConfiguration()
            )
            context = container.mainContext
        } catch {
            AppLogger.storage.error(
                "Persistent SwiftData store failed: \(error.localizedDescription, privacy: .public)"
            )
            do {
                let memoryOnly = ModelConfiguration(isStoredInMemoryOnly: true)
                container = try ModelContainer(
                    for: CreditModel.self, PaymentModel.self,
                    configurations: memoryOnly
                )
                context = container.mainContext
                AppLogger.storage.warning(
                    "Using in-memory store; data will not persist between launches."
                )
            } catch {
                AppLogger.storage.critical(
                    "SwiftData unavailable: \(error.localizedDescription, privacy: .public)"
                )
                fatalError("SwiftData ModelContainer could not be created.")
            }
        }
        modelContainer = container
        modelContext = context
        Task { await updateCredits() }
    }

    /// Unit tests and previews: inject a stack (typically `ModelConfiguration(isStoredInMemoryOnly: true)`).
    init(modelContainer: ModelContainer, modelContext: ModelContext) {
        self.modelContainer = modelContainer
        self.modelContext = modelContext
        needsUpdate = true
        Task { await updateCredits() }
    }

    func saveCredit(_ credit: CreditModel) {
        modelContext.insert(credit)
        do {
            try modelContext.save()

            needsUpdate = true
            Task { await updateCredits() }

            NotificationCenter.default.post(name: .creditAdded, object: nil)
            AppLogger.storage.debug("Credit saved: \(credit.id, privacy: .public)")
        } catch {
            AppLogger.storage.error(
                "Error saving credit: \(error.localizedDescription, privacy: .public)"
            )
        }
    }

    func loadCredits() -> [CreditModel] {
        do {
            let descriptor = FetchDescriptor<CreditModel>(
                sortBy: [SortDescriptor(\.startDate, order: .reverse)]
            )
            let loadedCredits = try modelContext.fetch(descriptor)

            if needsUpdate {
                Task { await updateCredits() }
            }

            return loadedCredits
        } catch {
            AppLogger.storage.error(
                "Error loading credits: \(error.localizedDescription, privacy: .public)"
            )
            credits = []
            return []
        }
    }

    func loadCredit(by id: String) -> CreditModel? {
        credits.first { $0.id == id }
    }

    func addPayment(for creditId: String, with payment: PaymentModel) {
        do {
            let descriptor = FetchDescriptor<CreditModel>(
                predicate: #Predicate { $0.id == creditId }
            )

            guard let credit = try modelContext.fetch(descriptor).first else {
                AppLogger.storage.warning("Credit not found for id \(creditId, privacy: .public)")
                return
            }

            credit.payments.append(payment)
            credit.depositedAmount += payment.amount

            try modelContext.save()

            if let index = credits.firstIndex(where: { $0.id == creditId }) {
                credits[index] = credit
            }

            needsUpdate = true
            if needsUpdate {
                Task { await updateCredits() }
            }

            NotificationCenter.default.post(name: .creditAdded, object: nil)

            AppLogger.storage.debug("Payment added for credit: \(credit.name, privacy: .public)")
        } catch {
            AppLogger.storage.error(
                "Error adding payment: \(error.localizedDescription, privacy: .public)"
            )
        }
    }

    func deleteCredit(for id: String) {
        do {
            let descriptor = FetchDescriptor<CreditModel>(
                predicate: #Predicate { $0.id == id }
            )

            guard let credit = try modelContext.fetch(descriptor).first else {
                AppLogger.storage.warning("Credit not found for id \(id, privacy: .public)")
                return
            }

            modelContext.delete(credit)
            try modelContext.save()

            credits.removeAll { $0.id == id }

            let descriptorAfter = FetchDescriptor<CreditModel>(
                sortBy: [SortDescriptor(\.startDate, order: .reverse)]
            )
            credits = try modelContext.fetch(descriptorAfter)

            NotificationCenter.default.post(name: .creditAdded, object: nil)
            AppLogger.storage.debug("Credit deleted: \(credit.name, privacy: .public)")
        } catch {
            AppLogger.storage.error(
                "Error deleting credit: \(error.localizedDescription, privacy: .public)"
            )
        }
    }

    func clearAllCredits() {
        do {
            let descriptor = FetchDescriptor<CreditModel>()
            let allCredits = try modelContext.fetch(descriptor)
            for credit in allCredits {
                modelContext.delete(credit)
            }
            try modelContext.save()
            credits.removeAll()
            AppLogger.storage.debug("All credits cleared")
        } catch {
            AppLogger.storage.error(
                "Error clearing credits: \(error.localizedDescription, privacy: .public)"
            )
        }
    }

    func updateCredits() async {
        do {
            let descriptor = FetchDescriptor<CreditModel>(
                sortBy: [SortDescriptor(\.startDate, order: .reverse)]
            )
            credits = try modelContext.fetch(descriptor)
            needsUpdate = false
        } catch {
            AppLogger.storage.error(
                "Error updating credits: \(error.localizedDescription, privacy: .public)"
            )
            credits = []
        }
    }

    func setValue(_ value: some Any, forKey key: String, in credit: CreditModel) {
        switch key {
        case "name":
            credit.name = value as? String ?? credit.name
        case "amount":
            credit.amount = value as? Double ?? credit.amount
        case "depositedAmount":
            credit.depositedAmount = value as? Double ?? credit.depositedAmount
        case "percentage":
            credit.percentage = value as? Double ?? credit.percentage
        case "period":
            credit.period = value as? Int ?? credit.period
        default:
            AppLogger.storage.warning("Invalid key for setValue: \(key, privacy: .public)")
            return
        }

        do {
            try modelContext.save()
            DispatchQueue.main.async { _ = self.loadCredits() }
        } catch {
            AppLogger.storage.error(
                "Error saving updated credit: \(error.localizedDescription, privacy: .public)"
            )
        }
    }

    func getValue<T>(forKey key: String, from credit: CreditModel) -> T? {
        switch key {
        case "name":
            return credit.name as? T
        case "amount":
            return credit.amount as? T
        case "depositedAmount":
            return credit.depositedAmount as? T
        case "percentage":
            return credit.percentage as? T
        case "period":
            return credit.period as? T
        default:
            AppLogger.storage.warning("Invalid key for getValue: \(key, privacy: .public)")
            return nil
        }
    }
}
// swiftlint:enable type_body_length
