import SwiftUI

@main
struct TemplateKeyboardApp: App {
    @StateObject private var store = TemplateStore()

    var body: some Scene {
        WindowGroup {
            CategoryListView()
                .environmentObject(store)
        }
    }
}
