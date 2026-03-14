import UIKit
import SwiftUI

final class KeyboardViewController: UIInputViewController {

    private let store = KeyboardTemplateStore()
    private var hostingController: UIHostingController<KeyboardView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        let keyboardView = KeyboardView(
            store: store,
            insertText: { [weak self] text in
                self?.textDocumentProxy.insertText(text)
            },
            nextKeyboard: { [weak self] in
                self?.advanceToNextInputMode()
            },
            deleteBackward: { [weak self] in
                self?.textDocumentProxy.deleteBackward()
            },
            selectAll: { [weak self] in
                guard let proxy = self?.textDocumentProxy else { return }
                let before = proxy.documentContextBeforeInput ?? ""
                let after  = proxy.documentContextAfterInput  ?? ""
                proxy.adjustTextPosition(byCharacterOffset: after.count)
                let total = before.count + after.count
                for _ in 0..<total { proxy.deleteBackward() }
            }
        )

        let hc = UIHostingController(rootView: keyboardView)
        hostingController = hc

        addChild(hc)
        view.addSubview(hc.view)
        hc.didMove(toParent: self)

        hc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hc.view.topAnchor.constraint(equalTo: view.topAnchor),
            hc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // Explicit height so the system knows how tall the keyboard is.
        let heightConstraint = view.heightAnchor.constraint(equalToConstant: 260)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
    }

    // Reload templates every time the keyboard is raised so edits
    // made in the main app are always reflected immediately.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.load()
    }
}
