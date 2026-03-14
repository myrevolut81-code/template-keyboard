import UIKit

final class KeyboardRootView: UIView {

    // MARK: - Callbacks (set by KeyboardViewController)

    let insertText:    (String) -> Void
    let deleteBackward: () -> Void
    let clearAll:       () -> Void
    let nextKeyboard:   () -> Void

    // MARK: - Sub-screens

    private lazy var mainMenuView: UIView    = makeMainMenuView()
    private var categoriesView: CategoriesView?
    private var templatesView:  TemplatesView?

    // MARK: - Init

    init(
        insertText: @escaping (String) -> Void,
        deleteBackward: @escaping () -> Void,
        clearAll: @escaping () -> Void,
        nextKeyboard: @escaping () -> Void
    ) {
        self.insertText     = insertText
        self.deleteBackward = deleteBackward
        self.clearAll       = clearAll
        self.nextKeyboard   = nextKeyboard
        super.init(frame: .zero)
        backgroundColor = .systemGroupedBackground
        setupMainMenu()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    // MARK: - Public

    func reload() {
        // If we're on the main menu, just refresh it
        if mainMenuView.superview != nil {
            refreshMainMenu()
        }
    }

    // MARK: - Main Menu Setup

    private func setupMainMenu() {
        addSubview(mainMenuView)
        mainMenuView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainMenuView.topAnchor.constraint(equalTo: topAnchor),
            mainMenuView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainMenuView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainMenuView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func makeMainMenuView() -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGroupedBackground

        // Globe button — top right
        let globeBtn = makeToolbarButton(image: "globe")
        globeBtn.addTarget(self, action: #selector(globeTapped), for: .touchUpInside)
        container.addSubview(globeBtn)
        globeBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            globeBtn.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            globeBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            globeBtn.widthAnchor.constraint(equalToConstant: 36),
            globeBtn.heightAnchor.constraint(equalToConstant: 36),
        ])

        // Stack of two main buttons
        let stack = UIStackView()
        stack.axis      = .vertical
        stack.spacing   = 10
        stack.translatesAutoresizingMaskIntoConstraints = false

        let catBtn   = makeMenuButton(title: "Категории", tag: 0)
        let quickBtn = makeMenuButton(title: "Быстрые шаблоны", tag: 1)
        stack.addArrangedSubview(catBtn)
        stack.addArrangedSubview(quickBtn)
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])

        // Empty state label (hidden by default)
        let label = makeEmptyLabel("Нет шаблонов. Добавьте их в приложении.")
        label.tag = 99
        label.isHidden = true
        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
        ])

        return container
    }

    private func makeMenuButton(title: String, tag: Int) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = .label
        config.baseBackgroundColor = .secondarySystemGroupedBackground
        config.cornerStyle = .medium
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            return a
        }

        let btn = UIButton(configuration: config)
        btn.tag = tag
        btn.heightAnchor.constraint(equalToConstant: 52).isActive = true
        btn.addTarget(self, action: #selector(mainMenuTapped(_:)), for: .touchUpInside)
        return btn
    }

    private func refreshMainMenu() {
        let store = TemplateStore.shared
        let isEmpty = store.categories.isEmpty && store.quickTemplates.isEmpty
        guard let label = mainMenuView.viewWithTag(99) else { return }
        label.isHidden = !isEmpty

        // Show/hide the stack
        for sub in mainMenuView.subviews {
            if let stack = sub as? UIStackView { stack.isHidden = isEmpty }
        }
    }

    // MARK: - Navigation

    @objc private func mainMenuTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            showCategories()
        } else {
            showQuickTemplates()
        }
    }

    private func showCategories() {
        let cv = CategoriesView(
            categories: TemplateStore.shared.categories,
            onBack: { [weak self] in self?.popToMainMenu() },
            onSelectCategory: { [weak self] category in
                self?.showTemplates(title: category.name,
                                    templates: category.templates,
                                    onBack: { self?.popToCategories() })
            },
            nextKeyboard: nextKeyboard
        )
        categoriesView = cv
        transition(from: mainMenuView, to: cv)
    }

    private func showQuickTemplates() {
        showTemplates(
            title: "Быстрые шаблоны",
            templates: TemplateStore.shared.quickTemplates,
            onBack: { [weak self] in self?.popToMainMenu() }
        )
    }

    private func showTemplates(
        title: String,
        templates: [Template],
        onBack: @escaping () -> Void
    ) {
        let tv = TemplatesView(
            title: title,
            templates: templates,
            insertText: insertText,
            deleteBackward: deleteBackward,
            clearAll: clearAll,
            nextKeyboard: nextKeyboard,
            onBack: onBack
        )
        templatesView = tv
        let from = categoriesView ?? mainMenuView
        transition(from: from, to: tv)
    }

    private func popToMainMenu() {
        let from: UIView = templatesView ?? categoriesView ?? mainMenuView
        categoriesView = nil
        templatesView  = nil
        transition(from: from, to: mainMenuView)
    }

    private func popToCategories() {
        guard let cv = categoriesView else {
            popToMainMenu()
            return
        }
        let from = templatesView ?? cv
        templatesView = nil
        transition(from: from, to: cv)
    }

    // MARK: - Transition

    private func transition(from: UIView, to: UIView) {
        guard from !== to else { return }

        to.translatesAutoresizingMaskIntoConstraints = false
        addSubview(to)
        NSLayoutConstraint.activate([
            to.topAnchor.constraint(equalTo: topAnchor),
            to.leadingAnchor.constraint(equalTo: leadingAnchor),
            to.trailingAnchor.constraint(equalTo: trailingAnchor),
            to.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve) {
            from.isHidden = true
            to.isHidden   = false
        } completion: { _ in
            if from !== self.mainMenuView {
                from.removeFromSuperview()
            } else {
                // Keep main menu in hierarchy but hidden
            }
        }
    }

    // MARK: - Actions

    @objc private func globeTapped() {
        nextKeyboard()
    }

    // MARK: - Helpers

    private func makeToolbarButton(image: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: image), for: .normal)
        btn.tintColor = .secondaryLabel
        return btn
    }

    private func makeEmptyLabel(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.textColor = .secondaryLabel
        lbl.font = .systemFont(ofSize: 14)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }
}
