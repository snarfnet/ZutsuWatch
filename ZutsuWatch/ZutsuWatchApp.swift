import SwiftUI
import SwiftData
import GoogleMobileAds
import AppTrackingTransparency

@main
struct ZutsuWatchApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var attRequested = false

    init() {
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.light)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active && !attRequested {
                        attRequested = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            ATTrackingManager.requestTrackingAuthorization { _ in }
                        }
                    }
                }
        }
        .modelContainer(for: HeadacheEntry.self)
    }
}
