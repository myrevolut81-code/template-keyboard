import Foundation

final class KeyboardTemplateStore: ObservableObject {
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?

    func load() {
        guard
            let data = AppGroup.defaults.data(forKey: AppGroup.categoriesKey),
            let decoded = try? JSONDecoder().decode([Category].self, from: data)
        else {
            categories = []
            return
        }
        categories = decoded

        // Keep the selected category in sync with fresh data.
        if let sel = selectedCategory {
            selectedCategory = decoded.first(where: { $0.id == sel.id })
        }
    }
}
