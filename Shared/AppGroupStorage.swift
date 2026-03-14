import Foundation

enum AppGroup {
    static let identifier = "group.templatekeyboard"
    static let categoriesKey = "categories"

    static var defaults: UserDefaults {
        guard let ud = UserDefaults(suiteName: identifier) else {
            fatalError("Could not create UserDefaults for App Group '\(identifier)'. Ensure the App Group is configured in both targets' entitlements.")
        }
        return ud
    }
}
