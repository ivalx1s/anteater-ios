import Foundation
import Combine
import Relux
import ConnectionMonitor

extension ConnectionMonitor.UI {
	@Observable
	final class State: ReluxViewStateObserving, @unchecked Sendable {
		private var pipelines: Set<AnyCancellable> = []

		var connected: Bool = false
		
		init(
			connectionMonitorBusinessState: ConnectionMonitor.Business.State
		) {
			Task {
				await connect(connectionMonitorBusinessState: connectionMonitorBusinessState)
			}
		}
		
		private func connect(connectionMonitorBusinessState: ConnectionMonitor.Business.State) async {
			let combinedStream = await combineLatest(connectionMonitorBusinessState.statusUpdates, connectionMonitorBusinessState.statusUpdates)
			
			Task { @MainActor in
				for await newStatuses in combinedStream {
					self.connected = newStatuses.0.expensive && newStatuses.0.expensive
				}
			}
		}
	}
}

// experimental
fileprivate func combineLatest<A: Sendable, B: Sendable>(_ streamA: AsyncStream<A>, _ streamB: AsyncStream<B>) -> AsyncStream<(A, B)> {
	AsyncStream { continuation in
		Task {
			let latestA = ManagedCriticalState<A?>(nil)
			let latestB = ManagedCriticalState<B?>(nil)
			
			await withTaskGroup(of: Void.self) { group in
				group.addTask {
					for await valueA in streamA {
						await latestA.set(value: valueA)
						if let b = await latestB.get() {
							continuation.yield((valueA, b))
						}
					}
				}
				
				group.addTask {
					for await valueB in streamB {
						await latestB.set(value: valueB)
						if let a = await latestA.get() {
							continuation.yield((a, valueB))
						}
					}
				}
				
				await group.waitForAll()
			}
			
			continuation.finish()
		}
	}
}

fileprivate actor ManagedCriticalState<State>: Sendable {
	private var state: State
	
	init(_ initialState: State) {
		self.state = initialState
	}
	
	func get() -> State {
		return state
	}
	
	func set(value: State) {
		self.state = value
	}
}
