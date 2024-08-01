import Swinject
import Relux
import Logger

extension Relux: IoC.Registry.Module {
	
	@MainActor
	static func register(in container: Swinject.Container) {
		
		container.register((any Relux.Logger).self) { resolver -> (any Relux.Logger) in
			Relux.ReluxLogger()
		}
		.inObjectScope(.container)
	
	}
}
