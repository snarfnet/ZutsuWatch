import SwiftUI

struct PressureChartView: View {
    let history: [PressurePoint]
    let forecast: [PressurePoint]

    var body: some View {
        GeometryReader { geo in
            let allPoints = history + forecast
            guard !allPoints.isEmpty else {
                return AnyView(
                    Text("データなし")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                )
            }

            let minP = (allPoints.map(\.pressure).min() ?? 1010) - 2
            let maxP = (allPoints.map(\.pressure).max() ?? 1020) + 2
            let minDate = allPoints.map(\.date).min() ?? .now
            let maxDate = allPoints.map(\.date).max() ?? .now
            let dateRange = maxDate.timeIntervalSince(minDate)

            return AnyView(
                ZStack {
                    // グリッド線
                    VStack {
                        ForEach(0..<4) { i in
                            if i > 0 { Spacer() }
                            HStack {
                                let val = maxP - (maxP - minP) * Double(i) / 3
                                Text(String(format: "%.0f", val))
                                    .font(.system(size: 9, design: .rounded))
                                    .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
                                    .frame(width: 28, alignment: .trailing)
                                Rectangle()
                                    .fill(AppTheme.textSecondary.opacity(0.1))
                                    .frame(height: 0.5)
                            }
                        }
                    }

                    // 現在の時刻ライン
                    let nowX = dateRange > 0 ? CGFloat(Date.now.timeIntervalSince(minDate) / dateRange) * (geo.size.width - 32) + 32 : 0
                    if nowX > 32 && nowX < geo.size.width {
                        Path { path in
                            path.move(to: CGPoint(x: nowX, y: 0))
                            path.addLine(to: CGPoint(x: nowX, y: geo.size.height))
                        }
                        .stroke(AppTheme.lavender.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    }

                    // 履歴ライン
                    if history.count > 1 {
                        chartLine(points: history, in: geo.size, minP: minP, maxP: maxP, minDate: minDate, dateRange: dateRange)
                            .stroke(AppTheme.lavender, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    }

                    // 予報ライン
                    if forecast.count > 1 {
                        let forecastWithBridge = [history.last].compactMap { $0 } + forecast
                        chartLine(points: forecastWithBridge, in: geo.size, minP: minP, maxP: maxP, minDate: minDate, dateRange: dateRange)
                            .stroke(AppTheme.pink.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [6, 4]))
                    }
                }
                .padding(.leading, 0)
            )
        }
    }

    private func chartLine(points: [PressurePoint], in size: CGSize, minP: Double, maxP: Double, minDate: Date, dateRange: TimeInterval) -> Path {
        Path { path in
            guard dateRange > 0, maxP > minP else { return }
            let chartWidth = size.width - 32
            for (i, point) in points.enumerated() {
                let x = CGFloat(point.date.timeIntervalSince(minDate) / dateRange) * chartWidth + 32
                let y = size.height - CGFloat((point.pressure - minP) / (maxP - minP)) * size.height
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
    }
}
