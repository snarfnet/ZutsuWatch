import SwiftUI

struct MainTabView: View {
    @StateObject private var pressure = PressureService()

    var body: some View {
        VStack(spacing: 0) {
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

            BannerAdView()
                .frame(height: 50)
        }
    }
}
