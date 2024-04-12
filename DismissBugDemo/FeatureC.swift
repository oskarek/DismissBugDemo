import ComposableArchitecture
import SwiftUI

// MARK: Reducer

@Reducer
struct FeatureC: Reducer {
	@ObservableState
	struct State: Equatable {}

	enum Action {
		case closeButtonTapped
		case viewDidLoad
	}

	@Dependency(\.dismiss) var dismiss

	var body: some ReducerOf<Self> {
		Reduce { _, action in
			switch action {
			case .closeButtonTapped:
				return .run { _ in await dismiss() }
			case .viewDidLoad:
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
		Task.detached { [weak self] in
			await self?.sendViewDidLoadAction()
		}

		let closeButton = UIButton(type: .system)
		closeButton.setTitle("Close", for: .normal)
		closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
		closeButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
		closeButton.center = view.center
		view.addSubview(closeButton)
	}

	@MainActor
	private func sendViewDidLoadAction() {
		store.send(.viewDidLoad)
	}

	@objc func closeButtonTapped() {
		store.send(.closeButtonTapped)
	}
}
