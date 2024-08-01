import Swinject

extension IoC {
	actor Registry {
		private static var registeredModules: [any Module.Type] = []
		
		@MainActor
		static func registerModules(_ modules: [any Module.Type]) {
			registeredModules.append(contentsOf: modules)
			IoC.initialize(with: IoC.Registry.build)
		}
		
		@MainActor
		static var build: Container {
			let container = Container()
			for module in registeredModules {
				module.register(in: container)
			}
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
