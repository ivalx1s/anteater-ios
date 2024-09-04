import SwiftUI
import SwiftPlus
import FoundationPlus
import Relux
import ReluxFeatureManagement
import ConnectionMonitor
import ReluxRouter
import Logger

@_exported import SwiftUIRelux


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
