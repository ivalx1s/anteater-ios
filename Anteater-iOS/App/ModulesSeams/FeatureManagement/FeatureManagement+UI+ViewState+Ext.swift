import Foundation
import Combine
import FeatureManagementModule

extension FeatureManagement.UI.ViewState {
	var anteaterFeatures: AnyPublisher<[FeatureManagement.Business.Model.AnteaterFeature], Never> {
		self.$enabledFeatures
			.map { features in
				features
					.compactMap { FeatureManagement.Business.Model.AnteaterFeature(rawValue: $0) }
			}
			.eraseToAnyPublisher()
	}
	
	func check(expression: FeatureManagement.Business.Model.FeatureComposite) -> Bool {
		expression.check(against: enabledFeatures)
	}
}
