import SwiftUI

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
			VStack {
				Image(systemName: "globe")
					.imageScale(.large)
					.foregroundStyle(.tint)
				Text("Hello, world!")
			}
			.padding()
		}
	}
}
