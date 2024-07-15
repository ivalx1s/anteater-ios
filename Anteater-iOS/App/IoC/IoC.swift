import Swinject


enum IoC {
	nonisolated(unsafe) private static var container: Swinject.Container?
	
	
	public static func initialize(with container: Swinject.Container) {
		self.container = container
	}
	
	public static func deInitialize() {
		self.container = nil
	}
	
	public static func get<Service>(type: Service.Type, name: String? = nil) -> Service? {
		if let name = name {
			return self.container?.synchronize().resolve(type, name: name)
		}
		return self.container?.synchronize().resolve(type)
	}
}
