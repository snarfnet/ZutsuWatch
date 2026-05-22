import Foundation
import CoreMotion
import Combine

@MainActor
final class PressureService: ObservableObject {
    @Published var currentPressure: Double = 1013.25
    @Published var pressureHistory: [PressurePoint] = []
    @Published var forecast: [PressurePoint] = []
    @Published var headacheRisk: HeadacheRisk = .low
    @Published var pressureTrend: Double = 0 // hPa/h change
    @Published var isLoading = false

    private let altimeter = CMAltimeter()
    private var historyTimer: Timer?

    init() {
        startMonitoring()
        loadForecast()
    }

    // MARK: - CMAltimeter リアルタイム気圧

    private func startMonitoring() {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            // シミュレータ用ダミーデータ
            loadDemoData()
            return
        }

        altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
            guard let data = data, error == nil else { return }
            let pressure = data.pressure.doubleValue * 10 // kPa -> hPa
            Task { @MainActor in
                self?.updatePressure(pressure)
            }
        }

        // 5分ごとに履歴に追加
        historyTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.recordHistory()
            }
        }
    }

    private func updatePressure(_ pressure: Double) {
        let oldPressure = currentPressure
        currentPressure = pressure

        // トレンド計算（1時間あたりの変化）
        if !pressureHistory.isEmpty {
            let oneHourAgo = pressureHistory.filter { $0.date > Date.now.addingTimeInterval(-3600) }
            if let oldest = oneHourAgo.first {
                pressureTrend = pressure - oldest.pressure
            }
        }

        // リスク評価
        evaluateRisk()
    }

    private func recordHistory() {
        let point = PressurePoint(date: .now, pressure: currentPressure)
        pressureHistory.append(point)

        // 48時間分のみ保持
        let cutoff = Date.now.addingTimeInterval(-48 * 3600)
        pressureHistory.removeAll { $0.date < cutoff }
    }

    // MARK: - リスク評価

    private func evaluateRisk() {
        // 気圧が急降下 → 頭痛リスク高
        if pressureTrend < -2 {
            headacheRisk = .high
        } else if pressureTrend < -0.5 {
            headacheRisk = .medium
        } else {
            headacheRisk = .low
        }
    }

    // MARK: - Open-Meteo 気圧予報

    func loadForecast() {
        isLoading = true
        Task {
            do {
                let forecasted = try await fetchForecast()
                self.forecast = forecasted
                self.isLoading = false
                evaluateForecastRisk()
            } catch {
                self.isLoading = false
            }
        }
    }

    private func fetchForecast() async throws -> [PressurePoint] {
        // Open-Meteo API (無料、キー不要)
        // 東京のデフォルト座標
        let lat = 35.6762
        let lon = 139.6503
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&hourly=surface_pressure&timezone=Asia%2FTokyo&forecast_days=2&past_days=1"

        guard let url = URL(string: urlString) else { return [] }

        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let hourly = json?["hourly"] as? [String: Any],
              let times = hourly["time"] as? [String],
              let pressures = hourly["surface_pressure"] as? [Double] else { return [] }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]

        var points: [PressurePoint] = []
        for (i, timeStr) in times.enumerated() where i < pressures.count {
            if let date = formatter.date(from: timeStr + ":00") {
                points.append(PressurePoint(date: date, pressure: pressures[i]))
            }
        }

        // 過去データを履歴にも反映
        let now = Date.now
        let pastPoints = points.filter { $0.date <= now }
        if pressureHistory.isEmpty {
            pressureHistory = pastPoints
        }

        // 現在の気圧を更新（センサーが使えない場合）
        if let closest = pastPoints.last {
            if !CMAltimeter.isRelativeAltitudeAvailable() {
                currentPressure = closest.pressure
                evaluateRisk()
            }
        }

        return points.filter { $0.date > now }
    }

    private func evaluateForecastRisk() {
        // 今後6時間の予報で気圧が3hPa以上下がる場合は高リスク
        let sixHours = forecast.filter { $0.date < Date.now.addingTimeInterval(6 * 3600) }
        if let minPressure = sixHours.map({ $0.pressure }).min() {
            let drop = currentPressure - minPressure
            if drop > 3 {
                headacheRisk = .high
            } else if drop > 1 && headacheRisk == .low {
                headacheRisk = .medium
            }
        }
    }

    // MARK: - デモデータ

    private func loadDemoData() {
        let base = 1013.25
        var points: [PressurePoint] = []
        for i in stride(from: -24, through: 0, by: 1) {
            let date = Date.now.addingTimeInterval(Double(i) * 3600)
            let variation = sin(Double(i) * 0.3) * 3 + Double.random(in: -0.5...0.5)
            points.append(PressurePoint(date: date, pressure: base + variation))
        }
        pressureHistory = points
        currentPressure = points.last?.pressure ?? base
        evaluateRisk()
    }
}
