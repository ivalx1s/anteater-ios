import SwiftUI
import Relux

struct ReluxRootView<Content: View & Sendable, Container: ReluxContainer>: View {
	@ViewBuilder private let content: (Container) async -> Content
	@Relux.ActionsBuilder private let _actions: @Sendable () -> [any ReluxAction]
	@Relux.ModulesBuilder private let modules:  @Sendable () -> [any Relux.Module]
	@Relux.SagasBuilder  private let sagas:    @Sendable () -> [any ReluxSaga]
	@Relux.StatesBuilder private let states:   @Sendable () -> [any ReluxState]
	@Relux.Navigation.RoutersBuilder private let routers:  @MainActor @Sendable () -> [any Relux.Navigation.RouterProtocol]
	
	init(
		@ViewBuilder content: @escaping (Container) async -> Content,
		@Relux.ModulesBuilder modules: @escaping @Sendable () -> [any Relux.Module],
		@Relux.StatesBuilder states: @escaping @Sendable () -> [any ReluxState],
		@Relux.SagasBuilder sagas:   @escaping @Sendable () -> [any ReluxSaga],
		@Relux.ActionsBuilder actions: @escaping @Sendable () -> [any ReluxAction],
		@Relux.Navigation.RoutersBuilder routers: @MainActor @escaping @Sendable () -> [any Relux.Navigation.RouterProtocol]
	) {
		self.content = content
		self.states = states
		self.modules = modules
		self.sagas = sagas
		self.routers = routers
		self._actions = actions
	}
	
	var body: some View {
		AsyncContentView(
			content: content,
			states: states,
			modules: modules,
			sagas: sagas,
			actions: _actions,
			routers: routers
		)
	}
}

private struct AsyncContentView<Content: View & Sendable, Container: ReluxContainer>: View {
	@ViewBuilder private let content: (Container) async -> Content
	@Relux.ModulesBuilder private let modules:  @Sendable  () -> [any Relux.Module]
	@Relux.StatesBuilder private let states:   @Sendable () -> [any ReluxState]
	@Relux.SagasBuilder private let sagas:   @Sendable () -> [any ReluxSaga]
	@Relux.ActionsBuilder private let _actions: @Sendable () -> [any ReluxAction]
	@Relux.Navigation.RoutersBuilder private let routers: @MainActor @Sendable () -> [any Relux.Navigation.RouterProtocol]
	
	@State private var contentView: AnyView?
	
	init(
		content: @escaping (Container) async -> Content,
		@Relux.StatesBuilder states: @escaping @Sendable () -> [any ReluxState],
		@Relux.ModulesBuilder modules: @escaping @Sendable () -> [any Relux.Module],
		@Relux.SagasBuilder sagas: @escaping @Sendable () -> [any ReluxSaga],
		@Relux.ActionsBuilder actions: @escaping @Sendable () -> [any ReluxAction],
		@Relux.Navigation.RoutersBuilder routers: @escaping @MainActor @Sendable () -> [any Relux.Navigation.RouterProtocol]
	) {
		self.content = content
		self.states = states
		self.modules = modules
		self.sagas = sagas
		self.routers = routers
		self._actions = actions
	}
	
	var body: some View {
		if let contentView {
			contentView
		} else {
			Text("")
				.task {
					let appState = await Container(
						reluxModules: modules(),
						states: states(),
						sagas: sagas(),
						routers: routers()
					)
					self.contentView = await updateView(await content(appState), fromStore: appState.relux.appStore)
					await actions(.concurrently, actions: _actions)
				}
		}
	}
	
	@MainActor
	func updateView<ViewContent: View>(_ view: ViewContent, fromStore store: Relux.Store) async -> AnyView {
		var view: any View = view
		
		let routers = await store.routers.values
		for router in routers {
			view = view.environmentObject(router)
		}
		
		let viewStates = await store.viewStates
		for pair in viewStates {
			let viewState = pair.value
			view = view.environmentObject(viewState)
		}
		
		let viewStatesObservables = await store.viewStatesObservables
		for pair in viewStatesObservables {
			let viewState = pair.value
			view = view.environment(viewState)
		}
		
		return AnyView(view)
	}
}


