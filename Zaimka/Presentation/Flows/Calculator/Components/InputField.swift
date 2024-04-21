//
//  InputField.swift
//  Zaimka
//
//  Created by Anton Solovev on 23.04.2024.
//

import SwiftUI

struct InputField: View {
    var title: String
    @Binding var value: Double
    var keyboardType: UIKeyboardType = .decimalPad

    @State private var textValue: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            TextField("Enter \(title.lowercased())", text: $textValue)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(keyboardType)
                .onChange(of: textValue) { _, newValue in
                    value = Double(newValue) ?? value
                }
                .onAppear {
                    textValue = String(value)
                }
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
    }
}
