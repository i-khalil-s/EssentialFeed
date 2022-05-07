//
//  SharedTestHelpers.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 25/09/21.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "Any error", code: 1)
}

func anyURL() -> URL {
    return URL(string: "http://a-url.com")!
}

public extension Date {
    
    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}

