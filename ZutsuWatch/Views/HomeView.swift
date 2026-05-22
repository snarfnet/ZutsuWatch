import SwiftUI

struct HomeView: View {
    @ObservedObject var pressure: PressureService

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bgGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        riskCard
                        pressureCard
                        chartCard
                        forecastSummary
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Text("🌤️")
                        Text("ズツウォッチ")
                            .font(AppTheme.titleFont)
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                }
            }
        }
    }

    // MARK: - リスクカード

    private var riskCard: some View {
        VStack(spacing: 12) {
            Text(pressure.headacheRisk.emoji)
                .font(.system(size: 56))

            Text("頭痛リスク")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)

            Text(pressure.headacheRisk.label)
                .font(AppTheme.titleFont)
                .foregroundStyle(riskColor)

            // トレンド表示
            HStack(spacing: 4) {
                Image(systemName: trendIcon)
                    .foregroundStyle(trendColor)
                Text(String(format: "%+.1f hPa/h", pressure.pressureTrend))
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: riskColor.opacity(0.2), radius: 12, y: 4)
    }

    // MARK: - 気圧カード

    private var pressureCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("現在の気圧")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textSecondary)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", pressure.currentPressure))
                        .font(AppTheme.bigNumber)
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("hPa")
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            Spacer()

            VStack(spacing: 8) {
                Image(systemName: weatherIcon)
                    .font(.system(size: 36))
                    .foregroundStyle(AppTheme.sky)
                Text(weatherLabel)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(20)
        .background(.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - グラフカード

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 気圧の変化")
                .font(AppTheme.bodyFont.bold())
                .foregroundStyle(AppTheme.textPrimary)

            PressureChartView(
                history: pressure.pressureHistory,
                forecast: pressure.forecast
            )
            .frame(height: 160)
        }
        .padding(20)
        .background(.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - 予報サマリ

    private var forecastSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔮 今後の予報")
                .font(AppTheme.bodyFont.bold())
                .foregroundStyle(AppTheme.textPrimary)

            let upcoming = Array(pressure.forecast.prefix(6))
            if upcoming.isEmpty {
                Text("予報データを取得中...")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textSecondary)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(upcoming) { point in
                        VStack(spacing: 4) {
                            Text(point.date.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated))))
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.textSecondary)
                            Text(String(format: "%.0f", point.pressure))
                                .font(.system(.body, design: .rounded).bold())
                                .foregroundStyle(AppTheme.textPrimary)
                            let diff = point.pressure - pressure.currentPressure
                            Text(String(format: "%+.1f", diff))
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(diff < -1 ? AppTheme.pink : diff > 1 ? AppTheme.mint : AppTheme.textSecondary)
                        }
                        .padding(8)
                        .background(AppTheme.softWhite)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding(20)
        .background(.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Helpers

    private var riskColor: Color {
        switch pressure.headacheRisk {
        case .low: AppTheme.riskLow
        case .medium: AppTheme.riskMid
        case .high: AppTheme.riskHigh
        }
    }

    private var trendIcon: String {
        if pressure.pressureTrend < -0.5 { return "arrow.down.circle.fill" }
        if pressure.pressureTrend > 0.5 { return "arrow.up.circle.fill" }
        return "arrow.right.circle.fill"
    }

    private var trendColor: Color {
        if pressure.pressureTrend < -0.5 { return AppTheme.pink }
        if pressure.pressureTrend > 0.5 { return AppTheme.mint }
        return AppTheme.textSecondary
    }

    private var weatherIcon: String {
        if pressure.currentPressure > 1020 { return "sun.max.fill" }
        if pressure.currentPressure > 1013 { return "cloud.sun.fill" }
        if pressure.currentPressure > 1005 { return "cloud.fill" }
        return "cloud.rain.fill"
    }

    private var weatherLabel: String {
        if pressure.currentPressure > 1020 { return "高気圧" }
        if pressure.currentPressure > 1013 { return "平均的" }
        if pressure.currentPressure > 1005 { return "やや低め" }
        return "低気圧"
    }
}
