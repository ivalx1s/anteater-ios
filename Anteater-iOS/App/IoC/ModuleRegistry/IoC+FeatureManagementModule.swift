import FeatureManagementModule
import Swinject

extension FeatureManagement.UI.ViewState {
	public var __fullTypeName: String {
		"FeatureManagement.UI.ViewState"
	}
}

extension FeatureManagement: IoC.Registry.Module {
	
	@MainActor
	static func register(in container: Swinject.Container) {
	
		container.register((any IFeatureManagementStore).self) { _ -> (any IFeatureManagementStore) in
			FeatureManagement.Data.Store(
				keychain: .init()
			)
		}
		.inObjectScope(.container)
		
		container.register((any IFeatureManagementService).self) { resolver -> (any IFeatureManagementService) in
			FeatureManagement.Business.Service(
				store: resolver.resolve((any IFeatureManagementStore).self)!
			)
		}
		.inObjectScope(.container)
		
		container.register((any IFeatureManagementSaga).self) { resolver -> (any IFeatureManagementSaga) in
			FeatureManagement.Business.Saga(
				svc: resolver.resolve((any IFeatureManagementService).self)!
			)
		}
		.inObjectScope(.container)
		
		container.register(FeatureManagement.Business.State.self) { resolver -> FeatureManagement.Business.State in
			FeatureManagement.Business.State()
		}
		.inObjectScope(.container)
		
		container.register([Business.Model.Feature].self) { resolver -> [Business.Model.Feature] in
			FeatureManagement.Business.Model.AnteaterFeature
				.allCases
				.map { .init(key: $0.rawValue, label: $0.label) }
		}
		.inObjectScope(.container)
		
		container.register(FeatureManagement.UI.ViewState.self) { resolver -> FeatureManagement.UI.ViewState in
			FeatureManagement.UI.ViewState(
				featureState: resolver.resolve(FeatureManagement.Business.State.self)!,
				allFeatures: resolver.resolve([Business.Model.Feature].self)!
			)
		}
		.inObjectScope(.container)
		
		container.register(FeatureManagement.Module.self) { resolver -> FeatureManagement.Module in
			FeatureManagement.Module(
				sagas: [resolver.resolve((any IFeatureManagementSaga).self)!],
				serviceFacade: resolver.resolve((any IFeatureManagementService).self)!,
				states: [resolver.resolve(FeatureManagement.Business.State.self)!],
				uistates: [resolver.resolve(FeatureManagement.UI.ViewState.self)!],
				store: resolver.resolve((any IFeatureManagementStore).self)!
			)
		}
		.inObjectScope(.container)
	}
	
}
