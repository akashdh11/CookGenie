//
//  AppComponents.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/23/26.
//

import SwiftUI

// MARK: - AppTextField
struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(placeholder)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.accent)
                .padding(.leading, 4)
            
            Group {
                if isSecure {
                    SecureField("", text: $text)
                        .keyboardType(keyboardType)
                } else {
                    TextField("", text: $text)
                        .textInputAutocapitalization(autocapitalization)
                        .keyboardType(keyboardType)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .cornerRadius(.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color.accentColor)
            )
        }
    }
}

// MARK: - AppButton
struct AppButton: View {
    let title: String
    var icon: ImageResource? = nil
    let action: () -> Void
    var style: Style = .primary
    var isLoading: Bool = false
    
    enum Style {
        case primary, secondary, outline
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .tint(style == .primary ? .white : .accentColor)
                } else if let icon = icon {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .font(.headline)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: .buttonHeight)
        }
        .buttonStyle(AppButtonStyle(style: style))
        .disabled(isLoading)
    }
}

// MARK: - Button Styles
struct AppButtonStyle: ButtonStyle {
    let style: AppButton.Style
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(backgroundColor(for: configuration.isPressed))
            .foregroundStyle(foregroundStyle())
            .cornerRadius(.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(borderColor(), lineWidth: style == .outline ? 1.5 : 0)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
    
    private func backgroundColor(for isPressed: Bool) -> Color {
        let base: Color
        switch style {
        case .primary: base = .accentColor
        case .secondary: base = Color("SecondaryAccent")
        case .outline: base = Color.clear
        }
        return isPressed ? base.opacity(0.85) : base
    }
    
    private func foregroundStyle() -> Color {
        switch style {
        case .primary: return .white
        case .secondary: return .primary
        case .outline: return .accentColor
        }
    }
    
    private func borderColor() -> Color {
        switch style {
        case .outline: return .accentColor.opacity(0.5)
        default: return .clear
        }
    }
}

// MARK: - Size
extension CGFloat {
    static let cornerRadius: CGFloat = 16
    static let buttonHeight: CGFloat = 56
}
