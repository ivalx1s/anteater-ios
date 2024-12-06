import ReluxFeatureManagement
import Swinject

extension FeatureManagement: IoC.Registry.Module {
	
	@MainActor
	static func register(in container: Swinject.Container) {
	
        container.register((any FeatureManagement.Data.IStore).self) { _ -> (any FeatureManagement.Data.IStore) in
			FeatureManagement.Data.Store(
				keychain: .init()
			)
		}
		.inObjectScope(.container)
		
		container.register([Business.Model.Feature].self) { resolver -> [Business.Model.Feature] in
			FeatureManagement.Business.Model.AnteaterFeature
				.allCases
				.map { .init(key: $0.rawValue, label: $0.label) }
		}
		.inObjectScope(.container)
		
		container.register(FeatureManagement.Module.self) { resolver -> FeatureManagement.Module in
			FeatureManagement.Module(
                store: resolver.resolve((any FeatureManagement.Data.IStore).self)!,
                allFeatures: resolver.resolve([Business.Model.Feature].self)!
			)
		}
		.inObjectScope(.container)
	}
	
}
