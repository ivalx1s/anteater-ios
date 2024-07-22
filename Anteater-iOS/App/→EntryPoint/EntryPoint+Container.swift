import SwiftUI
import FeatureManagementModule
import ConnectionMonitor
import Relux
import ReluxRouter

enum EntryPoint {}

extension EntryPoint {
	struct ContentContainer: View {
		
		@StateObject private var appState: AppReluxContainer
		
		init(appState: AppReluxContainer) {
			self._appState = StateObject(wrappedValue: appState)
		}
		
		var body: some View {
			ContentView()
		}
	}
}


extension EntryPoint {
	struct ContentView: View {
		
		var body: some View {
			TabView {
				UI.Dashboard.Container()
					.tabItem {
						Label("Dashboard", systemImage: "1.circle")
					}
				
				UI.Profile.Container()
					.tabItem {
						Label("Profile", systemImage: "2.circle")
					}
			}
		}
	}
}


enum UI {
	
}

extension UI {
	enum Dashboard {
		
	}
}


extension UI {
	enum Profile {
		
	}
}

extension UI.Dashboard {
	
	struct Container: View {
		
		@Environment(ConnectionMonitor.UI.State.self) private var connectionMonitor
		@EnvironmentObject private var features: FeatureManagement.UI.ViewState
		@EnvironmentObject private var dashboardRouter: Relux.Navigation.Router<UI.Dashboard.Navigation.Page>
		
		var body: some View {
			UI.Dashboard.RootPage(
				connectionState: connectionMonitor.connected,
				allFeatures: features.allFeatures,
				enabledFeatures: features.enabledFeatures,
				navigationPath: $dashboardRouter.path
			)
		}
		
	}
}

extension UI.Dashboard {
	struct RootPage: View {
		
		let connectionState: Bool
		let allFeatures: [FeatureManagement.Business.Model.Feature]
		let enabledFeatures: [FeatureManagement.Business.Model.Feature.Key]
		
		@Binding var navigationPath: NavigationPath
		
		var body: some View {
			NavigationStack(path: $navigationPath) {
				VStack {
					Text("Dashboard root page")
						.font(.largeTitle)
						.padding()
					Text("Connection: \(connectionState)")
					Image(systemName: "1.circle")
						.resizable()
						.frame(width: 100, height: 100)
					
					ScrollView(.horizontal) {
						HStack {
							ForEach(allFeatures, id: \.key) { feature in
								Text("\(feature.label)")
							}
						}
					}
					Button(action: {
						Task {
							await action {
								Relux.Navigation.Router.Action.push(page: UI.Dashboard.Navigation.Page.info)
							}
						}
					}) {
						Text("Info Page")
					}
					.padding(.bottom, 30)
					Button(action: {
						Task {
							await action {
								Relux.Navigation.Router.Action.push(page: UI.Dashboard.Navigation.Page.details)
							}
						}
					}) {
						Text("Details Page")
					}
					Spacer()
				}
					.navigationDestination(for: UI.Dashboard.Navigation.Page.self, destination: Route)
			}
		}
		
		@ViewBuilder
		private func Route(forPage page: UI.Dashboard.Navigation.Page) -> some View {
			switch page {
				case .details:
					Text("UI.Dashboard.Details.Page")
				case .info:
					Text("UI.Dashboard.Info.Page")
					
			}
		}
		
	}
}

extension UI.Profile {
	
	struct Container: View {
		
		@Environment(ConnectionMonitor.UI.State.self) private var connectionMonitor
		@EnvironmentObject private var features: FeatureManagement.UI.ViewState
		
		var body: some View {
			UI.Profile.RootPage(
				connectionState: connectionMonitor.connected,
				allFeatures: features.allFeatures,
				enabledFeatures: features.enabledFeatures
			)
		}
		
	}
}

extension UI.Profile {
	struct RootPage: View {
		
		let connectionState: Bool
		let allFeatures: [FeatureManagement.Business.Model.Feature]
		let enabledFeatures: [FeatureManagement.Business.Model.Feature.Key]
		
		var body: some View {
			VStack {
				Text("Profile root page")
					.font(.largeTitle)
					.padding()
				Text("Connection: \(connectionState)")
				Image(systemName: "2.circle")
					.resizable()
					.frame(width: 100, height: 100)
				
				ScrollView(.horizontal) {
					HStack {
						ForEach(allFeatures, id: \.key) { feature in
							Text("\(feature.label)")
						}
					}
				}
				Spacer()
			}
		}
		
	}
}

//extension View {
//	func debug() -> Self {
//		print(Mirror(reflecting: self).subjectType)
//		return self
//	} }
