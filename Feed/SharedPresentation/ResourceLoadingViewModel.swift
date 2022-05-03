//
//  FeedLoadingViewModel.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 17/03/22.
//

import Foundation

public struct ResourceLoadingViewModel {
    public let isLoading: Bool
}

public protocol ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel)
}
