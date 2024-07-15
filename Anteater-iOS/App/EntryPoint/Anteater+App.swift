import SwiftUI
import SwiftPlus
import FoundationPlus
import Logger
import Relux
import FeatureManagementModule
import ConnectionMonitor

@main
struct Anteater: App {
	static private(set) var appStore: Relux.Store!
	static private(set) var rootSaga: Relux.RootSaga!
	
	private var relux: Relux
	
	init() {
		Anteater.configureIoC()
		
		relux =
			.init(appStore: .init(), rootSaga: .init())
			.register(
				FeatureManagement.Module(
					store: FeatureManagement.Data.Store(keychain: .init()),
					allFeatures: []
				)
			)
			.register(
				ConnectionMonitor.Module(
					networkService: IoC.get(type: ConnectionMonitor.NetworkMonitoring.self)!,
					viewStates: [],
					viewStateObservables: [IoC.get(type: ConnectionMonitor.UI.State.self)!]
				)
			)
		
		configureRootSaga()
		Anteater.configureAppStore()
		
		Task {
			await action {
				FeatureManagement.Business.Effect.obtainEnabledFeatures
			} label: {
				"obtainEnabledFeatures"
			}
		}
		
		Task {
			await action {
				ConnectionMonitor.SideEffect.startNetworkMonitor
			} label: {
				"startNetworkMonitor"
			}
		}
	}
	
	var body: some Scene {
		WindowGroup {
			EntryPoint.ContentContainer()
				.environmentObject(relux.appStore.getViewState(FeatureManagement.UI.ViewState.self))
				.environment(relux.appStore.getViewState(ConnectionMonitor.UI.State.self))
		}
	}
	
	@MainActor
	private static func configureIoC() {
		IoC.Registry.registerType(ConnectionMonitor.self)
		IoC.initialize(with: IoC.Registry.build)
	}
	
	private func configureRootSaga() {
		let rootSaga = relux.rootSaga
		rootSaga.add(saga: IoC.get(type: ConnectionMonitor.Saga.self)!)
	}
	
	@MainActor
	static private func configureAppStore() {
		self.appStore = .init()
		
		// business states
		appStore.connectState(state: IoC.get(type: ConnectionMonitor.Business.State.self)!)
		
		// view states
		appStore.connectViewStateObservable(state: IoC.get(type: ConnectionMonitor.UI.State.self)!)
	}

}

extension View {
	func debugViewType() -> Self {
		print(Mirror(reflecting: self).subjectType)
		return self
	}
}


