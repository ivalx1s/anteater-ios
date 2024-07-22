import Swinject

extension IoC {
	actor Registry {
		private static var registeredModules: [any Module.Type] = []
		
		static func registerModule(_ type: any Module.Type) {
			registeredModules.append(type)
		}
		
		@MainActor
		static var build: Container {
			let container = Container()
			for module in registeredModules {
				module.register(in: container)
			}
			registeredModules = []
			return container
		}
	}
}

extension IoC.Registry {
	protocol Module {
		
		@MainActor
		static func register(in container: Container)
	}
}
