import UIKit

final class TemplatesView: UIView {

    // MARK: - Callbacks

    private let insertText:     (String) -> Void
    private let deleteBackward: () -> Void
    private let clearAll:       () -> Void
    private let nextKeyboard:   () -> Void
    private let onBack:         () -> Void

    // MARK: - State

    private let screenTitle: String
    private var allTemplates: [Template] = []

    // Rule 4 — typed button cache; never cast arrangedSubviews
    private var templateButtons: [UIButton] = []

    // MARK: - UI

    private let toolbar        = UIView()
    private let searchField    = UITextField()
    private let scrollView     = UIScrollView()
    private let stackView      = UIStackView()
    private let emptyLabel     = UILabel()

    // MARK: - Init

    init(
        title: String,
        templates: [Template],
        insertText: @escaping (String) -> Void,
        deleteBackward: @escaping () -> Void,
        clearAll: @escaping () -> Void,
        nextKeyboard: @escaping () -> Void,
        onBack: @escaping () -> Void
    ) {
        self.screenTitle    = title
        self.insertText     = insertText
        self.deleteBackward = deleteBackward
        self.clearAll       = clearAll
        self.nextKeyboard   = nextKeyboard
        self.onBack         = onBack
        super.init(frame: .zero)
        backgroundColor = .systemGroupedBackground
        setupToolbar()
        setupScrollView()
        loadTemplates(templates)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    // MARK: - Toolbar

    private func setupToolbar() {
        toolbar.backgroundColor = .systemGroupedBackground
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(toolbar)
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44),
        ])

        // Bottom separator
        let sep = UIView()
        sep.backgroundColor = .separator
        sep.translatesAutoresizingMaskIntoConstraints = false
        toolbar.addSubview(sep)
        NSLayoutConstraint.activate([
            sep.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor),
            sep.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor),
            sep.heightAnchor.constraint(equalToConstant: 0.5),
        ])

        // ← Назад
        let backBtn = UIButton(type: .system)
        var backConfig = UIButton.Configuration.plain()
        backConfig.image = UIImage(systemName: "chevron.left")
        backConfig.title = "Назад"
        backConfig.imagePadding = 4
        backConfig.baseForegroundColor = .label
        backConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs; a.font = UIFont.systemFont(ofSize: 15, weight: .semibold); return a
        }
        backBtn.configuration = backConfig
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.setContentHuggingPriority(.required, for: .horizontal)
        toolbar.addSubview(backBtn)

        // Search field
        searchField.placeholder     = "Поиск…"
        searchField.font            = .systemFont(ofSize: 14)
        searchField.borderStyle     = .none
        searchField.backgroundColor = .tertiarySystemGroupedBackground
        searchField.layer.cornerRadius = 8
        searchField.layer.masksToBounds = true
        searchField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 1))
        searchField.leftViewMode = .always
        searchField.clearButtonMode = .whileEditing
        searchField.returnKeyType = .done
        searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)
        searchField.translatesAutoresizingMaskIntoConstraints = false

        // ⌫ Delete character
        let deleteBtn = makeIconButton(systemName: "delete.backward")
        deleteBtn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        // 🗑 Clear all
        let clearBtn = makeIconButton(systemName: "trash")
        clearBtn.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)

        // 🌐 Next keyboard
        let globeBtn = makeIconButton(systemName: "globe")
        globeBtn.addTarget(self, action: #selector(globeTapped), for: .touchUpInside)

        let rightStack = UIStackView(arrangedSubviews: [deleteBtn, clearBtn, globeBtn])
        rightStack.axis    = .horizontal
        rightStack.spacing = 2
        rightStack.translatesAutoresizingMaskIntoConstraints = false

        for v in [backBtn, searchField, rightStack] {
            toolbar.addSubview(v)
        }

        NSLayoutConstraint.activate([
            backBtn.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 6),
            backBtn.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),

            rightStack.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -6),
            rightStack.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),

            searchField.leadingAnchor.constraint(equalTo: backBtn.trailingAnchor, constant: 6),
            searchField.trailingAnchor.constraint(equalTo: rightStack.leadingAnchor, constant: -6),
            searchField.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
            searchField.heightAnchor.constraint(equalToConstant: 30),
        ])
    }

    private func makeIconButton(systemName: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: systemName), for: .normal)
        btn.tintColor = .secondaryLabel
        btn.widthAnchor.constraint(equalToConstant: 34).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 34).isActive = true
        return btn
    }

    // MARK: - Scroll View

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        stackView.axis    = .vertical
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -8),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -24),
        ])

        // Empty state label
        emptyLabel.text          = "Нет шаблонов. Добавьте их в приложении."
        emptyLabel.textColor     = .secondaryLabel
        emptyLabel.font          = .systemFont(ofSize: 14)
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.isHidden      = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            emptyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    }

    // MARK: - Data

    /// Builds all buttons once. Search only toggles isHidden — stack is never rebuilt.
    func loadTemplates(_ templates: [Template]) {
        allTemplates = templates

        // Clear previous buttons
        templateButtons.removeAll()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if templates.isEmpty {
            emptyLabel.isHidden = false
            scrollView.isHidden = true
            return
        }

        emptyLabel.isHidden = true
        scrollView.isHidden = false

        // Rule 4 — build once, cache in typed array
        for template in templates {
            let btn = makeTemplateButton(template)
            templateButtons.append(btn)
            stackView.addArrangedSubview(btn)
        }
    }

    private func makeTemplateButton(_ template: Template) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = template.text
        config.baseForegroundColor = .label
        config.baseBackgroundColor = .secondarySystemGroupedBackground
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 14)
            let ps = NSMutableParagraphStyle()
            ps.alignment = .left
            a.paragraphStyle = ps
            return a
        }
        config.titleAlignment = .leading

        let btn = UIButton(configuration: config)
        btn.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        btn.accessibilityIdentifier = template.id.uuidString
        btn.addTarget(self, action: #selector(templateTapped(_:)), for: .touchUpInside)
        return btn
    }

    // MARK: - Search (Rule 1 — only toggle isHidden, never rebuild)

    @objc private func searchChanged() {
        let query = searchField.text ?? ""
        applySearch(query)
    }

    private func applySearch(_ query: String) {
        // Rule 4 — iterate typed array, no casting
        for btn in templateButtons {
            let text = btn.configuration?.title ?? ""
            btn.isHidden = !query.isEmpty && !text.localizedCaseInsensitiveContains(query)
        }

        // Show "no results" label if all buttons are hidden
        let allHidden = !templateButtons.isEmpty && templateButtons.allSatisfy { $0.isHidden }
        emptyLabel.text    = query.isEmpty ? "Нет шаблонов. Добавьте их в приложении." : "Нет результатов."
        emptyLabel.isHidden = !(allTemplates.isEmpty || allHidden)
    }

    // MARK: - Actions

    @objc private func templateTapped(_ sender: UIButton) {
        guard
            let idStr = sender.accessibilityIdentifier,
            let id = UUID(uuidString: idStr),
            let template = allTemplates.first(where: { $0.id == id })
        else { return }
        // Rule 2 — always append trailing space
        insertText(template.text + " ")
    }

    @objc private func backTapped() {
        searchField.resignFirstResponder()
        onBack()
    }

    @objc private func deleteTapped() {
        // Rule 3 — guard against empty field
        deleteBackward()
    }

    @objc private func clearTapped() {
        clearAll()
    }

    @objc private func globeTapped() {
        nextKeyboard()
    }
}
