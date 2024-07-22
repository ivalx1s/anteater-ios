import SwiftUI
import Foundation
import FeatureManagementModule
import ConnectionMonitor
import Relux

struct __DebugInternalPlayground: View {
	
//	@EnvironmentObject private var features: FeatureManagement.UI.ViewState
	@Environment(ConnectionMonitor.UI.State.self) private var connectionMonitor
	
	var body: some View {
		VStack {
			Image(systemName: "globe")
				.imageScale(.large)
				.foregroundStyle(.tint)
			Text("Hello, world!")
//				.presentIf(.exactFeature(.debugMenu))
			
			Button(action: {
				Task {
					await action {
						FeatureManagement.Business.Effect.enableFeature(feature: FeatureManagement.Business.Model.AnteaterFeature.debugMenu.rawValue)
					} label: {
						"yo"
					}
				}
			}) {
//				ForEach(features.enabledFeatures, id: \.self) { enabledFeature in
//					Text("\(enabledFeature)")
//				}
			}
			
			Text(connectionMonitor.connected.description)
			
			Button(action: {
				Task {
					await action {
						ConnectionMonitor.Action.updateStatus(ConnectionMonitor.NetworkStatus.init(connected: false, expensive: true))
					}
				}
			}) {
				Text("Toggle network")
			}
		}
		.padding()
		//			.debugViewType()
	}
	}
