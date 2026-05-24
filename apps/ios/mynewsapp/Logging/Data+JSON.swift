//
//  Data+JSON.swift
//  mynewsapp
//
//  Created by Pouria Almassi on 2026-05-24.
//

import Foundation

extension Data {
    
    /// Parses the receiver into a minified raw JSON string.
    /// Falls back to a standard UTF-8 string representation if JSON parsing fails.
    public var rawJSONString: String {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: .fragmentsAllowed),
              let minifiedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []),
              let minifiedString = String(data: minifiedData, encoding: .utf8) else {
            // Fallback to standard UTF-8 string if not a valid JSON structure
            return String(data: self, encoding: .utf8) ?? "<Unable to decode as UTF-8 string>"
        }
        return minifiedString
    }
}
