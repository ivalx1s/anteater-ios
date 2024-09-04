import SwiftUI
import ReluxFeatureManagement

extension FeatureManagement.Business.Model.FeatureComposite {
	static func exactFeature(_ feature: FeatureManagement.Business.Model.AnteaterFeature) -> Self {
		.feature(feature: feature.rawValue)
	}
}

