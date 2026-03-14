import SwiftUI

struct KeyboardView: View {
    @ObservedObject var store: KeyboardTemplateStore
    let insertText: (String) -> Void
    let nextKeyboard: () -> Void
    let deleteBackward: () -> Void
    let selectAll: () -> Void

    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            contentArea
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .onChange(of: store.selectedCategory) { _, newValue in
            if newValue == nil { searchText = "" }
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack(spacing: 8) {
            if store.selectedCategory != nil {
                backButton
                Spacer()
                deleteButton
                selectAllButton
            } else {
                categoryRow
            }
            globeButton
        }
        .padding(.horizontal, 10)
        .frame(height: 44)
    }

    private var backButton: some View {
        Button {
            store.selectedCategory = nil
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
                Text("Back")
            }
            .font(.system(size: 15))
            .foregroundStyle(.primary)
        }
    }

    private var deleteButton: some View {
        Button(action: deleteBackward) {
            Image(systemName: "delete.backward")
                .font(.system(size: 16))
                .foregroundStyle(.primary)
        }
        .frame(width: 36, height: 36)
    }

    private var selectAllButton: some View {
        Button(action: selectAll) {
            Text("Select All")
                .font(.system(size: 13))
                .foregroundStyle(.primary)
        }
    }

    private var categoryRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(store.categories) { category in
                    Button(category.name) {
                        store.selectedCategory = category
                    }
                    .buttonStyle(CategoryButtonStyle())
                }
            }
            .padding(.horizontal, 2)
        }
    }

    // Globe button lets the user switch to another keyboard.
    // needsInputModeSwitchKey is not checked here because this
    // is a personal tool — always showing the button is harmless.
    private var globeButton: some View {
        Button(action: nextKeyboard) {
            Image(systemName: "globe")
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
        }
        .frame(width: 36, height: 36)
    }

    // MARK: - Content

    @ViewBuilder
    private var contentArea: some View {
        if let category = store.selectedCategory {
            if category.templates.isEmpty {
                placeholder("No templates in this category")
            } else {
                templateListWithSearch(for: category)
            }
        } else {
            let hint = store.categories.isEmpty
                ? "Open TemplateKeyboard app to add templates"
                : "Tap a category above"
            placeholder(hint)
        }
    }

    private func templateListWithSearch(for category: Category) -> some View {
        let filtered = category.templates.filter {
            searchText.isEmpty || $0.text.localizedCaseInsensitiveContains(searchText)
        }
        return VStack(spacing: 0) {
            TextField("Search templates", text: $searchText)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            Divider()
            if filtered.isEmpty {
                placeholder("No results")
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(filtered) { template in
                            Button {
                                insertText(template.text + " ")
                            } label: {
                                Text(template.text)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .foregroundStyle(.primary)
                            .simultaneousGesture(LongPressGesture().onEnded { _ in
                                UIPasteboard.general.string = template.text
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            })
                        }
                    }
                    .padding(8)
                }
            }
        }
    }

    private func placeholder(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(.secondary)
            .font(.callout)
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Button Styles

struct CategoryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}
