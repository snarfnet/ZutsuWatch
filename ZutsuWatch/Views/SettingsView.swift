import SwiftUI

struct SettingsView: View {
    @AppStorage("notifyOnDrop") private var notifyOnDrop = true
    @AppStorage("dropThreshold") private var dropThreshold = 2.0
    @AppStorage("locationName") private var locationName = "東京"

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bgGradient.ignoresSafeArea()

                Form {
                    Section("通知") {
                        Toggle(isOn: $notifyOnDrop) {
                            Label("気圧低下で通知", systemImage: "bell.fill")
                        }
                        .tint(AppTheme.lavender)

                        if notifyOnDrop {
                            VStack(alignment: .leading) {
                                Text("低下しきい値: \(String(format: "%.1f", dropThreshold)) hPa")
                                    .font(AppTheme.bodyFont)
                                Slider(value: $dropThreshold, in: 1...5, step: 0.5)
                                    .tint(AppTheme.lavender)
                                Text("1時間あたりこの値以上低下したら通知します")
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.6))

                    Section("地域") {
                        Picker("予報地域", selection: $locationName) {
                            Text("東京").tag("東京")
                            Text("大阪").tag("大阪")
                            Text("名古屋").tag("名古屋")
                            Text("福岡").tag("福岡")
                            Text("札幌").tag("札幌")
                            Text("仙台").tag("仙台")
                            Text("那覇").tag("那覇")
                        }
                        .tint(AppTheme.lavender)
                    }
                    .listRowBackground(Color.white.opacity(0.6))

                    Section("気圧と頭痛について") {
                        VStack(alignment: .leading, spacing: 8) {
                            infoRow(emoji: "📉", text: "気圧が急に下がると頭痛が起きやすくなります")
                            infoRow(emoji: "🧠", text: "気圧低下で血管が膨張し、神経を刺激します")
                            infoRow(emoji: "💊", text: "予兆があれば早めの対処が効果的です")
                            infoRow(emoji: "📊", text: "記録を続けると自分のパターンが見えてきます")
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.6))

                    Section("アプリ情報") {
                        HStack {
                            Text("バージョン")
                            Spacer()
                            Text("1.0")
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        HStack {
                            Text("気象データ")
                            Spacer()
                            Text("Open-Meteo")
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.6))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Text("⚙️")
                        Text("設定")
                            .font(AppTheme.titleFont)
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                }
            }
        }
    }

    private func infoRow(emoji: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(emoji)
            Text(text)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textPrimary)
        }
    }
}
