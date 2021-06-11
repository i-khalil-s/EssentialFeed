//
//  HTTPClient.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 11/06/21.
//

import Foundation


public enum HTTPResponse {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPResponse) -> Void)
}
