//
//  DebtDetailsView.swift
//  Zaimka
//
//  Created by Anton Solovev on 20.04.2024.
//

import SwiftUI

struct DebtDetailsView: UIViewControllerRepresentable {
    var credit: CreditModel
    func makeUIViewController(context: Context) -> DebtDetailsViewController {
        DebtDetailsViewController(for: credit)
    }

    func updateUIViewController(_ controller: DebtDetailsViewController, context: Context) {}
}
