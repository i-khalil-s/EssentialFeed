//
//  FeedCachePolicy.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 26/09/21.
//

import Foundation

internal final class FeedCachePolicy {
    
    private static let calendar = Calendar(identifier: .gregorian)
    
    private init(){}
    
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    internal static func isValid(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        return date < maxCacheAge
    }
}
