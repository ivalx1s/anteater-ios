import SwiftUI
import SwiftPlus
import FoundationPlus
import Relux
import FeatureManagementModule
import ConnectionMonitor
import ReluxRouter
import Logger


@main @MainActor
struct Anteater: App {
	
	@StateObject private var reluxContainer = Anteater.reluxContainerInstance
	
	init() {
		Anteater.configureIoC()
	}
	
	var body: some Scene {
		WindowGroup {
			EntryPoint.ContentContainer()
				.passingObservableToEnvironment(fromStore: reluxContainer.relux.store)
				.task {
					await action {
						FeatureManagement.Business.Effect.obtainEnabledFeatures
					}
				}
				.task(priority: .low) {
					await action {
						ConnectionMonitor.SideEffect.startNetworkMonitor
					}
				}
				.onAppear { log("Anteater has been rendered") }
		}
	}
}


extension Anteater {
	private static func configureIoC() {
		IoC.Registry.registerModules(
			[
				Relux.self,
				FeatureManagement.self,
				ConnectionMonitor.self,
			]
		)
	}
}

extension Anteater {
	private static var reluxContainerInstance: ReluxContainer {
		.init(
			logger: IoC.get(type: (any Relux.Logger).self)!,
			modules: .resolvedModules,
			routers: [
				Relux.Navigation.ProjectingRouter<UI.Dashboard.Navigation.Page>(),
				Relux.Navigation.Router<UI.Profile.Navigation.Page>()
			]
		)
	}
}

extension [any Relux.Module] {
	static var resolvedModules: Self {
		return [
			IoC.get(type: (FeatureManagement.Module).self)!,
			IoC.get(type: (ConnectionMonitor.Module).self)!
		]
	}
}


extension View {
	@MainActor
	func passingObservableToEnvironment(fromStore store: Relux.Store) -> some View {
		var view: any View = self
		
		let routers = store
			.routers
			.values
			.map {
				$0 as Any
			}
		
		let uistates = store
			.uistates
			.values
			.map {
				$0 as Any
			}
		
		passToEnvironment(inView: &view, objects: routers + uistates)
		
		return AnyView(view)
	}
	
	
	@MainActor
	func passToEnvironment(inView view: inout any View, objects: [Any]) {
		for object in objects {
			if let observableObj = object as? (any ObservableObject) {
				debugPrint("[ReluxRootView] passing \(observableObj) as ObservableObject to SwiftUI environment")
				view = view.environmentObject(observableObj)
			}
			
			if #available(iOS 17, *) {
				if let observable = object as? (any Observable & AnyObject) {
					debugPrint("[ReluxRootView] passing \(observable) as Observable to SwiftUI environment")
					view = view.environment(observable)
				}
			}
		}
	}
}
