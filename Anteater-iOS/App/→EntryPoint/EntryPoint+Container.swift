import SwiftUI
import ReluxFeatureManagement
import ConnectionMonitor
import Relux

enum EntryPoint {}

extension EntryPoint {
	struct ContentContainer: View {
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

extension UI.Dashboard {
	struct RootPage: View {
		
		let connectionState: Bool
		let allFeatures: [FeatureManagement.Business.Model.Feature]
		let enabledFeatures: [FeatureManagement.Business.Model.Feature.Key]
		
		@Binding var router: NavigationPath
		
		var body: some View {
			NavigationStack(path: $router) {
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
								Relux.Navigation.ProjectingRouter.Action.push(page: UI.Dashboard.Navigation.Page.info)
							}
						}
					}) {
						Text("Info Page")
					}
					.padding(.bottom, 30)
					Button(action: {
						Task {
							await action {
								Relux.Navigation.ProjectingRouter.Action.push(page: UI.Dashboard.Navigation.Page.details)
							}
						}
					}) {
						Text("Details Page")
					}
					Spacer()
				}
					.navigationDestination(for: UI.Dashboard.Navigation.Page.self, destination: route)
			}
		}
		
		@ViewBuilder
		private func route(forPage page: UI.Dashboard.Navigation.Page) -> some View {
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
