import UIKit

final class KeyboardViewController: UIInputViewController {

    private var rootView: KeyboardRootView!

    override func viewDidLoad() {
        super.viewDidLoad()

        TemplateStore.shared.load()

        rootView = KeyboardRootView(
            insertText: { [weak self] text in
                self?.textDocumentProxy.insertText(text)
            },
            deleteBackward: { [weak self] in
                guard let proxy = self?.textDocumentProxy else { return }
                if proxy.documentContextBeforeInput != nil {
                    proxy.deleteBackward()
                }
            },
            clearAll: { [weak self] in
                guard let proxy = self?.textDocumentProxy else { return }
                while proxy.documentContextBeforeInput != nil {
                    proxy.deleteBackward()
                }
            },
            nextKeyboard: { [weak self] in
                self?.advanceToNextInputMode()
            }
        )

        view.addSubview(rootView)
        rootView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rootView.topAnchor.constraint(equalTo: view.topAnchor),
            rootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // Fallback height — overridden with required priority in viewDidAppear
        let fallback = view.heightAnchor.constraint(equalToConstant: 320)
        fallback.priority = .defaultHigh
        fallback.isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TemplateStore.shared.load()
        rootView.reload()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Required-priority constraint applied after layout settles to prevent size jumps
        view.heightAnchor.constraint(equalToConstant: 320).isActive = true
    }
}
