import Swinject

extension IoC {
	@MainActor
	enum Registry {
		private static var registeredTypes: [any Module.Type] = []
		
		static func registerType(_ type: any Module.Type) {
			registeredTypes.append(type)
		}
		
		static var build: Container {
			let container = Container()
			for type in registeredTypes {
				type.register(in: container)
			}
			registeredTypes = []
			return container
		}
	}
}

extension IoC.Registry {
	protocol Module {
		@MainActor static func register(in container: Container)
	}
}
