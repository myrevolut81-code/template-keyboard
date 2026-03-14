import SwiftUI

struct CategoryListView: View {
    @EnvironmentObject var store: TemplateStore
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.categories) { category in
                    NavigationLink(category.name) {
                        TemplateListView(categoryId: category.id)
                    }
                }
                .onDelete { offsets in
                    store.deleteCategories(at: offsets)
                }
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory, onDismiss: { newCategoryName = "" }) {
                addCategorySheet
            }
        }
    }

    private var addCategorySheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Category name", text: $newCategoryName)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAddCategory = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let name = newCategoryName.trimmingCharacters(in: .whitespaces)
                        guard !name.isEmpty else { return }
                        store.addCategory(name: name)
                        showingAddCategory = false
                    }
                    .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.height(180)])
    }
}
