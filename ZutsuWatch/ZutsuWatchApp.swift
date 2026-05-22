import SwiftUI
import SwiftData
import GoogleMobileAds

@main
struct ZutsuWatchApp: App {
    init() {
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.light)
        }
        .modelContainer(for: HeadacheEntry.self)
    }
}
