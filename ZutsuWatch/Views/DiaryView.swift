import SwiftUI
import SwiftData

struct DiaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HeadacheEntry.date, order: .reverse) private var entries: [HeadacheEntry]
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bgGradient.ignoresSafeArea()

                if entries.isEmpty {
                    VStack(spacing: 16) {
                        Text("📝")
                            .font(.system(size: 56))
                        Text("まだ記録がありません")
                            .font(AppTheme.bodyFont)
                            .foregroundStyle(AppTheme.textSecondary)
                        Text("頭痛があった時に+ボタンで記録しましょう")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                } else {
                    List {
                        // 統計ヘッダー
                        Section {
                            statsHeader
                        }
                        .listRowBackground(Color.white.opacity(0.6))

                        // エントリ一覧
                        Section("記録一覧") {
                            ForEach(entries) { entry in
                                entryRow(entry)
                            }
                            .onDelete(perform: deleteEntries)
                        }
                        .listRowBackground(Color.white.opacity(0.6))
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Text("📝")
                        Text("頭痛ダイアリー")
                            .font(AppTheme.titleFont)
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppTheme.lavender)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEntryView()
            }
        }
    }

    private var statsHeader: some View {
        let thisMonth = entries.filter {
            Calendar.current.isDate($0.date, equalTo: .now, toGranularity: .month)
        }
        let avgSeverity = thisMonth.isEmpty ? 0.0 : Double(thisMonth.map(\.severity).reduce(0, +)) / Double(thisMonth.count)
        let medicineCount = thisMonth.filter(\.tookMedicine).count

        return HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("\(thisMonth.count)")
                    .font(.system(.title, design: .rounded).bold())
                    .foregroundStyle(AppTheme.lavender)
                Text("今月の回数")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 4) {
                Text(String(format: "%.1f", avgSeverity))
                    .font(.system(.title, design: .rounded).bold())
                    .foregroundStyle(AppTheme.peach)
                Text("平均の強さ")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 4) {
                Text("\(medicineCount)")
                    .font(.system(.title, design: .rounded).bold())
                    .foregroundStyle(AppTheme.mint)
                Text("服薬回数")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
    }

    private func entryRow(_ entry: HeadacheEntry) -> some View {
        HStack(spacing: 12) {
            Text(entry.severityEmoji)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.severityLabel)
                        .font(AppTheme.bodyFont.bold())
                        .foregroundStyle(AppTheme.textPrimary)
                    if entry.tookMedicine {
                        Image(systemName: "pills.fill")
                            .font(.caption)
                            .foregroundStyle(AppTheme.mint)
                    }
                }
                HStack(spacing: 8) {
                    Text(entry.date.formatted(.dateTime.month().day().weekday(.abbreviated)))
                    Text("·")
                    Text(String(format: "%.1f hPa", entry.pressure))
                }
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)

                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func deleteEntries(at offsets: IndexSet) {
        offsets.map { entries[$0] }.forEach { modelContext.delete($0) }
    }
}

// MARK: - 記録追加

struct AddEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var severity = 2
    @State private var tookMedicine = false
    @State private var note = ""
    @State private var date = Date.now

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bgGradient.ignoresSafeArea()

                Form {
                    Section("いつ？") {
                        DatePicker("日時", selection: $date)
                            .tint(AppTheme.lavender)
                    }
                    .listRowBackground(Color.white.opacity(0.6))

                    Section("どのくらい？") {
                        Picker("強さ", selection: $severity) {
                            Text("😕 軽い").tag(1)
                            Text("😖 普通").tag(2)
                            Text("🤯 ひどい").tag(3)
                        }
                        .pickerStyle(.segmented)
                    }
                    .listRowBackground(Color.white.opacity(0.6))

                    Section("薬は飲んだ？") {
                        Toggle(isOn: $tookMedicine) {
                            Label("服薬した", systemImage: "pills.fill")
                        }
                        .tint(AppTheme.mint)
                    }
                    .listRowBackground(Color.white.opacity(0.6))

                    Section("メモ") {
                        TextField("（任意）気づいたことなど", text: $note, axis: .vertical)
                            .lineLimit(2...4)
                    }
                    .listRowBackground(Color.white.opacity(0.6))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("頭痛を記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let entry = HeadacheEntry(
                            date: date,
                            severity: severity,
                            pressure: 0,
                            note: note,
                            tookMedicine: tookMedicine
                        )
                        modelContext.insert(entry)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}
