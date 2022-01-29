//
//  FeedImageViewModel.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 11/01/22.
//

import Foundation
import Feed

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLoaction: Bool {
        return location != nil
    }
    
}
