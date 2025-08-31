import SwiftUI
import UIKit

// MARK: - Design System
struct DesignSystem {
    struct Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let subheadline = Font.system(size: 17, weight: .medium, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let callout = Font.system(size: 16, weight: .medium, design: .rounded)
        static let caption = Font.system(size: 12, weight: .medium, design: .rounded)
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    }
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }
    
    struct Shadow {
        static let light = Color.black.opacity(0.05)
        static let medium = Color.black.opacity(0.1)
        static let heavy = Color.black.opacity(0.15)
    }
}

extension Color {
    static func accentMapped(_ key: String) -> Color {
        switch key {
        case "blue": return Color(red: 0.0, green: 0.48, blue: 1.0)
        case "green": return Color(red: 0.2, green: 0.78, blue: 0.35)
        case "orange": return Color(red: 1.0, green: 0.58, blue: 0.0)
        case "purple": return Color(red: 0.69, green: 0.32, blue: 0.87)
        case "red": return Color(red: 1.0, green: 0.23, blue: 0.19)
        case "gray": return Color(red: 0.56, green: 0.56, blue: 0.58)
        case "black": return Color(red: 0.11, green: 0.11, blue: 0.12)
        default: return Color(red: 0.69, green: 0.32, blue: 0.87)
        }
    }
    
    static let cardBackground = Color(UIColor.secondarySystemBackground)
    static let elevatedBackground = Color(UIColor.tertiarySystemBackground)
}

extension UIApplication {
    static func hideKeyboard() {
        DispatchQueue.main.async {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

struct SmartPlaceholderTextView: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var minHeight: CGFloat
    @Binding var isFocused: Bool

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.isScrollEnabled = true
        tv.backgroundColor = UIColor.clear
        tv.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        tv.delegate = context.coordinator
        tv.textContainerInset = UIEdgeInsets.zero
        tv.textContainer.lineFragmentPadding = 0
        tv.isEditable = true
        tv.layer.cornerRadius = 0
        tv.layer.masksToBounds = true


        let toolbar = UIToolbar(frame: .zero)
        toolbar.sizeToFit()
        toolbar.backgroundColor = UIColor.systemBackground
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: context.coordinator, action: #selector(Coordinator.doneTapped))
        done.tintColor = UIColor.systemBlue
        toolbar.items = [flex, done]
        tv.inputAccessoryView = toolbar

        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            uiView.text = placeholder
            uiView.textColor = UIColor.secondaryLabel
        } else {
            uiView.textColor = UIColor.label
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: SmartPlaceholderTextView
        init(_ parent: SmartPlaceholderTextView) { self.parent = parent }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isFocused = true
            
            if textView.text == parent.placeholder {
                let placeholderText = parent.placeholder
                if let dotsRange = placeholderText.range(of: "...") {
                    let beforeDots = String(placeholderText[..<dotsRange.lowerBound])
                    let afterDots = String(placeholderText[dotsRange.upperBound...])
                    
                    textView.text = beforeDots + afterDots
                    textView.textColor = UIColor.label
                    
                    let cursorPosition = beforeDots.count
                    if let newPosition = textView.position(from: textView.beginningOfDocument, offset: cursorPosition) {
                        textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                    }
                } else {
                    textView.text = ""
                    textView.textColor = UIColor.label
                }
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isFocused = false
            let trimmed = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            parent.text = trimmed
            if trimmed.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.secondaryLabel
            }
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        @objc func doneTapped() {
            UIApplication.hideKeyboard()
        }
    }
}

struct MultilineTextView: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var minHeight: CGFloat
    @Binding var isFocused: Bool

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.isScrollEnabled = true
        tv.backgroundColor = UIColor.clear
        tv.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        tv.delegate = context.coordinator
        tv.textContainerInset = UIEdgeInsets.zero
        tv.textContainer.lineFragmentPadding = 0
        tv.isEditable = true
        tv.layer.cornerRadius = 0
        tv.layer.masksToBounds = true


