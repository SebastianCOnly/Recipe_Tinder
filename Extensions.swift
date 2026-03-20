//
//  Extensions.swift
//  Recipe_Tinder
//
//  Useful extensions for SwiftUI and Foundation
//

import SwiftUI

extension Color {
    static let primaryAccent = Color("AccentColor")
    static let cardBackground = Color(uiColor: .systemBackground)
    static let cardShadow = Color.black.opacity(0.2)
    
    static let likeGreen = Color.green.opacity(0.7)
    static let dislikeRed = Color.red.opacity(0.7)
    static let superLikeBlue = Color.blue.opacity(0.7)
}

extension View {
    func cardShadow(radius: CGFloat = 10, opacity: Double = 0.2) -> some View {
        self.shadow(color: Color.black.opacity(opacity), radius: radius, x: 0, y: 5)
    }
    
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

extension String {
    func capitalizedFirst() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension Array where Element == String {
    func toReadableList() -> String {
        guard !isEmpty else { return "" }
        guard count > 1 else { return first ?? "" }
        
        let allButLast = dropLast().joined(separator: ", ")
        return "\(allButLast) and \(last!)"
    }
}

extension Date {
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear], from: self, to: now)
        
        if let weeks = components.weekOfYear, weeks > 0 {
            return "\(weeks) week\(weeks == 1 ? "" : "s") ago"
        }
        if let days = components.day, days > 0 {
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
        if let hours = components.hour, hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        }
        if let minutes = components.minute, minutes > 0 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        }
        return "Just now"
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func asCalories() -> String {
        return "\(Int(self)) cal"
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

extension URL {
    var isReachable: Bool {
        return (try? checkResourceIsReachable()) ?? false
    }
}
