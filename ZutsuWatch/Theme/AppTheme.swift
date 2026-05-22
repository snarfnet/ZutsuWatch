import SwiftUI

enum AppTheme {
    // パステルカラー
    static let pink = Color(red: 255/255, green: 150/255, blue: 180/255)
    static let lavender = Color(red: 190/255, green: 170/255, blue: 240/255)
    static let mint = Color(red: 160/255, green: 230/255, blue: 210/255)
    static let sky = Color(red: 150/255, green: 200/255, blue: 255/255)
    static let peach = Color(red: 255/255, green: 200/255, blue: 170/255)
    static let cream = Color(red: 255/255, green: 250/255, blue: 240/255)
    static let softWhite = Color(red: 250/255, green: 248/255, blue: 255/255)

    // テキスト
    static let textPrimary = Color(red: 80/255, green: 60/255, blue: 90/255)
    static let textSecondary = Color(red: 150/255, green: 130/255, blue: 160/255)

    // リスクカラー
    static let riskLow = mint
    static let riskMid = peach
    static let riskHigh = pink

    // 背景グラデーション
    static let bgGradient = LinearGradient(
        colors: [Color(red: 245/255, green: 240/255, blue: 255/255), cream],
        startPoint: .top, endPoint: .bottom
    )

    // フォント
    static let titleFont = Font.system(.title2, design: .rounded).bold()
    static let bodyFont = Font.system(.body, design: .rounded)
    static let captionFont = Font.system(.caption, design: .rounded)
    static let bigNumber = Font.system(size: 48, weight: .bold, design: .rounded)
}
