import ComposableArchitecture
import SwiftUI

@main
struct DismissBugDemoApp: App {
	let store = Store(initialState: FeatureA.State()) {
		FeatureA()._printChanges()
	}

	var body: some Scene {
		WindowGroup {
			MyViewControllerRepresentable(
				viewController: FeatureAViewController(store: store)
			)
			.ignoresSafeArea()
		}
	}
}

struct MyViewControllerRepresentable: UIViewControllerRepresentable {
	let viewController: UIViewController

	func makeUIViewController(context _: Context) -> UIViewController { viewController }

	func updateUIViewController(_: UIViewController, context _: Context) {}
}
