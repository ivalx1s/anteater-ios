import Swinject
import ConnectionMonitor
import Observation
import FeatureManagementModule

extension ConnectionMonitor: IoC.Registry.Module {
	
	@MainActor
	static func register(in container: Swinject.Container) {
		
		container.register(ConnectionMonitor.Module.self) { resolver -> ConnectionMonitor.Module in
			ConnectionMonitor.Module(
				sagas: [IoC.get(type: (any ConnectionMonitor.Saga).self)!],
				serviceFacade: IoC.get(type: (any ConnectionMonitor.ServiceFacade).self)!,
				networkService: IoC.get(type: (any ConnectionMonitor.NetworkMonitoring).self)!,
				states: [
					IoC.get(type: (ConnectionMonitor.Business.State).self)!
				],
				uistates: [
					resolver.resolve(ConnectionMonitor.UI.State.self)!
				]
			)
		}
		.inObjectScope(.container)
		
		
		container.register(ConnectionMonitor.UI.State.self) { resolver -> ConnectionMonitor.UI.State in
			ConnectionMonitor.UI.State(
				connectionMonitorBusinessState: resolver.resolve(ConnectionMonitor.Business.State.self)!
			)
		}
		.inObjectScope(.container)
		
		container.register(ConnectionMonitor.Business.State.self) { resolver -> ConnectionMonitor.Business.State in
			ConnectionMonitor.Business.State()
		}
		.inObjectScope(.container)
	
		
		container.register((any ConnectionMonitor.ServiceFacade).self) { resolver -> (any ConnectionMonitor.ServiceFacade) in
			ConnectionMonitor.Service(
				networkService: resolver.resolve((any ConnectionMonitor.NetworkMonitoring).self)!
			)
		}
		.inObjectScope(.container)
		
		container.register((any ConnectionMonitor.NetworkMonitoring).self) { resolver -> (any ConnectionMonitor.NetworkMonitoring) in
			ConnectionMonitor.NetworkService()
		}
		.inObjectScope(.container)
		
		container.register((any ConnectionMonitor.Saga).self) { resolver -> (any ConnectionMonitor.Saga) in
			ConnectionMonitor.ConnectionMonitorSaga(
				service: resolver.resolve((any ConnectionMonitor.ServiceFacade).self)!
			)
		}
		.inObjectScope(.container)
		
	}
}