        let toolbar = UIToolbar(frame: .zero)
        toolbar.sizeToFit()
        toolbar.backgroundColor = UIColor.systemBackground
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: context.coordinator, action: #selector(Coordinator.doneTapped))
        done.tintColor = UIColor.systemBlue
        toolbar.items = [flex, done]
        tv.inputAccessoryView = toolbar

        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            uiView.text = placeholder
            uiView.textColor = UIColor.secondaryLabel
        } else {
            uiView.textColor = UIColor.label
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: MultilineTextView
        init(_ parent: MultilineTextView) { self.parent = parent }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isFocused = true
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = UIColor.label
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isFocused = false
            let trimmed = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            parent.text = trimmed
            if trimmed.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.secondaryLabel
            }
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        @objc func doneTapped() {
            UIApplication.hideKeyboard()
        }
    }
}

struct CardTextEditorIOS14: View {
    @Binding var text: String
    var placeholder: String = ""
    var minHeight: CGFloat = 100
    @State private var isFocused = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .stroke(isFocused ? Color.accentMapped(UserDefaults.standard.string(forKey: "kansha.accent") ?? "purple") : Color.clear, lineWidth: 2)
                )
                .shadow(color: DesignSystem.Shadow.light, radius: 8, x: 0, y: 4)
                .shadow(color: DesignSystem.Shadow.medium, radius: 2, x: 0, y: 1)
            
            SmartPlaceholderTextView(text: $text, placeholder: placeholder, minHeight: minHeight, isFocused: $isFocused)
                .frame(minHeight: minHeight)
                .padding(DesignSystem.Spacing.md)
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            content
            if isPresented {
                VStack { Spacer(); Text(message).padding(.vertical,10).padding(.horizontal,16).background(BlurView()).cornerRadius(12).padding(.bottom,30) }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: isPresented)
            }
        }
    }
}

extension View { 
    func toast(isPresented: Binding<Bool>, message: String) -> some View { 
        modifier(ToastModifier(isPresented: isPresented, message: message)) 
    } 
}

struct BlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView { 
        UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial)) 
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct ModernTextField: View {
    @Binding var text: String
    var placeholder: String
    @State private var isFocused = false
    
    var body: some View {
        TextField(placeholder, text: $text, onEditingChanged: { editing in
            isFocused = editing
        }, onCommit: {
            UIApplication.hideKeyboard()
        })
        .font(DesignSystem.Typography.body)
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(Color.elevatedBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .stroke(isFocused ? Color.accentMapped(UserDefaults.standard.string(forKey: "kansha.accent") ?? "purple") : Color.clear, lineWidth: 2)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

struct GratitudeEntryCard: View {
    let index: Int
    let text: String
    let languageManager: LanguageManager
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.accentMapped(UserDefaults.standard.string(forKey: "kansha.accent") ?? "purple").opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Text("\(index + 1)")
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.accentMapped(UserDefaults.standard.string(forKey: "kansha.accent") ?? "purple"))
            }
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                if text.isEmpty {
                    Text(languageManager.localized("not_available"))
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    Text(text)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(Color.elevatedBackground)
        )
    }
}

struct ModernSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.accentMapped(UserDefaults.standard.string(forKey: "kansha.accent") ?? "purple"))
                
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(.primary)
            }
            
            content
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(Color.cardBackground)
                .shadow(color: DesignSystem.Shadow.light, radius: 4, x: 0, y: 2)
        )
    }
}

struct ColorPickerButton: View {
    let color: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.accentMapped(color))
                    .frame(width: 40, height: 40)
                
                if isSelected {
                    Circle()
                        .stroke(Color.primary, lineWidth: 3)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

struct LanguagePickerRow: View {
    let language: LanguageManager.LanguageInfo
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(language.nativeName)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(.primary)
                    
                    Text(language.name)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color.accentMapped(UserDefaults.standard.string(forKey: "kansha.accent") ?? "purple"))
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(isSelected ? Color.accentMapped(UserDefaults.standard.string(forKey: "kansha.accent") ?? "purple").opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
