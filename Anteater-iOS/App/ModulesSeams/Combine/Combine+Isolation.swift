import Combine

extension AnyPublisher: @unchecked @retroactive Sendable where Output: Sendable, Failure: Sendable {}
extension Published.Publisher: @unchecked @retroactive Sendable where Value: Sendable, Failure: Sendable {}
extension Never: Sendable {}
