import Foundation
import Combine

final class TemplateStore: ObservableObject {

    static let shared = TemplateStore()

    @Published var categories: [TemplateCategory] = []
    @Published var quickTemplates: [Template] = []

    private let suite        = "group.templatekeyboard"
    private let categoriesKey = "categories"
    private let quickKey      = "quick_templates"

    private var defaults: UserDefaults? {
        UserDefaults(suiteName: suite)
    }

    init() {
        load()
    }

    // MARK: - Load / Save

    func load() {
        if let data = defaults?.data(forKey: categoriesKey),
           let decoded = try? JSONDecoder().decode([TemplateCategory].self, from: data) {
            categories = decoded
        } else {
            categories = []
        }

        if let data = defaults?.data(forKey: quickKey),
           let decoded = try? JSONDecoder().decode([Template].self, from: data) {
            quickTemplates = decoded
        } else {
            quickTemplates = []
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(categories) {
            defaults?.set(data, forKey: categoriesKey)
        }
        if let data = try? JSONEncoder().encode(quickTemplates) {
            defaults?.set(data, forKey: quickKey)
        }
    }

    // MARK: - Category CRUD

    func addCategory(name: String) {
        categories.append(TemplateCategory(name: name, templates: []))
        save()
    }

    func deleteCategories(at offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
        save()
    }

    // MARK: - Template CRUD (inside category)

    func addTemplate(_ text: String, to categoryId: UUID) {
        guard let idx = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        categories[idx].templates.append(Template(text: text))
        save()
    }

    func deleteTemplates(at offsets: IndexSet, in categoryId: UUID) {
    guard let idx = categories.firstIndex(where: { $0.id == categoryId }) else { return }

    for index in offsets.sorted(by: >) {
        categories[idx].templates.remove(at: index)
    }

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

    // MARK: - Quick Template CRUD

    func addQuickTemplate(text: String) {
        quickTemplates.append(Template(text: text))
        save()
    }

    func deleteQuickTemplates(at offsets: IndexSet) {
    for index in offsets.sorted(by: >) {
        quickTemplates.remove(at: index)
    }
    save()
}

    func deleteQuickTemplate(id: UUID) {
        quickTemplates.removeAll { $0.id == id }
        save()
    }

    // MARK: - Delete from category by id (used by keyboard delete mode)

    func deleteTemplate(id: UUID, fromCategory categoryId: UUID) {
        guard let idx = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        categories[idx].templates.removeAll { $0.id == id }
        save()
    }
}
