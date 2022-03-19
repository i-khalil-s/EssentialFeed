//
//  FeedImageViewModel.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 11/01/22.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLoaction: Bool {
        return location != nil
    }
    
}
