import Swinject
import ConnectionMonitor
import Observation


extension ConnectionMonitor: IoC.Registry.Module {
	static func register(in container: Swinject.Container) {
		container.register(ConnectionMonitor.Business.State.self) { resolver -> ConnectionMonitor.Business.State in
			ConnectionMonitor.Business.State()
		}
		.inObjectScope(.container)
		
		container.register(ConnectionMonitor.UI.State.self) { resolver -> ConnectionMonitor.UI.State in
			ConnectionMonitor.UI.State(
				connectionMonitorBusinessState: resolver.resolve(ConnectionMonitor.Business.State.self)!
			)
		}
		.inObjectScope(.container)
	
		
		container.register(ConnectionMonitor.ServiceFacade.self) { resolver -> ConnectionMonitor.ServiceFacade in
			ConnectionMonitor.Service(
				networkService: resolver.resolve(ConnectionMonitor.NetworkMonitoring.self)!
			)
		}
		.inObjectScope(.container)
		
		container.register(ConnectionMonitor.NetworkMonitoring.self) { resolver -> ConnectionMonitor.NetworkMonitoring in
			ConnectionMonitor.NetworkService()
		}
		.inObjectScope(.container)
		
		container.register(ConnectionMonitor.Saga.self) { resolver -> ConnectionMonitor.Saga in
			ConnectionMonitor.ConnectionMonitorSaga(
				service: resolver.resolve(ConnectionMonitor.ServiceFacade.self)!
			)
		}
		.inObjectScope(.container)
		
	}
}
