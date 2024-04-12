import ComposableArchitecture
import SwiftUI

// MARK: Reducer

@Reducer
struct FeatureA: Reducer {
	@ObservableState
	struct State: Equatable {
		@Presents var featureB: FeatureB.State?
	}

	enum Action {
		case featureB(PresentationAction<FeatureB.Action>)
		case presentButtonTapped
	}

	@Dependency(\.dismiss) var dismiss

	var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .featureB:
				return .none
			case .presentButtonTapped:
				state.featureB = .init()
				return .none
			}
		}
		.ifLet(\.$featureB, action: \.featureB) {
			FeatureB()
		}
	}
}

// MARK: UI

final class FeatureAViewController: UIViewController {
	let store: StoreOf<FeatureA>

	init(store: StoreOf<FeatureA>) {
		self.store = store
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .green

		let button = UIButton(type: .system)
		button.setTitle("Present Feature B", for: .normal)
		button.addTarget(self, action: #selector(presentButtonTapped), for: .touchUpInside)
		button.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
		button.center = view.center
		view.addSubview(button)

		Task.detached { [weak self] in
			await self?.setupObserve()
		}
	}

	@MainActor
	private func setupObserve() {
		var featureBVC: FeatureBViewController?
		observe { [weak self] in
			guard let self else { return }
			if
				let featureBStore = store.scope(state: \.featureB, action: \.featureB.presented),
				featureBVC == nil
			{
				featureBVC = FeatureBViewController(store: featureBStore)
				featureBVC?.modalPresentationStyle = .fullScreen
				present(featureBVC!, animated: true, completion: nil)
			} else if store.featureB == nil, featureBVC != nil {
				dismiss(animated: true)
				featureBVC = nil
			}
		}
	}

	@objc func presentButtonTapped() {
		store.send(.presentButtonTapped)
	}
}
