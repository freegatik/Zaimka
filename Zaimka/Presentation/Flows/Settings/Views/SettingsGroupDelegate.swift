//
//  SettingsGroupDelegate.swift
//  Zaimka
//
//  Created by Anton Solovev on 25.04.2024.
//

// MARK: - SettingsGroupDelegate

@MainActor
protocol SettingsGroupDelegate: AnyObject {
    func turnOffPassword()
    func createPassword()
    func showButton()
    func hideButton()
    func showFaceIDError(message: String)
}
