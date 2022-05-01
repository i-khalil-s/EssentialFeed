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

func makeItemsJSON(_ items: [[String:Any]]) -> Data{
    let itemsJSON = [
        "items" : items
    ]
    return  try! JSONSerialization.data(withJSONObject: itemsJSON)
}
