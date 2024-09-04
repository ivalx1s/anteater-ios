import SwiftUI
import ConnectionMonitor
import ReluxFeatureManagement

extension UI.Profile {
	
	struct Container: View {
		
		@Environment(ConnectionMonitor.UI.State.self) private var connectionMonitor
		@EnvironmentObject private var features: FeatureManagement.UI.ViewState
		
		@Environment(Relux.Navigation.Router<UI.Profile.Navigation.Page>.self) private var profileRouter
		
		var body: some View {
			UI.Profile.RootPage(
				connectionState: connectionMonitor.connected,
				allFeatures: features.allFeatures,
				enabledFeatures: features.enabledFeatures
			)
		}
	}
}
