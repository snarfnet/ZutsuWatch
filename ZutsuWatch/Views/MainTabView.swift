import SwiftUI

struct MainTabView: View {
    @StateObject private var pressure = PressureService()

    var body: some View {
        VStack(spacing: 0) {
            BannerAdView(adUnitID: AdConfig.topBannerAdUnitID)
                .frame(height: 50)

            TabView {
                HomeView(pressure: pressure)
                    .tabItem {
                        Label("ホーム", systemImage: "cloud.sun")
                    }

                DiaryView()
                    .tabItem {
                        Label("記録", systemImage: "book")
                    }

                SettingsView()
                    .tabItem {
                        Label("設定", systemImage: "gearshape")
                    }
            }
            .tint(AppTheme.lavender)

            BannerAdView(adUnitID: AdConfig.bottomBannerAdUnitID)
                .frame(height: 50)
        }
    }
}
