import Foundation

final class TemplateStore: ObservableObject {
    @Published var categories: [Category] = []

    init() {
        load()
    }

    func load() {
        guard
            let data = AppGroup.defaults.data(forKey: AppGroup.categoriesKey),
            let decoded = try? JSONDecoder().decode([Category].self, from: data)
        else { return }
        categories = decoded
    }

    // MARK: - Categories

    func addCategory(name: String) {
        categories.append(Category(name: name, templates: []))
        save()
    }

    func deleteCategories(at offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
        save()
    }

    // MARK: - Templates

    func addTemplate(_ text: String, to categoryId: UUID) {
        guard let idx = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        categories[idx].templates.append(Template(text: text))
        save()
    }

    func deleteTemplates(at offsets: IndexSet, in categoryId: UUID) {
        guard let idx = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        categories[idx].templates.remove(atOffsets: offsets)
        save()
    }

    func updateTemplate(_ template: Template, in categoryId: UUID) {
        guard
            let catIdx = categories.firstIndex(where: { $0.id == categoryId }),
            let tmpIdx = categories[catIdx].templates.firstIndex(where: { $0.id == template.id })
        else { return }
        categories[catIdx].templates[tmpIdx] = template
        save()
    }

    // MARK: - Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(categories) else { return }
        AppGroup.defaults.set(data, forKey: AppGroup.categoriesKey)
    }
}
