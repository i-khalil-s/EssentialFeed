//
//  FeedErrorViewModel.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 17/03/22.
//

import Foundation

public struct ResourceErrorViewModel {
    public let message: String?
    
    static var noError: ResourceErrorViewModel {
        return ResourceErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ResourceErrorViewModel {
        return ResourceErrorViewModel(message: message)
    }
}
