//
//  RemoteFeedLoader.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 04/06/21.
//

import Foundation

public enum HTTPResponseError {
    case success(HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPResponseError) -> Void)
}

public final class RemoteFeedLoader {
    
    private let url: URL!
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { response in
            
            switch response {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
            }
        }
    }
}
