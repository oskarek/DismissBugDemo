import ComposableArchitecture
import SwiftUI

// MARK: Reducer

@Reducer
struct FeatureB: Reducer {
	@ObservableState
	struct State: Equatable {
		@Presents var featureC: FeatureC.State?
	}

	enum Action {
		case closeButtonTapped
		case featureC(PresentationAction<FeatureC.Action>)
		case presentButtonTapped
	}

	@Dependency(\.dismiss) var dismiss

	var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .closeButtonTapped:
				return .run { _ in await dismiss() }
			case .featureC:
				return .none
			case .presentButtonTapped:
				state.featureC = .init()
				return .none
			}
		}
		.ifLet(\.$featureC, action: \.featureC) {
			FeatureC()
		}
	}
}

// MARK: UI

final class FeatureBViewController: UIViewController {
	let store: StoreOf<FeatureB>

	init(store: StoreOf<FeatureB>) {
		self.store = store
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .red

		let presentButton = UIButton(type: .system)
		presentButton.setTitle("Present Feature C", for: .normal)
		presentButton.addTarget(self, action: #selector(presentButtonTapped), for: .touchUpInside)
		presentButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
		presentButton.center = view.center
		view.addSubview(presentButton)

		let closeButton = UIButton(type: .system)
		closeButton.setTitle("Close", for: .normal)
		closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
		closeButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
		closeButton.center.x = view.center.x
		closeButton.center.y = presentButton.center.y + 50
		view.addSubview(closeButton)
	}

	var viewWillAppearCalled = false
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard !viewWillAppearCalled else { return }
		viewWillAppearCalled = true
		setupObserve()
	}

	private func setupObserve() {
		var featureCViewController: FeatureCViewController?
		observe { [weak self] in
			guard let self else { return }
			if
				let featureCStore = store.scope(state: \.featureC, action: \.featureC.presented),
				featureCViewController == nil
			{
				featureCViewController = FeatureCViewController(store: featureCStore)
				featureCViewController?.modalPresentationStyle = .fullScreen
				present(featureCViewController!, animated: true, completion: nil)
			} else if store.featureC == nil, featureCViewController != nil {
				dismiss(animated: true)
				featureCViewController = nil
			}
		}
	}

	@objc func presentButtonTapped() {
		store.send(.presentButtonTapped)
	}

	@objc func closeButtonTapped() {
		store.send(.closeButtonTapped)
	}
}
