import Foundation
import Combine
import Relux
import ConnectionMonitor


extension ConnectionMonitor.UI {
	@Observable @MainActor
	final class State: ReluxViewStateObserving, @unchecked Sendable {
		private var pipelines: Set<AnyCancellable> = []

		var connected: Bool = false
	
		init(
			connectionMonitorBusinessState: ConnectionMonitor.Business.State
		) {
			Task {
				await connect2(connectionMonitorBusinessState: connectionMonitorBusinessState)
			}
		}
		
		private func connect2(connectionMonitorBusinessState: ConnectionMonitor.Business.State) async {
			await connectionMonitorBusinessState.$status
				.receive(on: DispatchQueue.main)
				.weakSink(self) { (self, status) in
					self.connected = status.connected
				}
				.store(in: &pipelines)
		}
	}
}


extension Publisher where Failure == Never {
	func weakSink<Object: AnyObject>(
		_ object: Object,
		receiveValue: @escaping (Object, Output) -> Void
	) -> AnyCancellable {
		sink { [weak object] value in
			guard let object = object else { return }
			receiveValue(object, value)
		}
	}
}
