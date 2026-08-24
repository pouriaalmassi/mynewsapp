//
//  LogDetailView.swift
//  mynewsapp
//
//  Created by Pouria Almassi on 2026-05-29.
//

import SwiftUI

struct LogDetailView: View {
    let entry: LogEntry
    @State private var didCopy = false
    
    // Formatting date beautifully
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: entry.timestamp)
    }
    
    // Aesthetic Styling Constants based on level
    private var levelColor: Color {
        switch entry.level {
        case .info: return Color.blue
        case .error: return Color.orange
        case .fault: return Color.red
        }
    }
    
    private var levelGradient: LinearGradient {
        switch entry.level {
        case .info:
            return LinearGradient(colors: [Color.blue.opacity(0.15), Color.cyan.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .error:
            return LinearGradient(colors: [Color.orange.opacity(0.15), Color.yellow.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .fault:
            return LinearGradient(colors: [Color.red.opacity(0.15), Color.purple.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    // Categories specific colors
    private var categoryColor: Color {
        switch entry.category {
        case .general: return Color.indigo
        case .network: return Color.purple
        case .ui: return Color.pink
        case .viewModels: return Color.teal
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header card for metadata
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        // Level tag
                        HStack(spacing: 4) {
                            Circle()
                                .fill(levelColor)
                                .frame(width: 8, height: 8)
                            Text(entry.level.rawValue.uppercased())
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(levelColor)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(levelColor.opacity(0.12))
                        .cornerRadius(6)
                        
                        // Category tag
                        Text(entry.category.rawValue)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(categoryColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(categoryColor.opacity(0.12))
                            .cornerRadius(6)
                        
                        Spacer()
                    }
                    
                    Divider()
                        .background(Color.primary.opacity(0.1))
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(formattedDate)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .fontWeight(.medium)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(levelColor.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // Message block section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Log Message")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Copy Button with tactile visual confirmation
                        Button(action: {
                            UIPasteboard.general.string = entry.message
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                didCopy = true
                            }
                            // Reset state after 1.5 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation(.easeOut) {
                                    didCopy = false
                                }
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: didCopy ? "checkmark.circle.fill" : "doc.on.doc")
                                    .font(.subheadline)
                                Text(didCopy ? "Copied" : "Copy")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(didCopy ? .green : levelColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(didCopy ? Color.green.opacity(0.12) : levelColor.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Detailed Content ScrollView
                    ScrollView(.horizontal, showsIndicators: true) {
                        Text(entry.message)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled) // Standard iOS feature for easy text copy
                            .padding()
                            .frame(minWidth: UIScreen.main.bounds.width - 64, alignment: .leading)
                    }
                    .background(Color(uiColor: .tertiarySystemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(
            levelGradient
                .ignoresSafeArea()
        )
        .navigationTitle("Log details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LogDetailView(
            entry: LogEntry(
                category: .network,
                level: .info,
                message: "GET https://api.newsapi.org/v2/top-headlines?category=general\nHTTP/1.1 200 OK\nContent-Type: application/json\nLength: 8192 bytes"
            )
        )
    }
}
