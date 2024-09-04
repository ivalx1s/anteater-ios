import SwiftUI
import ConnectionMonitor
import ReluxFeatureManagement
import Relux

extension UI.Dashboard {
	
	@MainActor
	struct Container: View {
		
		@Environment(ConnectionMonitor.UI.State.self) private var connectionMonitor
		@EnvironmentObject private var features: FeatureManagement.UI.ViewState
		@EnvironmentObject private var dashboardRouter: Relux.Navigation.ProjectingRouter<UI.Dashboard.Navigation.Page>
		
		var body: some View {
			UI.Dashboard.RootPage(
				connectionState: connectionMonitor.connected,
				allFeatures: features.allFeatures,
				enabledFeatures: features.enabledFeatures,
				router: $dashboardRouter.path
			)
		}
		
	}
}
