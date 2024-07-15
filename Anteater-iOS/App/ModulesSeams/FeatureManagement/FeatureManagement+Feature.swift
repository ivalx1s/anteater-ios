import Foundation
import FeatureManagementModule

extension FeatureManagement.Business.Model {
	enum AnteaterFeature: FeatureManagement.Business.Model.Feature.Key, Sendable {
		case debugMenu = "debugMenu"
		case personalAssistant = "personalAssistant"
	}
}

extension FeatureManagement.Business.Model.AnteaterFeature {
	var label: String {
		switch self {
			case .debugMenu: return "Debug Menu"
			case .personalAssistant: return "Personal assistant"
		}
	}
}

extension FeatureManagement.Business.Model.AnteaterFeature: CaseIterable {}

extension FeatureManagement.Business.Model.AnteaterFeature: RawRepresentable {}

extension FeatureManagement.Business.Model.AnteaterFeature: ExpressibleByStringLiteral {
	init(stringLiteral value: String) {
		self.init(rawValue: value)!
	}
}

extension FeatureManagement.Business.Model.AnteaterFeature: Codable {}
