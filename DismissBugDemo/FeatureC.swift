import ComposableArchitecture
import SwiftUI

// MARK: Reducer

@Reducer
struct FeatureC: Reducer {
	@ObservableState
	struct State: Equatable {}

	enum Action {
		case closeButtonTapped
		case viewWillInitiallyAppear
	}

	@Dependency(\.dismiss) var dismiss

	var body: some ReducerOf<Self> {
		Reduce { _, action in
			switch action {
			case .closeButtonTapped:
				return .run { _ in await dismiss() }
			case .viewWillInitiallyAppear:
				return .none
			}
		}
	}
}

// MARK: UI

final class FeatureCViewController: UIViewController {
	let store: StoreOf<FeatureC>

	init(store: StoreOf<FeatureC>) {
		self.store = store
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .yellow

		let closeButton = UIButton(type: .system)
		closeButton.setTitle("Close", for: .normal)
		closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
		closeButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
		closeButton.center = view.center
		view.addSubview(closeButton)
	}

	var viewWillAppearCalled = false
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard !viewWillAppearCalled else { return }
		viewWillAppearCalled = true
		store.send(.viewWillInitiallyAppear)
	}

	@objc func closeButtonTapped() {
		store.send(.closeButtonTapped)
	}
}
