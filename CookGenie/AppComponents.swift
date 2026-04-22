//
//  AppComponents.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/23/26.
//

import SwiftUI

// MARK: AppTextField
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
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color.accentColor)
            )
        }
    }
}

// MARK: AppButton
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

// MARK: Button Styles
struct AppButtonStyle: ButtonStyle {
    let style: AppButton.Style
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(backgroundColor(for: configuration.isPressed))
            .foregroundStyle(foregroundStyle())
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadius))
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

// MARK: FlowLayout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let width = proposal.width ?? 0
        let height = rows.last?.maxY ?? 0
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        for row in rows {
            for element in row.elements {
                let x = bounds.minX + element.x
                let y = bounds.minY + row.y
                element.subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            }
        }
    }
    
    private struct Row {
        var elements: [(subview: LayoutSubview, x: CGFloat)] = []
        var y: CGFloat = 0
        var height: CGFloat = 0
        var maxY: CGFloat { y + height }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let maxWidth = proposal.width ?? 0
        var rows: [Row] = [Row()]
        var currentX: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && !rows.last!.elements.isEmpty {
                var newRow = Row()
                newRow.y = rows.last!.maxY + spacing
                rows.append(newRow)
                currentX = 0
            }
            
            let rowIndex = rows.count - 1
            rows[rowIndex].elements.append((subview, currentX))
            rows[rowIndex].height = max(rows[rowIndex].height, size.height)
            currentX += size.width + spacing
        }
        return rows
    }
}

// MARK: TagView
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
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}


// MARK: SelectionChip
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
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

// MARK: HistoryRow
struct RecipeRow: View {
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
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
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
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.02), radius: 5)
    }
}

// MARK: SafeIconView
struct SafeIconView: View {
    let systemName: String
    var fallbackName: String = "fork.knife"
    
    var body: some View {
        if UIImage(systemName: systemName) != nil {
            Image(systemName: systemName)
        } else {
            Image(systemName: fallbackName)
        }
    }
}

// MARK: Size
extension CGFloat {
    static let cornerRadius: CGFloat = 16
    static let buttonHeight: CGFloat = 56
}
