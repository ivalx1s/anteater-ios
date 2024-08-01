import SwiftUI
import Relux
import FeatureManagementModule
import ConnectionMonitor

@MainActor
final class ReluxContainer: ObservableObject {
	 private(set) var relux: Relux!
	
	init(
		logger: (any Relux.Logger),
		modules: [any Relux.Module],
		routers: [any Relux.Navigation.RouterProtocol]
	) {
		initRelux(withLogger: logger)
		registerModules(modules)
		registerRouters(routers)
	}
	
	
	@MainActor
	private func initRelux(withLogger logger: (any Relux.Logger)) {
		relux = .init(
			logger: logger,
			appStore: .init(),
			rootSaga: .init()
		)
	}
	
	@MainActor
	private func registerModules(_ modules: [any Relux.Module]) {
		relux = relux.register(modules)
	}
	
	@MainActor
	private func registerRouters(_ routers: [any Relux.Navigation.RouterProtocol]) {
		for router in routers {
			relux.store.connectRouter(router: router)
		}
		
	}
}
