//
//  LogListView.swift
//  mynewsapp
//
//  Created by Pouria Almassi on 2026-05-29.
//

import SwiftUI
import Observation

final class NotificationToken: @unchecked Sendable {
    private let token: NSObjectProtocol
    
    init(_ token: NSObjectProtocol) {
        self.token = token
    }
    
    deinit {
        NotificationCenter.default.removeObserver(token)
    }
}

@Observable
@MainActor
final class LogViewModel {
    private(set) var entries: [LogEntry] = []
    
    var searchText: String = ""
    var selectedLevels: Set<LogLevel> = Set(LogLevel.allCases)
    var selectedCategories: Set<AppLogger.Category> = Set(AppLogger.Category.allCases)
    
    private var appendToken: NotificationToken?
    private var clearToken: NotificationToken?
    
    init() {
        refresh()
        
        let appendObs = NotificationCenter.default.addObserver(
            forName: .didAppendLogEntry,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refresh()
        }
        self.appendToken = NotificationToken(appendObs)
        
        let clearObs = NotificationCenter.default.addObserver(
            forName: .didClearLogs,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refresh()
        }
        self.clearToken = NotificationToken(clearObs)
    }
    
    func refresh() {
        self.entries = LogStore.shared.entries
    }
    
    func clear() {
        LogStore.shared.clear()
        refresh()
    }
    
    var filteredEntries: [LogEntry] {
        // Show newest logs on top
        let sorted = entries.sorted(by: { $0.timestamp > $1.timestamp })
        return sorted.filter { entry in
            if !selectedLevels.contains(entry.level) { return false }
            if !selectedCategories.contains(entry.category) { return false }
            if !searchText.isEmpty {
                return entry.message.localizedCaseInsensitiveContains(searchText) ||
                       entry.category.rawValue.localizedCaseInsensitiveContains(searchText) ||
                       entry.level.rawValue.localizedCaseInsensitiveContains(searchText)
            }
            return true
        }
    }
    
    func copyAllToClipboard() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        return filteredEntries.map { entry in
            "[\(formatter.string(from: entry.timestamp))] [\(entry.level.rawValue.uppercased())] [\(entry.category.rawValue)] \(entry.message)"
        }.joined(separator: "\n")
    }
}

struct LogListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = LogViewModel()
    @State private var isShowingClearAlert = false
    @State private var isFiltersExpanded = true
    @State private var didCopyAll = false
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: date)
    }
    
    // Level styling helpers
    private func colorForLevel(_ level: LogLevel) -> Color {
        switch level {
        case .info: return .blue
        case .error: return .orange
        case .fault: return .red
        }
    }
    
    // Category styling helpers
    private func colorForCategory(_ category: AppLogger.Category) -> Color {
        switch category {
        case .general: return .indigo
        case .network: return .purple
        case .ui: return .pink
        case .viewModels: return .teal
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Expanded Filters dashboard
                if isFiltersExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        // Log Severity Levels section
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Severity level")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 8) {
                                ForEach(LogLevel.allCases) { level in
                                    let isSelected = viewModel.selectedLevels.contains(level)
                                    let color = colorForLevel(level)
                                    
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            if isSelected {
                                                if viewModel.selectedLevels.count > 1 {
                                                    viewModel.selectedLevels.remove(level)
                                                }
                                            } else {
                                                viewModel.selectedLevels.insert(level)
                                            }
                                        }
                                    }) {
                                        HStack(spacing: 4) {
                                            if isSelected {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.caption)
                                            }
                                            Text(level.rawValue)
                                                .font(.caption)
                                                .fontWeight(.bold)
                                        }
                                        .foregroundColor(isSelected ? .white : color)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(isSelected ? color : color.opacity(0.12))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        // Categories section
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Category")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(AppLogger.Category.allCases, id: \.self) { category in
                                        let isSelected = viewModel.selectedCategories.contains(category)
                                        let color = colorForCategory(category)
                                        
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.15)) {
                                                if isSelected {
                                                    if viewModel.selectedCategories.count > 1 {
                                                        viewModel.selectedCategories.remove(category)
                                                    }
                                                } else {
                                                    viewModel.selectedCategories.insert(category)
                                                }
                                            }
                                        }) {
                                            HStack(spacing: 4) {
                                                if isSelected {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.caption)
                                                }
                                                Text(category.rawValue)
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                            }
                                            .foregroundColor(isSelected ? .white : color)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(isSelected ? color : color.opacity(0.12))
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Logs display area
                Group {
                    if viewModel.filteredEntries.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "terminal")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary.opacity(0.6))
                            Text(viewModel.entries.isEmpty ? "No logs captured yet." : "No logs matching current filters.")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            if !viewModel.entries.isEmpty {
                                Button("Reset filters") {
                                    withAnimation {
                                        viewModel.selectedLevels = Set(LogLevel.allCases)
                                        viewModel.selectedCategories = Set(AppLogger.Category.allCases)
                                        viewModel.searchText = ""
                                    }
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(viewModel.filteredEntries) { entry in
                            NavigationLink(destination: LogDetailView(entry: entry)) {
                                HStack(spacing: 12) {
                                    // Visual Level indicator strip
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(colorForLevel(entry.level))
                                        .frame(width: 4)
                                        .frame(maxHeight: .infinity)
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            // Format timestamp nicely
                                            Text(formattedTime(entry.timestamp))
                                                .font(.system(.caption, design: .monospaced))
                                                .foregroundColor(.secondary)
                                            
                                            Spacer()
                                            
                                            // Category label
                                            Text(entry.category.rawValue)
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(colorForCategory(entry.category))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(colorForCategory(entry.category).opacity(0.12))
                                                .cornerRadius(4)
                                        }
                                        
                                        // Log snippet preview
                                        Text(entry.message)
                                            .font(.system(.subheadline, design: .monospaced))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("System Logs (\(viewModel.filteredEntries.count))")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "Search messages or categories...")
            .toolbar {
                // Left controls: Dismiss and Clear list
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Dismiss") {
                        dismiss()
                    }
                    
                    Button(role: .destructive, action: {
                        isShowingClearAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .disabled(viewModel.entries.isEmpty)
                }
                
                // Right controls: Filter toggle and Copy All
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        UIPasteboard.general.string = viewModel.copyAllToClipboard()
                        withAnimation {
                            didCopyAll = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                didCopyAll = false
                            }
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: didCopyAll ? "checkmark.circle.fill" : "doc.on.doc")
                            Text(didCopyAll ? "Copied" : "Copy logs")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(didCopyAll ? .green : .blue)
                    }
                    .disabled(viewModel.filteredEntries.isEmpty)
                    
                    Button(action: {
                        withAnimation {
                            isFiltersExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isFiltersExpanded ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
            .alert("Clear all logs?", isPresented: $isShowingClearAlert) {
                Button("Clear all", role: .destructive) {
                    withAnimation {
                        viewModel.clear()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will delete all logs collected in the current run of the application. This action cannot be undone.")
            }
        }
    }
}

#Preview {
    LogListView()
}
