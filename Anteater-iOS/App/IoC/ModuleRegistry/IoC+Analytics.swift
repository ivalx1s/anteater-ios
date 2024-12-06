import Swinject
import ReluxAnalytics
import Foundation

fileprivate final class AmplitudeLicenseKeyStore: Analytics.LicenseKeyProviding {
    let licenseKey: String = ""
}

fileprivate final class UserIdentityProvider: Analytics.IUserIdentityProvider {
    let userIdentity: String = "user_id"
}

extension Analytics: IoC.Registry.Module {
    
    @MainActor
    static func register(in container: Swinject.Container) {
        
        container.register((any Analytics.IAnalyticsService).self) { resolver -> (any Analytics.IAnalyticsService) in
            var aggregators = [any Analytics.IAnalyticsAggregator]()
            #if !DEBUG // disable analytics in debug builds
            // let amplitudeAggregator = ...
            // let appsflyerAggregator = ...
            aggregators.append(/*amplitudeAggregator*/)
            aggregators.append(/*appsflyerAggregator*/)
            #endif
            return Analytics.AnalyticsService(
                aggregators: aggregators
            )
        }
        
        container.register(Analytics.Saga.self) { resolver -> Analytics.Saga in
            Analytics.Saga(
                analyticsService: resolver.resolve((any Analytics.IAnalyticsService).self)!,
                userIdentityProvider: UserIdentityProvider()
            )
        }
        
        container.register(Analytics.Module.self) { resolver -> Analytics.Module in
            Analytics.Module.init(
                sagas: [resolver.resolve(Analytics.Saga.self)!]
            )
        }
    }
}
