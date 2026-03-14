import SwiftUI

struct AddTemplateView: View {
    @EnvironmentObject var store: TemplateStore
    @Environment(\.dismiss) private var dismiss

    let categoryId: UUID
    let existing: Template?

    @State private var text: String

    init(categoryId: UUID, existing: Template?) {
        self.categoryId = categoryId
        self.existing = existing
        _text = State(initialValue: existing?.text ?? "")
    }

    private var isEditing: Bool { existing != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Template text") {
                    TextEditor(text: $text)
                        .frame(minHeight: 140)
                }
            }
            .navigationTitle(isEditing ? "Edit Template" : "New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        if isEditing, var updated = existing {
                            updated.text = trimmed
                            store.updateTemplate(updated, in: categoryId)
                        } else {
                            store.addTemplate(trimmed, to: categoryId)
                        }
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
