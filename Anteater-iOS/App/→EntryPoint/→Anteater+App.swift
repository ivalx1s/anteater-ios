import SwiftUI
import SwiftPlus
import FoundationPlus
import Logger
import Relux
import FeatureManagementModule
import ConnectionMonitor
import ReluxRouter


@main @MainActor
struct Anteater: App {
	
	init() {
		configureIoC()
	}
	
	private func configureIoC() {
		IoC.Registry.registerModule(FeatureManagement.self)
		IoC.Registry.registerModule(ConnectionMonitor.self)
		IoC.initialize(with: IoC.Registry.build)
	}
	
	var body: some Scene {
		WindowGroup {
			ReluxRootView { appState in
				EntryPoint.ContentContainer(appState: appState)
			}
			modules: {
				IoC.get(type: (FeatureManagement.Module).self)!
				IoC.get(type: (ConnectionMonitor.Module).self)!
			}
			states: { 
				
			}
			sagas: { }
			actions: {
				FeatureManagement.Business.Effect.obtainEnabledFeatures
				ConnectionMonitor.SideEffect.startNetworkMonitor
			}
			routers: {
				Relux.Navigation.Router<UI.Dashboard.Navigation.Page>()
				Relux.Navigation.Router<UI.Profile.Navigation.Page>()
			}
		}
	}
}
