import UIKit

final class CategoriesView: UIView {

    // MARK: - Callbacks

    private let onBack:           () -> Void
    private let onSelectCategory: (TemplateCategory) -> Void
    private let nextKeyboard:     () -> Void

    // MARK: - UI

    private let toolbar   = UIView()
    private let scrollView = UIScrollView()
    private let stackView  = UIStackView()
    private let emptyLabel = UILabel()

    // MARK: - Init

    init(
        categories: [TemplateCategory],
        onBack: @escaping () -> Void,
        onSelectCategory: @escaping (TemplateCategory) -> Void,
        nextKeyboard: @escaping () -> Void
    ) {
        self.onBack           = onBack
        self.onSelectCategory = onSelectCategory
        self.nextKeyboard     = nextKeyboard
        super.init(frame: .zero)
        backgroundColor = .systemGroupedBackground
        setupToolbar()
        setupScrollView()
        loadCategories(categories)
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

        // Separator
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

        // Back button
        let backBtn = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.left")
        config.title = "Назад"
        config.imagePadding = 4
        config.baseForegroundColor = .label
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs; a.font = UIFont.systemFont(ofSize: 15, weight: .semibold); return a
        }
        backBtn.configuration = config
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        toolbar.addSubview(backBtn)
        NSLayoutConstraint.activate([
            backBtn.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 6),
            backBtn.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
        ])

        // Globe button
        let globeBtn = UIButton(type: .system)
        globeBtn.setImage(UIImage(systemName: "globe"), for: .normal)
        globeBtn.tintColor = .secondaryLabel
        globeBtn.addTarget(self, action: #selector(globeTapped), for: .touchUpInside)
        globeBtn.translatesAutoresizingMaskIntoConstraints = false
        toolbar.addSubview(globeBtn)
        NSLayoutConstraint.activate([
            globeBtn.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -10),
            globeBtn.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
            globeBtn.widthAnchor.constraint(equalToConstant: 36),
            globeBtn.heightAnchor.constraint(equalToConstant: 36),
        ])
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

        stackView.axis      = .vertical
        stackView.spacing   = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -8),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -24),
        ])

        // Empty label
        emptyLabel.text          = "Нет категорий. Добавьте их в приложении."
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

    private func loadCategories(_ categories: [TemplateCategory]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if categories.isEmpty {
            emptyLabel.isHidden = false
            scrollView.isHidden = true
            return
        }

        emptyLabel.isHidden = true
        scrollView.isHidden = false

        for category in categories {
            let btn = makeCategoryButton(category: category)
            stackView.addArrangedSubview(btn)
        }
    }

    private func makeCategoryButton(category: TemplateCategory) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = category.name
        config.baseForegroundColor = .label
        config.baseBackgroundColor = .secondarySystemGroupedBackground
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs; a.font = UIFont.systemFont(ofSize: 15, weight: .medium); return a
        }

        let btn = UIButton(configuration: config)
        btn.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true

        // Store category id in accessibilityIdentifier for retrieval in action
        btn.accessibilityIdentifier = category.id.uuidString
        btn.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
        return btn
    }

    // MARK: - Actions

    @objc private func backTapped() {
        onBack()
    }

    @objc private func globeTapped() {
        nextKeyboard()
    }

    @objc private func categoryTapped(_ sender: UIButton) {
        guard
            let idStr = sender.accessibilityIdentifier,
            let id = UUID(uuidString: idStr),
            let category = TemplateStore.shared.categories.first(where: { $0.id == id })
        else { return }
        onSelectCategory(category)
    }
}
