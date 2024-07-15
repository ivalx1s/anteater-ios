import FeatureManagementModule
import Swinject

extension FeatureManagement: IoC.Registry.Module {
	
	static func register(in container: Swinject.Container) {
		container.register(IFeatureManagementStore.self) { _ -> IFeatureManagementStore in
			FeatureManagement.Data.Store(
				keychain: .init()
			)
		}
		.inObjectScope(.container)
		
		container.register(FeatureManagement.Module.self) { resolver -> FeatureManagement.Module in
			FeatureManagement.Module(
				store: resolver.resolve(IFeatureManagementStore.self)!,
				allFeatures: FeatureManagement.Business.Model.AnteaterFeature
					.allCases
					.map { .init(key: $0.rawValue, label: $0.label) }
			)
		}
		.inObjectScope(.container)
	}
	
}
