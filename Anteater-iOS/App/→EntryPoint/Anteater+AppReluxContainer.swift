import SwiftUI
import Relux
import FeatureManagementModule
import ConnectionMonitor

@MainActor
protocol ReluxContainer: AnyObject {
	var relux: Relux! { get }
	init(
		reluxModules: [any Relux.Module],
		states: [any ReluxState],
		sagas: [any ReluxSaga],
		routers: [any Relux.Navigation.RouterProtocol]
	) async
}



final class AppReluxContainer: ReluxContainer, ObservableObject {
	 private(set) var relux: Relux!
	
	init(
		reluxModules: [any Relux.Module],
		states: [any ReluxState],
		sagas: [any ReluxSaga],
		routers: [any Relux.Navigation.RouterProtocol]
	) async {
		await initRelux()
		await registerModules(reluxModules)
		await registerStates(states)
		await registerSagas(sagas)
		await registerRouters(routers)
	}
	
	
	@MainActor
	private func initRelux() async {
		relux = .init(appStore: .init(), rootSaga: .init())
	}
	
	@MainActor
	private func registerModules(_ modules: [any Relux.Module]) async {
		relux = await relux.register(modules)
	}
	
	@MainActor
	private func registerStates(_ states: [any ReluxState]) async {
		for state in states {
			await relux.appStore.connectState(state: state)
		}
	}
	
	@MainActor
	private func registerRouters(_ routers: [any Relux.Navigation.RouterProtocol]) async {
		for router in routers {
			await relux.appStore.connectRouter(router)
		}
		
	}
	
	@MainActor
	private func registerSagas(_ sagas: [any ReluxSaga]) async {
		for saga in sagas {
			await relux.rootSaga.add(saga: saga)
		}
	}
}
