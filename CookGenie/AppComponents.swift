//
//  AppComponents.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/23/26.
//

import SwiftUI

// MARK: Reusable components around the app

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
    var systemIcon: String? = nil
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
                } else if let systemIcon = systemIcon {
                    Image(systemName: systemIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
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

// MARK: - FlowLayout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for row in result.rows {
            for element in row.elements {
                element.subview.place(at: CGPoint(x: bounds.minX + element.x, y: bounds.minY + element.y), proposal: .unspecified)
            }
        }
    }
    
    struct FlowResult {
        struct Element {
            let subview: LayoutSubview
            let x: CGFloat
            let y: CGFloat
        }
        struct Row {
            var elements: [Element] = []
            var y: CGFloat = 0
            var height: CGFloat = 0
        }
        var rows: [Row] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: LayoutSubviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var currentRow = Row()
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if currentX + size.width > maxWidth && !currentRow.elements.isEmpty {
                    currentRow.y = currentY
                    rows.append(currentRow)
                    currentY += currentRow.height + spacing
                    currentX = 0
                    currentRow = Row()
                }
                
                currentRow.elements.append(Element(subview: subview, x: currentX, y: currentY))
                currentRow.height = max(currentRow.height, size.height)
                currentX += size.width + spacing
            }
            
            if !currentRow.elements.isEmpty {
                currentRow.y = currentY
                rows.append(currentRow)
                currentY += currentRow.height
            }
            
            self.size = CGSize(width: maxWidth, height: currentY)
        }
    }
}

// MARK: - TagView
struct TagView: View {
    let title: String
    var onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color("TagBackground"))
        .foregroundStyle(Color.orange)
        .cornerRadius(12)
    }
}

// MARK: - SectionHeader
struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.accent)
                }
            }
        }
    }
}

// MARK: - SelectionChip
struct SelectionChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color("ActiveChipBackground") : Color("TagBackground").opacity(0.5))
                .foregroundStyle(isSelected ? .black : .primary.opacity(0.8))
                .cornerRadius(12)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

// MARK: - HistoryRow
struct HistoryRow: View {
    let title: String
    let duration: String
    let ingredients: Int
    let date: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .frame(width: 60, height: 60)
                .background(Color("HistoryItemHighlight"))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(duration)
                        .foregroundStyle(.red)
                    Text("•")
                    Text("\(ingredients) Ingredients")
                    Text("•")
                    Text(date)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .fontWeight(.medium)
                
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color("CardBackground"))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.02), radius: 5)
    }
}

// MARK: - Size
extension CGFloat {
    static let cornerRadius: CGFloat = 16
    static let buttonHeight: CGFloat = 56
}
