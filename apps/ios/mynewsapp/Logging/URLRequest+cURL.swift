//
//  URLRequest+cURL.swift
//  mynewsapp
//
//  Created by Pouria Almassi on 2026-05-24.
//

import Foundation

extension URLRequest {
    
    /// Generates a standard cURL command representation of the URLRequest.
    /// Safely redacts Authorization header tokens to ensure logs are production-safe.
    public var cURLDescription: String {
        guard let url = url else { return "$ curl <invalid URL>" }
        var components = ["$ curl -i"]
        
        if let method = httpMethod {
            components.append("-X \(method)")
        }
        
        if let headers = allHTTPHeaderFields {
            for (key, value) in headers {
                // Redact credentials in header to preserve production safety
                if key.lowercased() == "authorization" {
                    components.append("-H \"\(key): Bearer [REDACTED]\"")
                } else {
                    components.append("-H \"\(key): \(value)\"")
                }
            }
        }
        
        // Include body if present and decodable as UTF-8 string
        if let body = httpBody, let bodyString = String(data: body, encoding: .utf8) {
            let escapedBody = bodyString.replacingOccurrences(of: "\"", with: "\\\"")
            components.append("-d \"\(escapedBody)\"")
        }
        
        components.append("\"\(url.absoluteString)\"")
        
        return components.joined(separator: " \\\n  ")
    }
}
