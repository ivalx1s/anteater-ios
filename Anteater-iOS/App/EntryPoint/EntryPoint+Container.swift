import SwiftUI
import FeatureManagementModule
import ConnectionMonitor
import Relux

enum EntryPoint {}

extension EntryPoint {
	struct ContentContainer: View {
		var body: some View {
			ContentView()
				.bindEnabledFeatures()
		}
	}
}


extension EntryPoint {
	struct ContentView: View {
		var body: some View {
			VStack {
				Image(systemName: "globe")
					.imageScale(.large)
					.foregroundStyle(.tint)
				Text("Hello, world!")
			}
		}
	}
}
