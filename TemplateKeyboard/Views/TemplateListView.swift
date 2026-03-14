import SwiftUI

struct TemplateListView: View {
    @EnvironmentObject var store: TemplateStore
    let categoryId: UUID

    @State private var showingAddTemplate = false
    @State private var templateToEdit: Template?

    private var category: Category? {
        store.categories.first(where: { $0.id == categoryId })
    }

    var body: some View {
        List {
            ForEach(category?.templates ?? []) { template in
                Button {
                    templateToEdit = template
                } label: {
                    Text(template.text)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
            }
            .onDelete { offsets in
                store.deleteTemplates(at: offsets, in: categoryId)
            }
        }
        .navigationTitle(category?.name ?? "Templates")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddTemplate = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddTemplate) {
            AddTemplateView(categoryId: categoryId, existing: nil)
        }
        .sheet(item: $templateToEdit) { template in
            AddTemplateView(categoryId: categoryId, existing: template)
        }
    }
}
